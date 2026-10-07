import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.private.kicker as Kicker
import "diag.js" as Diag
import "strings.js" as S

// Ventana propia a pantalla completa.
// No usamos Kicker.DashboardWindow porque su código C++ pide blur al compositor
// cada vez que se muestra y no se puede desactivar desde QML.
Window {
    id: root

    // Pantalla donde se abre (la fija LauncherButton antes de abrir)
    property var targetScreen: null

    // Modelos (los crea main.qml)
    property var rootModel: null
    property var popularModel: null
    property var recentModel: null
    property var runnerModel: null

    // Interfaz
    property bool gridMode: true

    // Ajustes (los enlaza LauncherButton con la configuración del plasmoid)
    // Idioma de la interfaz ("en" o "es"); lo enlaza LauncherButton con los ajustes
    property string lang: "en"
    property color bgColor: "#000000"
    property real bgOpacity: 0.75
    property real bubbleAlpha: 0.60
    property color bubbleColor: "#000000"
    // Texto de las cuadrículas: claro u oscuro según lo claro que quede su color sobre el fondo
    readonly property color bubbleInk: {
        const a = bubbleAlpha;
        const lum = 0.2126 * (bubbleColor.r * a + bgColor.r * (1 - a))
                  + 0.7152 * (bubbleColor.g * a + bgColor.g * (1 - a))
                  + 0.0722 * (bubbleColor.b * a + bgColor.b * (1 - a));
        return lum > 0.5 ? "#111111" : "#FFFFFF";
    }
    readonly property color bubbleInkFaint: Qt.rgba(bubbleInk.r, bubbleInk.g, bubbleInk.b, 0.4)
    property color accentColor: "#D71921"
    property bool use24Hour: false
    property int dateStyle: 0
    // Zona derecha: 0 = reproductor, 1 = tarjetas de categorías, 2 = nada
    property int rightPanel: 0
    readonly property bool mediaEnabled: rightPanel === 0
    readonly property bool cardsEnabled: rightPanel === 1
    property color cardColor: "#FFFFFF"
    property real cardOpacity: 0.30
    // El PlasmoidItem (lo pasa LauncherButton; lo necesita el modelo de categorías)
    property var applet: null
    property bool showTaskbar: true
    property bool showSeconds: true
    // Animaciones (interruptor general + una casilla por tipo)
    property bool animations: true
    property bool animFade: true
    property bool animClock: true
    property bool animTyping: true
    property bool animFilter: true
    property bool animHover: true
    property int marqueeMode: 1
    property bool animCardsMarquee: true
    signal rightPanelRequested(int mode)
    readonly property bool fxFade: animations && animFade
    readonly property bool fxClock: animations && animClock
    readonly property bool fxTyping: animations && animTyping
    readonly property bool fxFilter: animations && animFilter
    readonly property bool fxHover: animations && animHover
    readonly property bool fxCardsMarquee: animations && animCardsMarquee
    property string appVersion: ""
    // Fuentes elegidas en los ajustes ("" = la incluida en el plasmoid)
    property string fontClockName: ""
    property string fontSearchName: ""
    property string fontAppsName: ""
    property string fontTipsName: ""
    property string fontMediaName: ""
    property string fontCardsName: ""
    onLangChanged: updateClock()
    onUse24HourChanged: updateClock()
    onDateStyleChanged: updateClock()
    onShowSecondsChanged: updateClock()
    readonly property real u: Math.max(8, height / 100)   // 1 % del alto
    readonly property bool searching: searchField.text !== ""
    // Sin fuentes incluidas: "" = la fuente del sistema (se puede elegir otra en los ajustes)
    readonly property string fontText: ""
    readonly property string fontDisplay: ""

    // Familias instaladas en el sistema (para comprobar que la fuente elegida existe)
    readonly property bool customFonts: fontClockName !== "" || fontSearchName !== ""
        || fontAppsName !== "" || fontTipsName !== "" || fontMediaName !== "" || fontCardsName !== ""
    readonly property var installedFamilies: {
        if (!customFonts) {
            return [];
        }
        try {
            return Qt.fontFamilies();
        } catch (e) {
            return [];
        }
    }
    function resolveFont(name, fallback) {
        if (name === "") {
            return fallback;
        }
        if (installedFamilies.length > 0 && installedFamilies.indexOf(name) < 0) {
            return fallback;
        }
        return name;
    }
    readonly property string fClock: resolveFont(fontClockName, fontDisplay)
    readonly property string fSearch: resolveFont(fontSearchName, "")
    readonly property string fApps: resolveFont(fontAppsName, fontText)
    readonly property string fTips: resolveFont(fontTipsName, fontDisplay)
    readonly property string fMedia: resolveFont(fontMediaName, fontDisplay)
    readonly property string fCards: resolveFont(fontCardsName, fontDisplay)

    // ---------------------------------------------------------------- avisos
    // Fallos de módulos opcionales (apps activas, reproductor, audio)
    property var problems: []
    property bool noticeDismissed: false
    property int lastProblemCount: 0
    readonly property var fontIssues: {
        const out = [];
        const cats = [[S.tr(root.lang, "Date and time"), fontClockName], [S.tr(root.lang, "Search"), fontSearchName],
                      [S.tr(root.lang, "App names"), fontAppsName], [S.tr(root.lang, "Button bubbles"), fontTipsName],
                      [S.tr(root.lang, "Media player"), fontMediaName], [S.tr(root.lang, "Cards"), fontCardsName]];
        for (let i = 0; i < cats.length; ++i) {
            const name = cats[i][1];
            if (name !== "" && installedFamilies.length > 0 && installedFamilies.indexOf(name) < 0) {
                out.push(Diag.fontProblem(lang, cats[i][0], name));
            }
        }
        return out;
    }
    readonly property var allProblems: problems.concat(fontIssues)
    readonly property bool noticeVisible: allProblems.length > 0 && !noticeDismissed
    onAllProblemsChanged: {
        if (allProblems.length > lastProblemCount) {
            noticeDismissed = false;
        }
        lastProblemCount = allProblems.length;
    }

    function addProblem(p) {
        for (let i = 0; i < problems.length; ++i) {
            if (problems[i].id === p.id) {
                return;
            }
        }
        console.warn("NonDotLauncher: " + p.title + " - " + p.what + " " + p.detail);
        problems = problems.concat([p]);
    }

    // Se llama cuando un Loader falla: vuelve a cargar el archivo para obtener el error técnico
    function reportLoadFailure(id, feature, file, off) {
        const c = Qt.createComponent(Qt.resolvedUrl(file));
        const err = c.status === Component.Error ? c.errorString() : S.tr(root.lang, "Could not create the component.");
        addProblem(Diag.describe(lang, id, feature, err, off));
    }

    // Lista plana de todas las apps (la hija con más elementos del modelo raíz)
    property var allAppsModel: null
    // Texto de búsqueda en minúsculas (filtra la cuadrícula en tiempo real)
    readonly property string query: searchField.text.trim().toLowerCase()
    readonly property int gridColumns: 6
    // Panel del reproductor: solo se muestra si cabe a la derecha de la columna central
    // Se pega a la derecha de la columna central y ocupa de la parte alta de la fila de
    // más usadas a la parte baja de la cuadrícula de apps (como si fuera otra columna del diseño).
    readonly property real stackGap: u * 1.6
    // Sin la barra de apps activas, la cuadrícula gana una fila y se centra del todo
    readonly property bool taskbarActive: showTaskbar && taskLoader.status !== Loader.Error
    readonly property int extraRows: taskbarActive ? 0 : 1
    readonly property real stackOffset: taskbarActive ? u * 3 : 0
    readonly property real quickH: cellH + gridPad * 2
    readonly property real allH: (3 + extraRows) * cellH + gridPad * 2
    readonly property real gridH: quickH + stackGap + allH
    readonly property real nominalStackH: u * 6 + stackGap + quickH + stackGap + allH
    readonly property real gridTop: (height - nominalStackH) / 2 - stackOffset + u * 6 + stackGap
    // Botón M (cambia la zona derecha)
    readonly property real modeBtnSize: u * 8
    // Alto de la zona derecha: sin la barra de apps, el botón M ocupa su parte baja
    readonly property real rightH: taskbarActive ? gridH : gridH - modeBtnSize - stackGap
    readonly property real mediaX: stack.x + stack.width + u * 2
    readonly property real mediaWidth: Math.min(u * 33, width - mediaX - u * 3)
    readonly property bool mediaFits: mediaWidth >= u * 24
    readonly property real mediaControlsH: u * 8.4
    readonly property real mediaOutputH: u * 7.4
    readonly property real cellH: u * 15
    readonly property real gridPad: u * 1.2
    // Más usadas + recientes (se rellena en rebuildQuick)
    property var quickItems: []

    title: "NonDot Launcher"
    flags: Qt.FramelessWindowHint

    // Progreso del fundido de entrada (0..1). La opacidad de la ventana no está soportada
    // por el compositor, así que se desvanecen el fondo negro y el contenido por separado.
    property real fade: 0
    property bool closing: false
    // Progreso del fundido al cambiar de vista (rejilla/lista)
    property real viewFade: 1

    // Negro profundo al 75 % de opacidad, sin blur
    color: Qt.rgba(bgColor.r, bgColor.g, bgColor.b, bgOpacity * fade)

    NumberAnimation {
        id: openFade
        target: root
        property: "fade"
        to: 1
        duration: root.fxFade ? 240 : 0
        easing.type: Easing.OutCubic
    }

    // Cierre suave: se desvanece y después se oculta la ventana
    SequentialAnimation {
        id: closeFade
        NumberAnimation { target: root; property: "fade"; to: 0; duration: root.fxFade ? 180 : 0; easing.type: Easing.InCubic }
        ScriptAction { script: { root.closing = false; root.hide(); } }
    }

    function dismiss() {
        if (!visible || closing) {
            return;
        }
        closeMenu();
        closing = true;
        openFade.stop();
        clockFade.stop();
        closeFade.restart();
    }

    // Reloj: aparece un poco después del fondo
    NumberAnimation {
        id: clockFade
        target: clockBlock
        property: "opacity"
        from: 0
        to: 1
        duration: root.fxClock ? 420 : 0
        easing.type: Easing.OutCubic
    }


    // ---------------------------------------------------------------- abrir / cerrar
    function open() {
        if (targetScreen) {
            screen = targetScreen;
            // En Wayland, Qt decide el monitor del modo pantalla completa por la geometría
            if (targetScreen.virtualX !== undefined) {
                x = targetScreen.virtualX;
                y = targetScreen.virtualY;
                width = targetScreen.width;
                height = targetScreen.height;
            }
        }
        closeFade.stop();
        closing = false;
        searchField.text = "";
        navZone = "search";
        categoryIndex = -1;
        applyCategory();
        updateAllApps();
        rebuildQuick();
        if (!visible) {
            fade = 0;
            clockBlock.opacity = fxClock ? 0 : 1;
        }
        updateClock();
        showFullScreen();
        openFade.restart();
        if (fxClock) {
            clockDelay.restart();
        } else {
            clockBlock.opacity = 1;
        }
        raise();
        requestActivate();
        searchField.forceActiveFocus();
    }

    function toggle() {
        if (visible && !closing) {
            dismiss();
        } else {
            open();
        }
    }

    onVisibleChanged: {
        if (!visible) {
            if (outputLoader.item) {
                outputLoader.item.open = false;
            }
            closeMenu();
            searchField.text = "";
            allView.positionViewAtBeginning();
        }
    }

    // Cambio de vista con fundido: se desvanece, cambia y reaparece
    SequentialAnimation {
        id: viewSwitch
        NumberAnimation { target: root; property: "viewFade"; to: 0; duration: root.fxFilter ? 120 : 0 }
        ScriptAction { script: root.gridMode = !root.gridMode }
        NumberAnimation { target: root; property: "viewFade"; to: 1; duration: root.fxFilter ? 160 : 0 }
    }

    // ---------------------------------------------------------------- reloj
    property string dateText: ""
    property string timeText: ""

    function pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    function updateClock() {
        const n = new Date();
        if (dateStyle === 1) {
            dateText = pad(n.getDate()) + "/" + pad(n.getMonth() + 1) + "/" + n.getFullYear();
        } else {
            dateText = S.longDate(lang, n);
        }
        const h = n.getHours();
        const mm = pad(n.getMinutes());
        const ss = showSeconds ? ":" + pad(n.getSeconds()) : "";
        if (use24Hour) {
            timeText = pad(h) + ":" + mm + ss;
        } else {
            const h12 = h % 12 === 0 ? 12 : h % 12;
            timeText = h12 + ":" + mm + ss + " " + (h < 12 ? "AM" : "PM");
        }
    }

    Timer { id: clockDelay; interval: 160; onTriggered: clockFade.restart() }
    Timer {
        interval: 1000
        repeat: true
        running: root.visible
        onTriggered: root.updateClock()
    }

    // ---------------------------------------------------------------- datos
    function updateAllApps() {
        if (!rootModel) {
            return;
        }
        let best = null;
        let bestCount = -1;
        for (let i = 0; i < rootModel.count; ++i) {
            const m = rootModel.modelForRow(i);
            if (m && m.count > bestCount) {
                best = m;
                bestCount = m.count;
            }
        }
        allAppsModel = best;
    }

    function rebuildQuick() {
        const slots = gridColumns;
        const items = [];
        const seen = {};

        function add(m, src) {
            if (!m) {
                return;
            }
            for (let i = 0; i < m.count && items.length < slots; ++i) {
                const idx = m.index(i, 0);
                const name = m.data(idx, Qt.DisplayRole);
                if (seen[name]) {
                    continue;
                }
                seen[name] = true;
                items.push({ label: name, icon: m.data(idx, Qt.DecorationRole), src: src, row: i });
            }
        }

        add(popularModel, 0);                  // primero las más usadas
        if (items.length < slots) {
            add(recentModel, 1);               // las recientes solo rellenan lo que sobre
        }
        quickItems = items;
    }

    function launchQuick(item) {
        const m = item.src === 0 ? popularModel : recentModel;
        if (m) {
            m.trigger(item.row, "", null);
        }
        dismiss();
    }

    // Filtro en tiempo real sobre la lista de todas las apps
    KItemModels.KSortFilterProxyModel {
        id: filtered
        sourceModel: root.allAppsModel
        filterRowCallback: (sourceRow, sourceParent) => {
            const idx = sourceModel.index(sourceRow, 0, sourceParent);
            // Categoría elegida en las tarjetas (si hay una)
            if (root.categoryIds !== null) {
                if (!root.categoryIds[String(sourceModel.data(idx, root.favoriteIdRole))]) {
                    return false;
                }
            }
            if (root.query === "") {
                return true;
            }
            const name = String(sourceModel.data(idx, Qt.DisplayRole));
            return name.toLowerCase().includes(root.query);
        }
    }
    onQueryChanged: {
        navZone = "search";
        filtered.invalidateFilter();
        allView.positionViewAtBeginning();
    }

    // ---------------------------------------------------------------- categorías
    // Kicker::FavoriteIdRole = Qt::UserRole + 3 y HasChildrenRole = Qt::UserRole + 7 (actionlist.h)
    readonly property int favoriteIdRole: Qt.UserRole + 3
    readonly property int hasChildrenRole: Qt.UserRole + 7
    // [{ name, count, ids }]; ids = identificadores de las apps de esa categoría
    property var categories: []
    property int categoryIndex: -1
    property var categoryIds: null

    // Reúne los identificadores de todas las apps de un modelo (con subgrupos); devuelve cuántas son
    function collectIds(model, set) {
        let n = 0;
        for (let i = 0; i < model.count; ++i) {
            const idx = model.index(i, 0);
            const child = model.data(idx, hasChildrenRole) ? model.modelForRow(i) : null;
            if (child) {
                n += collectIds(child, set);
            } else {
                const id = String(model.data(idx, favoriteIdRole));
                if (id !== "" && !set[id]) {
                    set[id] = true;
                    n += 1;
                }
            }
        }
        return n;
    }

    function rebuildCategories() {
        const holder = catLoader.item;
        const m = holder ? holder.model : null;
        const out = [];
        if (m) {
            for (let i = 0; i < m.count; ++i) {
                const child = m.modelForRow(i);
                if (!child) {
                    continue;
                }
                const ids = {};
                const n = collectIds(child, ids);
                if (n === 0) {
                    continue;      // las categorías vacías no se muestran
                }
                out.push({ name: String(m.data(m.index(i, 0), Qt.DisplayRole)), count: n, ids: ids });
            }
        }
        categories = out;
        if (categoryIndex >= out.length) {
            categoryIndex = -1;
        }
        applyCategory();
    }

    function applyCategory() {
        categoryIds = (categoryIndex >= 0 && categoryIndex < categories.length) ? categories[categoryIndex].ids : null;
    }

    // Clic en una tarjeta: filtra por esa categoría; otro clic en la misma quita el filtro
    function pickCategory(i) {
        categoryIndex = categoryIndex === i ? -1 : i;
        applyCategory();
    }

    onCategoryIdsChanged: {
        filtered.invalidateFilter();
        allView.positionViewAtBeginning();
    }
    onCardsEnabledChanged: {
        if (!cardsEnabled) {
            categoryIndex = -1;
            applyCategory();
        }
    }

    // ---------------------------------------------------------------- teclado
    // El foco siempre está en el buscador; las flechas mueven una selección por tres zonas:
    // "search" (escribiendo), "quick" (fila de más usadas) y "grid" (todas las apps).
    property string navZone: "search"
    property int quickIndex: 0
    readonly property bool quickAvailable: !searching && gridMode && quickItems.length > 0

    function handleNavKey(event) {
        if (menuOpen || noticeVisible) {
            return;
        }
        const k = event.key;
        const isNav = k === Qt.Key_Up || k === Qt.Key_Down || k === Qt.Key_Left || k === Qt.Key_Right
            || k === Qt.Key_Return || k === Qt.Key_Enter;

        if (!isNav) {
            // Letras, borrar, etc.: la selección vuelve al buscador
            const modifier = k === Qt.Key_Shift || k === Qt.Key_Control || k === Qt.Key_Alt
                || k === Qt.Key_Meta || k === Qt.Key_Escape || k === Qt.Key_AltGr;
            if (!modifier) {
                navZone = "search";
            }
            return;
        }

        if (navZone === "search") {
            if (k === Qt.Key_Down) {
                if (quickAvailable) {
                    navZone = "quick";
                    quickIndex = 0;
                } else if (allView.count > 0) {
                    navZone = "grid";
                    allView.currentIndex = 0;
                }
                event.accepted = true;
            } else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
                launchFirstResult();
                event.accepted = true;
            }
            return;        // izquierda y derecha siguen moviendo el cursor del texto
        }

        event.accepted = true;
        if (navZone === "quick") {
            if (k === Qt.Key_Left) {
                quickIndex = Math.max(0, quickIndex - 1);
            } else if (k === Qt.Key_Right) {
                quickIndex = Math.min(quickItems.length - 1, quickIndex + 1);
            } else if (k === Qt.Key_Up) {
                navZone = "search";
            } else if (k === Qt.Key_Down) {
                if (allView.count > 0) {
                    navZone = "grid";
                    allView.currentIndex = Math.min(quickIndex, allView.count - 1);
                }
            } else if (quickIndex < quickItems.length) {
                launchQuick(quickItems[quickIndex]);
            }
            return;
        }

        // zona "grid"
        if (k === Qt.Key_Left) {
            allView.moveCurrentIndexLeft();
        } else if (k === Qt.Key_Right) {
            allView.moveCurrentIndexRight();
        } else if (k === Qt.Key_Down) {
            allView.moveCurrentIndexDown();
        } else if (k === Qt.Key_Up) {
            if (allView.currentIndex < allView.columns) {
                if (quickAvailable) {
                    quickIndex = Math.min(allView.currentIndex, quickItems.length - 1);
                    navZone = "quick";
                } else {
                    navZone = "search";
                }
            } else {
                allView.moveCurrentIndexUp();
            }
        } else if (allView.currentIndex >= 0) {
            launchFiltered(allView.currentIndex);
        }
    }

    // ---------------------------------------------------------------- menú de clic derecho
    // Las acciones son las mismas que ofrece KDE (editar aplicación, acciones de la app,
    // añadir al panel/escritorio...); se dibujan con la estética del lanzador.
    property var menuActions: []
    property var menuModel: null
    property int menuRow: -1
    property bool menuOpen: false
    property real menuX: 0
    property real menuY: 0

    // Kicker::ActionListRole = Qt::UserRole + 9 (ver actionlist.h de plasma-workspace)
    readonly property int actionListRole: Qt.UserRole + 9

    function openMenu(model, row, sx, sy) {
        if (!model || row < 0) {
            return;
        }
        let list = null;
        try {
            list = model.data(model.index(row, 0), actionListRole);
        } catch (e) {
            console.warn("NonDotLauncher: could not read the app menu: " + e);
            return;
        }
        if (!list || list.length === 0) {
            return;
        }
        const flat = [];
        Array.from(list).forEach(a => {
            if (a.subActions) {
                flat.push({ type: "title", text: a.text });
                Array.from(a.subActions).forEach(s => flat.push(s));
            } else {
                flat.push(a);
            }
        });
        menuActions = flat;
        menuModel = model;
        menuRow = row;
        menuX = sx;
        menuY = sy;
        menuOpen = true;
    }

    function closeMenu() {
        menuOpen = false;
        menuActions = [];
        menuModel = null;
        menuRow = -1;
    }

    function triggerMenuAction(a) {
        const m = menuModel;
        const r = menuRow;
        const closeRequested = m ? m.trigger(r, a.actionId, a.actionArgument) : false;
        closeMenu();
        if (closeRequested === true) {
            dismiss();
        }
    }

    function openFilteredMenu(index, sx, sy) {
        const src = filtered.mapToSource(filtered.index(index, 0));
        openMenu(allAppsModel, src.row, sx, sy);
    }

    // Abre la app de la fila "index" del modelo filtrado
    function launchFiltered(index) {
        const src = filtered.mapToSource(filtered.index(index, 0));
        if (allAppsModel && src.row >= 0) {
            allAppsModel.trigger(src.row, "", null);
        }
        dismiss();
    }

    Connections {
        target: root.rootModel
        function onCountChanged() { root.updateAllApps(); }
        function onRefreshed() { root.updateAllApps(); }
    }
    Connections {
        target: root.popularModel
        function onCountChanged() { rebuildTimer.restart(); }
    }
    Connections {
        target: root.recentModel
        function onCountChanged() { rebuildTimer.restart(); }
    }
    Timer { id: rebuildTimer; interval: 50; onTriggered: root.rebuildQuick() }

    // ---------------------------------------------------------------- sistema
    SystemModelHolder { id: sys }

    P5Support.DataSource {
        id: shell
        engine: "executable"
        property int serial: 0
        onNewData: (sourceName, data) => disconnectSource(sourceName)
        function run(cmd) {
            serial += 1;
            connectSource(cmd + " # " + serial);
        }
    }

    // ---------------------------------------------------------------- interfaz
    Item {
        id: stage
        anchors.fill: parent
        opacity: root.fade

        // clic en el fondo cierra el lanzador
        MouseArea {
            anchors.fill: parent
            onClicked: root.handleBackgroundClick()
        }

        // Columna central: buscador, más usadas, todas las apps, barra de tareas
        Item {
            id: stack
            width: Math.min(root.width * 0.56, root.height * 1.15)
            height: column.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -root.stackOffset

            ColumnLayout {
                id: column
                width: parent.width
                spacing: root.u * 1.6

                // Zona roja: buscador (barra delgada) + botón de vista
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: root.u * 6
                    spacing: root.u * 1.5

                    Bubble {

                        tint: root.bubbleColor

                        alpha: root.bubbleAlpha
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        u: root.u
                        radius: height / 2

                        Image {
                            id: searchIcon
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: root.u * 0.4
                            width: root.u * 5.2
                            height: width
                            source: "icons/buscar.svg"
                            sourceSize: Qt.size(256, 256)
                            smooth: true
                            mipmap: true
                        }

                        Text {
                            anchors.left: searchField.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !root.searching
                            text: S.tr(root.lang, "Search apps…")
                            color: root.bubbleInkFaint
                            font.family: root.fSearch !== "" ? root.fSearch : root.fontDisplay
                            font.pixelSize: root.u * 2.4
                        }

                        TextInput {
                            id: searchField
                            anchors.left: searchIcon.right
                            anchors.leftMargin: root.u * 1.6
                            anchors.right: parent.right
                            anchors.rightMargin: root.u * 2.4
                            anchors.verticalCenter: parent.verticalCenter
                            focus: true
                            color: root.bubbleInk
                            selectionColor: "#D71921"
                            clip: true
                            font.family: root.fSearch !== "" ? root.fSearch : root.fontText
                            font.pixelSize: root.u * 2.4

                            Keys.onEscapePressed: root.handleEscape()
                            Keys.onPressed: event => root.handleNavKey(event)
                        }
                    }

                    // Un solo botón: muestra el icono de la vista a la que se va a cambiar
                    NIconButton {
                        Layout.preferredWidth: root.u * 6
                        Layout.preferredHeight: root.u * 6
                        size: root.u * 6
                        iconName: root.gridMode ? "vista-lista" : "vista-rejilla"
                        toolTip: root.gridMode ? S.tr(root.lang, "List view") : S.tr(root.lang, "Grid view")
                        tipSide: "left"
                        fontFamily: root.fTips
                        typing: root.fxTyping
                        hoverFx: root.fxHover
                        onClicked: viewSwitch.restart()
                    }
                }

                // Fila de más usadas y recientes (la fila reservada de la cuadrícula 6x4)
                Bubble {
                    tint: root.bubbleColor
                    alpha: root.bubbleAlpha
                    id: quickBubble
                    opacity: root.viewFade
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: root.cellH + root.gridPad * 2
                    visible: !root.searching && root.gridMode
                    u: root.u

                    Row {
                        x: root.gridPad
                        y: root.gridPad
                        Repeater {
                            model: root.quickItems
                            delegate: AppTile {
                                required property int index
                                required property var modelData
                                selected: root.navZone === "quick" && index === root.quickIndex
                                accent: root.accentColor
                                ink: root.bubbleInk
                                width: (quickBubble.width - root.gridPad * 2) / root.gridColumns
                                height: root.cellH
                                u: root.u
                                label: modelData.label
                                iconSource: modelData.icon
                                fontFamily: root.fApps
                                onClicked: root.launchQuick(modelData)
                                onRightClicked: (sx, sy) => root.openMenu(modelData.src === 0 ? root.popularModel : root.recentModel, modelData.row, sx, sy)
                            }
                        }
                    }
                }

                // Todas las apps: 3 filas visibles (4 al buscar), con scroll por rueda
                Bubble {
                    tint: root.bubbleColor
                    alpha: root.bubbleAlpha
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: ((root.searching || !root.gridMode ? 4 : 3) + root.extraRows) * root.cellH + root.gridPad * 2
                    u: root.u

                    AppView {
                        id: allView
                        opacity: root.viewFade
                        anchors.fill: parent
                        anchors.margins: root.gridPad
                        u: root.u
                        listMode: !root.gridMode
                        animated: root.fxFilter
                        showCurrent: root.navZone === "grid"
                        accent: root.accentColor
                        ink: root.bubbleInk
                        fixedColumns: root.gridColumns
                        rowHeight: root.cellH
                        fontFamily: root.fApps
                        model: filtered
                        onLaunch: index => root.launchFiltered(index)
                        onContext: (index, sx, sy) => root.openFilteredMenu(index, sx, sy)
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.searching && filtered.count === 0
                        text: S.tr(root.lang, "No results")
                        color: root.bubbleInkFaint
                        font.family: root.fTips
                        font.pixelSize: root.u * 3
                    }
                }
            }
        }

        // Zona celeste: apps en ejecución, flotando cerca del borde inferior
        Bubble {
            tint: root.bubbleColor
            alpha: root.bubbleAlpha
            id: taskBubble
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.u * 3
            height: root.u * 10
            width: Math.min(stack.width,
                (taskLoader.item ? taskLoader.item.implicitWidth : 0) + root.u * 3)
            visible: root.taskbarActive
            u: root.u

            Loader {
                id: taskLoader
                anchors.fill: parent
                active: root.showTaskbar
                source: "TaskBar.qml"
                onStatusChanged: if (status === Loader.Error) {
                    root.reportLoadFailure("taskbar", S.tr(root.lang, "Active apps"), "TaskBar.qml", "")
                }
                onLoaded: {
                    item.u = Qt.binding(() => root.u);
                    item.fontFamily = Qt.binding(() => root.fTips);
                    item.fontText = Qt.binding(() => root.fApps);
                    item.animated = Qt.binding(() => root.fxTyping);
                            item.accent = Qt.binding(() => root.accentColor);
                    item.ink = Qt.binding(() => root.bubbleInk);
                }
            }
            Connections {
                target: taskLoader.item
                ignoreUnknownSignals: true
                function onActivatedApp() { root.dismiss(); }
            }
        }

        // Fecha y hora (arriba a la izquierda)
        Column {
            id: clockBlock
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: root.u * 4
            anchors.topMargin: root.u * 4
            spacing: root.u * 0.8
            opacity: 0

            Text {
                text: root.timeText
                color: "white"
                font.family: root.fClock
                font.pixelSize: root.u * 6
            }
            Text {
                text: root.dateText
                color: "#BBBBBB"
                font.family: root.fClock
                font.pixelSize: root.u * 2.6
            }
        }

        // Versión: texto pequeño en la esquina inferior izquierda
        Text {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: root.u * 2
            text: "v" + root.appVersion
            color: "#666666"
            font.family: root.fTips
            font.pixelSize: root.u * 1.4
        }

        // Sesión: pegada al borde izquierdo de la pantalla, centrada en vertical
        Bubble {
            tint: root.bubbleColor
            alpha: root.bubbleAlpha
            id: powerBubble
            anchors.left: parent.left
            anchors.leftMargin: root.u * 3
            anchors.verticalCenter: parent.verticalCenter
            width: root.u * 11
            height: powerColumn.implicitHeight + root.u * 3
            u: root.u

            Column {
                id: powerColumn
                anchors.centerIn: parent
                spacing: root.u * 1.5

                Repeater {
                    model: [
                        { icon: "apagar",          sys: "system-shutdown",    tip: S.tr(root.lang, "Power off") },
                        { icon: "reiniciar",       sys: "system-reboot",      tip: S.tr(root.lang, "Restart") },
                        { icon: "suspender",       sys: "system-suspend",     tip: S.tr(root.lang, "Suspend") },
                        { icon: "cambiar-usuario", sys: "system-switch-user", tip: S.tr(root.lang, "Switch user") }
                    ]
                    delegate: NIconButton {
                        required property var modelData
                        // depende de sys.count para reevaluarse si cambian las acciones
                        readonly property int row: (sys.count, sys.rowFor(modelData.sys))
                        visible: row >= 0
                        size: root.u * 8
                        iconName: modelData.icon
                        toolTip: modelData.tip
                        fontFamily: root.fTips
                        typing: root.fxTyping
                        hoverFx: root.fxHover
                        onClicked: {
                            sys.run(row);
                            root.dismiss();
                        }
                    }
                }
            }
        }

        // Cerrar: esquina superior derecha
        NIconButton {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: root.u * 3
            size: root.u * 8
            iconName: "cerrar"
            toolTip: S.tr(root.lang, "Close")
            tipSide: "left"
            fontFamily: root.fTips
            typing: root.fxTyping
            hoverFx: root.fxHover
            onClicked: root.dismiss()
        }

        // Ajustes: esquina inferior derecha, abre Preferencias del Sistema
        NIconButton {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: root.u * 3
            size: root.u * 8
            iconName: "ajustes"
            toolTip: S.tr(root.lang, "Settings")
            tipSide: "left"
            fontFamily: root.fTips
            typing: root.fxTyping
            hoverFx: root.fxHover
            onClicked: {
                shell.run("systemsettings >/dev/null 2>&1 &");
                root.dismiss();
            }
        }

        // Botón M: cambia la zona derecha (reproductor, tarjetas, nada).
        // Con la barra de apps activas va a su derecha; sin ella, bajo la zona derecha.
        ModeButton {
            id: modeButton
            size: root.modeBtnSize
            u: root.u
            lang: root.lang
            x: root.taskbarActive ? taskBubble.x + taskBubble.width + root.stackGap : root.mediaX
            y: root.taskbarActive ? taskBubble.y + (taskBubble.height - height) / 2
                                  : root.gridTop + root.gridH - height
            baseColor: root.cardColor
            baseOpacity: root.cardOpacity
            backdrop: root.bgColor
            accent: root.accentColor
            fontFamily: root.fTips
            tipFont: root.fTips
            mode: root.rightPanel
            typing: root.fxTyping
            hoverFx: root.fxHover
            onNext: root.rightPanelRequested((root.rightPanel + 1) % 3)
        }

        // Modelo de categorías (solo se carga si se eligen las tarjetas)
        Loader {
            id: catLoader
            active: root.cardsEnabled
            source: "CategoryModel.qml"
            onStatusChanged: if (status === Loader.Error) {
                root.reportLoadFailure("categories", S.tr(root.lang, "Category cards"), "CategoryModel.qml",
                                       S.tr(root.lang, "Plasmoid settings \u25B8 Right area"))
            }
            onLoaded: {
                item.applet = root.applet;
                root.rebuildCategories();
            }
        }
        Connections {
            target: catLoader.item ? catLoader.item.model : null
            ignoreUnknownSignals: true
            function onCountChanged() { rebuildCatTimer.restart(); }
            function onRefreshed() { rebuildCatTimer.restart(); }
        }
        Timer { id: rebuildCatTimer; interval: 80; onTriggered: root.rebuildCategories() }

        // Tarjetas de categorías (lado derecho, mismo espacio que el reproductor)
        CategoryCards {
            visible: root.cardsEnabled && root.mediaFits
            x: root.mediaX
            y: root.gridTop
            width: root.mediaWidth
            height: root.rightH
            u: root.u
            lang: root.lang
            cardsMarquee: root.fxCardsMarquee
            categories: root.categories
            selected: root.categoryIndex
            animated: root.animations
            baseColor: root.cardColor
            baseOpacity: root.cardOpacity
            backdrop: root.bgColor
            fontFamily: root.fCards
            accent: root.accentColor
            onPicked: index => root.pickCategory(index)
        }

        // Reproductor de medios y salida de audio (lado derecho). Cada parte se carga por
        // separado: si falla una, la otra sigue funcionando y se avisa de qué falta.
        Column {
            id: mediaColumn
            visible: root.mediaEnabled && root.mediaFits
            x: root.mediaX
            y: root.gridTop
            width: root.mediaWidth
            height: root.rightH
            spacing: root.stackGap

            Loader {
                id: playerLoader
                width: parent.width
                height: item ? item.implicitHeight : 0
                active: root.mediaEnabled
                source: "MediaPlayer.qml"
                onStatusChanged: if (status === Loader.Error) {
                    root.reportLoadFailure("media", S.tr(root.lang, "Media player"), "MediaPlayer.qml",
                                           S.tr(root.lang, "Plasmoid settings \u25B8 Right area"))
                }
                onLoaded: {
                    item.u = Qt.binding(() => root.u);
                    item.lang = Qt.binding(() => root.lang);
                    item.alpha = Qt.binding(() => root.bubbleAlpha);
                    item.tint = Qt.binding(() => root.bubbleColor);
                    item.ink = Qt.binding(() => root.bubbleInk);
                    item.fontFamily = Qt.binding(() => root.fMedia);
                    item.accent = Qt.binding(() => root.accentColor);
                    item.gap = Qt.binding(() => root.stackGap);
                    item.controlsHeight = Qt.binding(() => root.mediaControlsH);
                    item.cardHeight = Qt.binding(() => root.rightH - root.mediaControlsH
                                                       - root.mediaOutputH - root.stackGap * 2);
                    item.marqueeMode = Qt.binding(() => root.animations ? root.marqueeMode : 0);
                    item.animated = Qt.binding(() => root.fxHover);
                }
            }

            Loader {
                id: outputLoader
                width: parent.width
                height: item ? item.implicitHeight : 0
                active: root.mediaEnabled
                source: "AudioOutput.qml"
                onStatusChanged: if (status === Loader.Error) {
                    root.reportLoadFailure("audio", S.tr(root.lang, "Audio output"), "AudioOutput.qml",
                                           S.tr(root.lang, "Plasmoid settings \u25B8 Right area"))
                }
                onLoaded: {
                    item.u = Qt.binding(() => root.u);
                    item.lang = Qt.binding(() => root.lang);
                    item.alpha = Qt.binding(() => root.bubbleAlpha);
                    item.tint = Qt.binding(() => root.bubbleColor);
                    item.ink = Qt.binding(() => root.bubbleInk);
                    item.fontFamily = Qt.binding(() => root.fMedia);
                    item.accent = Qt.binding(() => root.accentColor);
                }
            }
        }

        // Cierra el menú al hacer clic en cualquier otro sitio
        MouseArea {
            anchors.fill: parent
            z: 200
            visible: root.menuOpen
            acceptedButtons: Qt.AllButtons
            onPressed: root.closeMenu()
        }

        // Aviso de problemas: qué falló, qué falta y si hay que esperar una actualización
        Rectangle {
            id: noticeVeil
            anchors.fill: parent
            z: 300
            visible: root.noticeVisible
            color: Qt.rgba(0, 0, 0, 0.6)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }

            ProblemsCard {
                anchors.centerIn: parent
                u: root.u
                problems: root.allProblems
                lang: root.lang
                fontFamily: root.fTips
                fontText: root.fApps
                accent: root.accentColor
                reportText: Diag.report(root.lang, root.appVersion, Qt.version, root.allProblems)
                onCloseRequested: root.noticeDismissed = true
            }
        }

        // Menú contextual con estética Nothing
        Rectangle {
            id: ctxMenu
            z: 201
            visible: root.menuOpen
            width: root.u * 36
            height: Math.min(menuColumn.implicitHeight, root.height * 0.6) + root.u * 1.6
            x: Math.max(root.u, Math.min(root.menuX, root.width - width - root.u))
            y: Math.max(root.u, Math.min(root.menuY, root.height - height - root.u))
            radius: root.u * 2
            color: Qt.rgba(0, 0, 0, 0.92)
            border.width: Math.max(1, Math.round(root.u * 0.12))
            border.color: Qt.rgba(1, 1, 1, 0.18)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: root.u * 0.8
                contentHeight: menuColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: menuColumn
                    width: parent.width

                    Repeater {
                        model: root.menuActions
                        delegate: Item {
                            id: entry
                            required property var modelData
                            readonly property bool isSep: modelData.type === "separator"
                            readonly property bool isTitle: modelData.type === "title"
                            readonly property bool active: !isSep && !isTitle && (modelData.enabled ?? true)

                            width: menuColumn.width
                            height: isSep ? root.u * 1.2 : (isTitle ? root.u * 4 : root.u * 5)

                            Rectangle {
                                visible: entry.isSep
                                anchors.verticalCenter: parent.verticalCenter
                                x: root.u
                                width: parent.width - root.u * 2
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.15)
                            }

                            Rectangle {
                                visible: entry.active
                                anchors.fill: parent
                                radius: root.u * 1.2
                                color: Qt.rgba(0.843, 0.098, 0.098, itemMouse.containsMouse ? 0.5 : 0)
                            }

                            Kirigami.Icon {
                                visible: !entry.isSep && !entry.isTitle && source !== ""
                                x: root.u * 1.2
                                anchors.verticalCenter: parent.verticalCenter
                                width: root.u * 2.8
                                height: width
                                source: entry.modelData.icon ?? ""
                            }

                            Text {
                                visible: !entry.isSep
                                anchors.verticalCenter: parent.verticalCenter
                                x: entry.isTitle ? root.u * 1.2 : root.u * 5.2
                                width: parent.width - x - root.u * 1.2
                                text: entry.modelData.text ?? ""
                                elide: Text.ElideRight
                                color: entry.isTitle ? "#888888" : (entry.active ? "white" : "#666666")
                                font.family: root.fApps
                                font.pixelSize: entry.isTitle ? root.u * 1.7 : root.u * 2.1
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                enabled: entry.active
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.triggerMenuAction(entry.modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------- acciones
    function handleBackgroundClick() {
        if (outputLoader.item && outputLoader.item.open) {
            outputLoader.item.open = false;
        } else {
            dismiss();
        }
    }

    function handleEscape() {
        if (noticeVisible) {
            noticeDismissed = true;
        } else if (outputLoader.item && outputLoader.item.open) {
            outputLoader.item.open = false;
        } else if (menuOpen) {
            closeMenu();
        } else if (navZone !== "search") {
            navZone = "search";
        } else if (searching) {
            searchField.text = "";
        } else {
            dismiss();
        }
    }

    // Enter: abre la app cuyo nombre coincide exacto; si no hay, la primera del filtro
    function launchFirstResult() {
        if (!searching || filtered.count < 1) {
            return;
        }
        let pick = 0;
        for (let i = 0; i < filtered.count; ++i) {
            const name = String(filtered.data(filtered.index(i, 0), Qt.DisplayRole)).toLowerCase();
            if (name === query) {
                pick = i;
                break;
            }
        }
        launchFiltered(pick);
    }

    Component.onCompleted: updateAllApps()
}
