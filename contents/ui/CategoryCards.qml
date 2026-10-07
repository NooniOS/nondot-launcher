import QtQuick
import "strings.js" as S

// Tarjetas de texto, una por categoría de apps, en una columna que se desplaza con la rueda.
// Con animaciones activas cada tarjeta asoma como una pestaña y, al pasar el cursor, se
// desliza para mostrar su nombre; sin animaciones son tarjetas fijas con el nombre visible.
Item {
    id: cards

    property real u: 10
    property string lang: "en"
    // [{ name, count }]
    property var categories: []
    property int selected: -1
    property bool animated: true
    // Nombres largos: deslizamiento permanente y sin pausas
    property bool cardsMarquee: true
    property color baseColor: "#FFFFFF"
    property real baseOpacity: 0.30
    // Color sobre el que se apoyan las tarjetas (para elegir texto claro u oscuro)
    property color backdrop: "#000000"
    property string fontFamily: ""
    property color accent: "#D71921"
    signal picked(int index)

    readonly property real rowH: u * 5.8
    readonly property real rowGap: u * 1.0
    readonly property real tabW: u * 3.8

    clip: true

    // Color de la tarjeta i: con animaciones activas, las contiguas varían de tono
    function toneColor(i) {
        const c = Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseOpacity);
        if (!animated) {
            return c;
        }
        // El color elegido se respeta tal cual; las tarjetas contiguas solo varían un poco de opacidad
        const f = [1.0, 0.8, 0.9, 0.7][i % 4];
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseOpacity * f);
    }

    // Texto blanco u oscuro según lo claro que quede el color de la tarjeta sobre el fondo
    function inkFor(c) {
        const r = c.r * c.a + backdrop.r * (1 - c.a);
        const g = c.g * c.a + backdrop.g * (1 - c.a);
        const b = c.b * c.a + backdrop.b * (1 - c.a);
        const lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        return lum > 0.5 ? "#111111" : "#FFFFFF";
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Column {
            id: col
            width: flick.width
            spacing: cards.rowGap

            Repeater {
                model: cards.categories

                delegate: Item {
                    id: row
                    required property int index
                    required property var modelData

                    property bool hovered: false
                    readonly property bool isSelected: cards.selected === index
                    readonly property bool open: !cards.animated || hovered || isSelected
                    readonly property color fill: cards.toneColor(index)
                    readonly property color ink: cards.inkFor(fill)

                    width: col.width
                    height: cards.rowH
                    clip: true

                    Rectangle {
                        id: card
                        width: row.width
                        height: row.height
                        x: row.open ? 0 : row.width - cards.tabW
                        radius: cards.u * 1.6
                        color: row.fill
                        border.width: Math.max(1, Math.round(cards.u * (row.isSelected ? 0.22 : 0.1)))
                        border.color: row.isSelected ? cards.accent : Qt.rgba(1, 1, 1, 0.2)

                        Behavior on x {
                            enabled: cards.animated
                            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                        }

                        // Pestaña: inicial de la categoría (solo con animaciones)
                        Text {
                            visible: cards.animated
                            x: 0
                            width: cards.tabW
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: row.modelData.name.charAt(0).toUpperCase()
                            color: row.ink
                            font.family: cards.fontFamily
                            font.pixelSize: cards.u * 2.6
                        }

                        MarqueeText {
                            x: cards.animated ? cards.tabW : cards.u * 2.4
                            width: parent.width - x - cards.u * 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.name
                            color: row.ink
                            fontFamily: cards.fontFamily
                            pixelSize: cards.u * 2.4
                            mode: cards.cardsMarquee ? 2 : 0
                            pause: 0
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: cards.u * 2
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.count
                            color: row.ink
                            opacity: 0.6
                            font.family: cards.fontFamily
                            font.pixelSize: cards.u * 1.9
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: row.hovered = containsMouse
                            onClicked: cards.picked(row.index)
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: cards.categories.length === 0
        text: S.tr(cards.lang, "No categories")
        color: "#555555"
        font.family: cards.fontFamily
        font.pixelSize: cards.u * 2.6
    }
}
