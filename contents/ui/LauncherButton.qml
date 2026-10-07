import QtQuick
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import "diag.js" as Diag
import "strings.js" as S

Item {
    id: root

    // El PlasmoidItem (lo pasa main.qml); los modelos de Kicker lo necesitan
    property var applet: null
    readonly property string version: "1.0.0"
    readonly property string lang: Plasmoid.configuration.language

    property var dashWindow: null
    property var modelsItem: null
    // Fallos de carga que impiden abrir el lanzador (se muestran en ErrorWindow)
    property var problems: []
    property var errorWindow: null

    // Modelos que crea AppModels.qml y que se pasan a la ventana
    property var rootModel: null
    property var popularModel: null
    property var recentModel: null
    property var runnerModel: null

    // true mientras esperamos la respuesta de KWin sobre el monitor activo
    property bool awaitingActiveOutput: false
    property double queryStartedAt: 0

    // KWin exporta activeOutputName() en /KWin (interfaz org.kde.KWin)
    readonly property string activeOutputCommand:
        "busctl --user call org.kde.KWin /KWin org.kde.KWin activeOutputName"

    // Pantalla (de Qt.application.screens) que contiene el punto global (x, y).
    // Los elementos de esa lista exponen name, virtualX, virtualY, width y height.
    function screenAt(x, y) {
        const screens = Qt.application.screens;
        for (let i = 0; i < screens.length; ++i) {
            const s = screens[i];
            if (x >= s.virtualX && x < s.virtualX + s.width
                    && y >= s.virtualY && y < s.virtualY + s.height) {
                return s;
            }
        }
        return null;
    }

    function screenByName(name) {
        const screens = Qt.application.screens;
        for (let i = 0; i < screens.length; ++i) {
            if (screens[i].name === name) {
                return screens[i];
            }
        }
        return null;
    }

    // Pantalla donde está este widget (la usa el clic y el respaldo de Meta)
    function widgetScreen() {
        try {
            const p = root.mapToGlobal(root.width / 2, root.height / 2);
            const byPos = screenAt(p.x, p.y);
            if (byPos) {
                return byPos;
            }
        } catch (e) {
            console.warn("NonDotLauncher: could not detect the widget screen: " + e);
        }
        return root.Window.window ? root.Window.window.screen : null;
    }

    function openOn(target, origin) {
        dashWindow.targetScreen = target;
        dashWindow.toggle();
    }

    // Ventana de aviso: se usa cuando el lanzador ni siquiera pudo crearse
    function showErrorWindow() {
        const report = Diag.report(lang, version, Qt.version, problems);
        console.warn("NonDotLauncher:\n" + report);
        if (errorWindow) {
            errorWindow.lang = lang;
            errorWindow.problems = problems;
            errorWindow.reportText = report;
            errorWindow.show();
            errorWindow.raise();
            return;
        }
        const c = Qt.createComponent(Qt.resolvedUrl("./ErrorWindow.qml"));
        if (c.status === Component.Ready) {
            errorWindow = c.createObject(null, { problems: problems, reportText: report, lang: lang });
            errorWindow.show();
        } else {
            console.warn("NonDotLauncher: could not create the notice window: " + c.errorString());
        }
    }

    // Carga un archivo QML y devuelve su mensaje de error técnico ("" si carga bien)
    function loadError(file) {
        const c = Qt.createComponent(Qt.resolvedUrl(file));
        return c.status === Component.Error ? c.errorString() : "";
    }

    function toggleDash(origin) {
        if (!dashWindow) {
            showErrorWindow();
            return;
        }

        // Cerrar: no hace falta saber la pantalla
        if (dashWindow.visible) {
            dashWindow.toggle();
            return;
        }

        if (origin === "activated") {
            // Atajo (Meta): abrir en el monitor activo según KWin
            awaitingActiveOutput = true;
            queryStartedAt = Date.now();
            activeOutputQuery.connectSource(activeOutputCommand);
            queryTimeout.restart();
        } else {
            // Clic: abrir en el monitor del propio widget
            openOn(widgetScreen(), origin);
        }
    }

    function handleActiveOutput(stdout, exitCode) {
        if (!awaitingActiveOutput) {
            return;
        }
        awaitingActiveOutput = false;
        queryTimeout.stop();

        // La salida de busctl tiene la forma:  s "DP-2"
        const m = /"([^"]+)"/.exec(stdout || "");
        const name = m ? m[1] : "";
        const target = name !== "" ? screenByName(name) : null;

        openOn(target ? target : widgetScreen(), target ? "activated/KWin" : "activated/respaldo");
    }

    P5Support.DataSource {
        id: activeOutputQuery
        engine: "executable"

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            root.handleActiveOutput(data["stdout"], data["exit code"]);
        }
    }

    // Si KWin no responde a tiempo, se abre en el monitor del widget
    Timer {
        id: queryTimeout
        interval: 800
        onTriggered: {
            if (root.awaitingActiveOutput) {
                activeOutputQuery.disconnectSource(root.activeOutputCommand);
                root.handleActiveOutput("", "timeout");
            }
        }
    }

    Component.onCompleted: {
        // 0) Modelos de datos (módulo privado de Kicker). Si fallan no se puede abrir el lanzador.
        const mc = Qt.createComponent(Qt.resolvedUrl("./AppModels.qml"));
        if (mc.status === Component.Ready) {
            modelsItem = mc.createObject(root, { applet: root.applet });
        }
        if (modelsItem) {
            rootModel = modelsItem.appsModel;
            popularModel = modelsItem.popularModel;
            recentModel = modelsItem.recentModel;
            runnerModel = modelsItem.runnerModel;
        } else {
            const err = mc.status === Component.Error ? mc.errorString() : S.tr(lang, "Could not create the models object.");
            problems = problems.concat([Diag.describe(lang, "models", S.tr(lang, "App list"), err,
                                                     "")]);
            return;
        }

        // 1) Crear la ventana. Se crea SIN padre visual para que Qt
        //    no la convierta en ventana hija (transient) de la del panel.
        const comp = Qt.createComponent(Qt.resolvedUrl("./Dashboard.qml"));
        if (comp.status === Component.Ready) {
            dashWindow = comp.createObject(null, {
                rootModel: root.rootModel,
                popularModel: root.popularModel,
                recentModel: root.recentModel,
                runnerModel: root.runnerModel,
                applet: root.applet
            });
        }
        if (dashWindow) {
            // Ajustes del plasmoid -> ventana (se actualizan en vivo)
            const w = dashWindow;
            w.lang = Qt.binding(() => Plasmoid.configuration.language);
            w.bgColor = Qt.binding(() => Plasmoid.configuration.bgColor);
            w.bgOpacity = Qt.binding(() => Plasmoid.configuration.bgOpacityPct / 100);
            w.bubbleAlpha = Qt.binding(() => Plasmoid.configuration.bubbleOpacityPct / 100);
            w.bubbleColor = Qt.binding(() => Plasmoid.configuration.bubbleColor);
            w.accentColor = Qt.binding(() => Plasmoid.configuration.accentColor);
            w.use24Hour = Qt.binding(() => Plasmoid.configuration.use24Hour);
            w.dateStyle = Qt.binding(() => Plasmoid.configuration.dateStyle);
            w.rightPanel = Qt.binding(() => Plasmoid.configuration.rightPanel);
            w.cardColor = Qt.binding(() => Plasmoid.configuration.cardColor);
            w.cardOpacity = Qt.binding(() => Plasmoid.configuration.cardOpacityPct / 100);
            w.fontCardsName = Qt.binding(() => Plasmoid.configuration.fontCards);
            w.showTaskbar = Qt.binding(() => Plasmoid.configuration.showTaskbar);
            w.showSeconds = Qt.binding(() => Plasmoid.configuration.showSeconds);
            w.animations = Qt.binding(() => Plasmoid.configuration.animations);
            w.animFade = Qt.binding(() => Plasmoid.configuration.animFade);
            w.animClock = Qt.binding(() => Plasmoid.configuration.animClock);
            w.animTyping = Qt.binding(() => Plasmoid.configuration.animTyping);
            w.animFilter = Qt.binding(() => Plasmoid.configuration.animFilter);
            w.animHover = Qt.binding(() => Plasmoid.configuration.animHover);
            w.marqueeMode = Qt.binding(() => Plasmoid.configuration.marqueeMode);
            w.animCardsMarquee = Qt.binding(() => Plasmoid.configuration.animCardsMarquee);
            w.rightPanelRequested.connect(mode => { Plasmoid.configuration.rightPanel = mode; });
            w.fontClockName = Qt.binding(() => Plasmoid.configuration.fontClock);
            w.fontSearchName = Qt.binding(() => Plasmoid.configuration.fontSearch);
            w.fontAppsName = Qt.binding(() => Plasmoid.configuration.fontApps);
            w.fontTipsName = Qt.binding(() => Plasmoid.configuration.fontTips);
            w.fontMediaName = Qt.binding(() => Plasmoid.configuration.fontMedia);
            w.appVersion = root.version;
        } else {
            const err2 = comp.status === Component.Error ? comp.errorString() : S.tr(lang, "Could not create the window.");
            problems = problems.concat([Diag.describe(lang, "dashboard", S.tr(lang, "Launcher window"), err2, "")]);
        }
    }

    Component.onDestruction: {
        if (dashWindow) {
            dashWindow.destroy();
        }
        if (errorWindow) {
            errorWindow.destroy();
        }
    }

    Kirigami.Icon {
        anchors.fill: parent
        source: Plasmoid.icon
        active: mouseArea.containsMouse
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggleDash("clic")
    }

    // Se emite cuando Plasma activa el lanzador (atajo global)
    Connections {
        target: Plasmoid

        function onActivated() {
            root.toggleDash("activated");
        }
    }
}
