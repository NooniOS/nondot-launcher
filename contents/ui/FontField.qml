import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "strings.js" as S

// Selector de fuente. En vez de un ComboBox con cientos de entradas (que congelaba la
// página al abrirla) usa un botón que abre una lista con buscador; la lista solo se
// construye al abrirla y solo dibuja las filas visibles.
ColumnLayout {
    id: field

    // Nombre de la familia elegida; "" = la fuente del sistema
    property string value: ""
    property string lang: "en"
    property string defaultLabel: S.tr(lang, "System default")
    // Lo pasa la página: se carga una sola vez para todos los selectores
    property var families: []
    // true si el sistema no pudo dar la lista: se escribe el nombre a mano
    property bool manual: false

    readonly property bool missing: value !== "" && families.length > 0 && families.indexOf(value) < 0

    spacing: Kirigami.Units.smallSpacing

    QQC2.Button {
        id: pick
        visible: !field.manual
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        text: field.value === "" ? field.defaultLabel : field.value
        icon.name: "preferences-desktop-font"
        onClicked: popup.openFor()
    }

    QQC2.TextField {
        visible: field.manual
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        text: field.value
        placeholderText: field.defaultLabel
        onEditingFinished: field.value = text.trim()
    }

    QQC2.Label {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        text: S.tr(field.lang, "Preview: Aa Bb 0123 Ññ Áé 12:34 PM")
        font.family: field.value
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.3
        elide: Text.ElideRight
        visible: field.value !== ""
    }

    QQC2.Label {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        visible: field.missing
        wrapMode: Text.WordWrap
        color: Kirigami.Theme.negativeTextColor
        text: S.tr(field.lang, "This font is not installed: the launcher will use the system font until you install it.")
    }

    QQC2.Popup {
        id: popup
        parent: pick
        y: pick.height
        width: Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 18
        padding: Kirigami.Units.smallSpacing
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

        // "" = la fuente incluida; el resto, las familias que coinciden con la búsqueda
        property var matches: [""]

        function refresh() {
            const q = search.text.trim().toLowerCase();
            const out = [""];
            const all = field.families;
            for (let i = 0; i < all.length; ++i) {
                if (q === "" || all[i].toLowerCase().indexOf(q) >= 0) {
                    out.push(all[i]);
                }
            }
            matches = out;
        }

        function openFor() {
            search.text = "";
            refresh();
            open();
            search.forceActiveFocus();
        }

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: S.tr(field.lang, "Search font…")
                onTextChanged: popup.refresh()
            }

            ListView {
                id: fontList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: popup.matches
                boundsBehavior: Flickable.StopAtBounds
                QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

                delegate: QQC2.ItemDelegate {
                    required property var modelData
                    width: ListView.view.width
                    text: modelData === "" ? field.defaultLabel : modelData
                    highlighted: modelData === field.value
                    onClicked: {
                        field.value = modelData;
                        popup.close();
                    }
                }
            }
        }
    }
}
