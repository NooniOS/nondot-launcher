import QtQuick

// Texto de una sola línea. Si no cabe, se corta con «…» o se desliza como un carrusel,
// según "mode": 0 = quieto, 1 = al pasar el cursor, 2 = siempre.
Item {
    id: m

    property string text: ""
    property color color: "white"
    property string fontFamily: ""
    property real pixelSize: 20
    property int mode: 1
    // Lo pone quien lo contiene (por ejemplo, un HoverHandler sobre toda la tarjeta)
    property bool hovered: false
    // Velocidad en píxeles por segundo y separación entre vuelta y vuelta
    property real speed: pixelSize * 3
    property real gap: pixelSize * 2
    property int align: Text.AlignLeft
    // Pausa antes de cada vuelta (0 = deslizamiento continuo, sin pausas)
    property int pause: 800

    clip: true
    implicitHeight: metrics.height
    height: implicitHeight

    readonly property real textW: metrics.advanceWidth
    readonly property bool overflow: textW > width + 1
    readonly property bool scrolling: overflow && (mode === 2 || (mode === 1 && hovered))
    property real offset: 0

    TextMetrics {
        id: metrics
        text: m.text
        font.family: m.fontFamily
        font.pixelSize: m.pixelSize
    }

    // Reposo: texto fijo (cortado con «…» si no cabe)
    Text {
        visible: !m.scrolling
        width: parent.width
        text: m.text
        color: m.color
        font.family: m.fontFamily
        font.pixelSize: m.pixelSize
        elide: Text.ElideRight
        horizontalAlignment: m.align
    }

    // Carrusel: dos copias seguidas que avanzan hacia la izquierda
    Item {
        visible: m.scrolling
        width: parent.width
        height: parent.height

        Text {
            x: -m.offset
            text: m.text
            color: m.color
            font.family: m.fontFamily
            font.pixelSize: m.pixelSize
        }
        Text {
            x: -m.offset + m.textW + m.gap
            text: m.text
            color: m.color
            font.family: m.fontFamily
            font.pixelSize: m.pixelSize
        }
    }

    SequentialAnimation {
        running: m.scrolling
        loops: Animation.Infinite
        PauseAnimation { duration: m.pause }
        NumberAnimation {
            target: m
            property: "offset"
            from: 0
            to: m.textW + m.gap
            duration: Math.max(1, (m.textW + m.gap) / m.speed * 1000)
        }
    }

    onScrollingChanged: if (!scrolling) offset = 0
    onTextChanged: offset = 0
}
