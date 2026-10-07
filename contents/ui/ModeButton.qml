import QtQuick
import "strings.js" as S

// Botón redondo con la letra M: cambia lo que se ve en la zona derecha
// (reproductor, tarjetas o nada). Usa el color y la opacidad de las tarjetas.
Item {
    id: btn

    property real u: 10
    property string lang: "en"
    property real size: 80
    property color baseColor: "#FFFFFF"
    property real baseOpacity: 0.30
    property color backdrop: "#000000"
    property color accent: "#D71921"
    property string fontFamily: ""
    property string tipFont: ""
    property int mode: 0            // modo actual: 0 reproductor, 1 tarjetas, 2 nada
    property bool typing: true
    property bool hoverFx: true
    signal next()

    width: size
    height: size

    readonly property color fill: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseOpacity)
    // Letra clara u oscura según lo claro que quede el botón sobre el fondo
    readonly property color ink: {
        const a = fill.a;
        const lum = 0.2126 * (fill.r * a + backdrop.r * (1 - a))
                  + 0.7152 * (fill.g * a + backdrop.g * (1 - a))
                  + 0.0722 * (fill.b * a + backdrop.b * (1 - a));
        return lum > 0.5 ? "#111111" : "#FFFFFF";
    }
    readonly property var names: [S.tr(lang, "Media player"), S.tr(lang, "Cards"), S.tr(lang, "Nothing")]
    readonly property string tipText: S.tr(lang, "Right area: %1 \u2192 %2", names[mode], names[(mode + 1) % 3])

    property bool tipOn: false
    property int typed: 0

    Rectangle {
        anchors.fill: parent
        radius: btn.size * 0.28
        color: btn.fill
        border.width: Math.max(1, Math.round(btn.u * 0.12))
        border.color: Qt.rgba(1, 1, 1, 0.2)
        scale: mouse.pressed ? 0.93 : (btn.hoverFx && mouse.containsMouse ? 1.07 : 1.0)
        Behavior on scale { NumberAnimation { duration: 90 } }

        Text {
            anchors.centerIn: parent
            text: "M"
            color: btn.ink
            font.family: btn.fontFamily
            font.pixelSize: btn.size * 0.46
        }
    }

    Timer { id: tipDelay; interval: 350; onTriggered: btn.tipOn = true }

    TextMetrics {
        id: tipMetrics
        text: btn.tipText
        font.family: btn.tipFont
        font.pixelSize: Math.max(12, Math.round(btn.size * 0.3))
    }

    NumberAnimation {
        id: typeAnim
        target: btn
        property: "typed"
        from: 1
        to: btn.tipText.length
        duration: Math.max(1, btn.tipText.length) * 26
    }

    onTipOnChanged: {
        if (tipOn) {
            typed = btn.typing ? 1 : btn.tipText.length;
            if (btn.typing) typeAnim.restart();
        } else {
            typeAnim.stop();
        }
    }

    Rectangle {
        z: 100
        opacity: btn.tipOn ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
        height: tipMetrics.height + btn.size * 0.4
        width: tipMetrics.width + btn.size * 0.6
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.9)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.25)
        // Encima del botón, sin salirse por la derecha
        y: -height - btn.size * 0.2
        x: btn.width - width

        Text {
            x: btn.size * 0.3
            anchors.verticalCenter: parent.verticalCenter
            text: btn.tipText.substring(0, btn.typed)
            color: "white"
            font: tipMetrics.font
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.next()
        onContainsMouseChanged: {
            if (containsMouse) {
                tipDelay.restart();
            } else {
                tipDelay.stop();
                btn.tipOn = false;
            }
        }
    }
}
