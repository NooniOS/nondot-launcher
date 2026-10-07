import QtQuick

// Botón redondo con un símbolo de texto (<, ||, >) escrito con la fuente elegida.
Item {
    id: btn

    property string glyph: ""
    property real size: 50
    property string fontFamily: ""
    property color glyphColor: "white"
    property color ink: "white"
    property color accent: "#D71921"
    property bool animated: true
    signal clicked()

    width: size
    height: size
    opacity: enabled ? 1 : 0.35

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, mouse.containsMouse && btn.enabled ? 0.5 : 0.0)
        border.width: Math.max(1, Math.round(btn.size * 0.03))
        border.color: Qt.rgba(btn.ink.r, btn.ink.g, btn.ink.b, 0.35)
        scale: btn.animated && mouse.pressed ? 0.93 : 1.0
        Behavior on scale { NumberAnimation { duration: btn.animated ? 90 : 0 } }
        Behavior on color { ColorAnimation { duration: btn.animated ? 120 : 0 } }

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            color: btn.glyphColor
            font.family: btn.fontFamily
            font.pixelSize: btn.size * 0.46
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (btn.enabled) btn.clicked()
    }
}
