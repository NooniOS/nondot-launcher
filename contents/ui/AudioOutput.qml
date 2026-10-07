/*
    Salida de audio: muestra cuál está activa (altavoces, bluetooth, HDMI...) y permite
    cambiarla. Usa el módulo de audio de Plasma (org.kde.plasma.private.volume), el mismo
    del widget de volumen de KDE.
*/
import QtQuick
import org.kde.plasma.private.volume
import "strings.js" as S

Item {
    id: out

    property real u: 10
    property string lang: "en"
    property color tint: "#000000"
    property color ink: "white"
    property real alpha: 0.6
    property string fontFamily: ""
    property color accent: "#D71921"
    // Lista desplegada
    property bool open: false

    implicitHeight: u * 7.4

    SinkModel { id: sinks }

    readonly property var current: PreferredDevice.sink
    readonly property string currentName: current ? (current.description ?? "") : ""

    function kindOf(name) {
        const n = String(name || "").toLowerCase();
        if (n.indexOf("bluez") >= 0) {
            return "BLUETOOTH";
        }
        if (n.indexOf("hdmi") >= 0 || n.indexOf("displayport") >= 0) {
            return "HDMI";
        }
        if (n.indexOf("usb") >= 0) {
            return "USB";
        }
        if (n.indexOf("analog") >= 0) {
            return S.tr(out.lang, "ANALOG");
        }
        return S.tr(out.lang, "OUTPUT");
    }

    Bubble {

        tint: out.tint
        id: bar
        anchors.fill: parent
        alpha: out.alpha
        u: out.u

        Column {
            anchors.verticalCenter: parent.verticalCenter
            x: out.u * 2
            width: parent.width - out.u * 6.5
            spacing: out.u * 0.3

            Text {
                width: parent.width
                text: S.tr(out.lang, "AUDIO OUTPUT · %1", out.kindOf(out.current ? out.current.name : ""))
                color: Qt.rgba(out.ink.r, out.ink.g, out.ink.b, 0.55)
                font.family: out.fontFamily
                font.pixelSize: out.u * 1.5
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: out.currentName !== "" ? out.currentName : S.tr(out.lang, "No audio output")
                color: out.ink
                font.family: out.fontFamily
                font.pixelSize: out.u * 2
                elide: Text.ElideRight
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: out.u * 2
            anchors.verticalCenter: parent.verticalCenter
            text: out.open ? "▲" : "▼"
            color: out.accent
            font.pixelSize: out.u * 1.8
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: out.open = !out.open
        }
    }

    // Lista de salidas, justo debajo
    Rectangle {
        id: popup
        visible: out.open
        z: 50
        // Se abre hacia arriba para no salirse de la pantalla
        y: -height - out.u * 0.8
        width: out.width
        height: Math.min(listView.contentHeight, out.u * 18) + out.u * 1.6
        radius: out.u * 2
        color: Qt.rgba(out.tint.r, out.tint.g, out.tint.b, 0.94)
        border.width: Math.max(1, Math.round(out.u * 0.12))
        border.color: Qt.rgba(out.ink.r, out.ink.g, out.ink.b, 0.18)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onWheel: wheel => wheel.accepted = false
        }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: out.u * 0.8
            clip: true
            model: sinks
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: row
                // "auto_null" es la salida vacía que aparece sin dispositivos
                readonly property bool hidden: model.Name === "auto_null"
                readonly property bool isDefault: model.PulseObject ? model.PulseObject.default : false
                width: listView.width
                height: hidden ? 0 : out.u * 5.6
                visible: !hidden

                Rectangle {
                    anchors.fill: parent
                    radius: out.u * 1.2
                    color: Qt.rgba(out.accent.r, out.accent.g, out.accent.b,
                                   rowMouse.containsMouse ? 0.5 : (row.isDefault ? 0.25 : 0))
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: out.u * 1.2
                    width: parent.width - out.u * 2.4
                    text: (row.isDefault ? "● " : "") + model.Description
                    color: out.ink
                    font.family: out.fontFamily
                    font.pixelSize: out.u * 1.9
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (model.PulseObject) {
                            model.PulseObject.default = true;
                        }
                        out.open = false;
                    }
                }
            }
        }
    }
}
