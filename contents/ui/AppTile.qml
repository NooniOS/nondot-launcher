import QtQuick
import org.kde.kirigami as Kirigami

// Una app: icono del tema del sistema + nombre. En modo lista va en horizontal.
Item {
    id: tile

    property string label: ""
    property var iconSource: ""
    property bool listMode: false
    property real u: 10
    property string fontFamily: ""
    // Seleccionada con el teclado (flechas)
    property bool selected: false
    property color accent: "#D71921"
    property color ink: "white"
    signal clicked()
    signal rightClicked(real sceneX, real sceneY)

    Rectangle {
        anchors.fill: parent
        anchors.margins: tile.u * 0.4
        radius: tile.u * 1.6
        color: Qt.rgba(tile.ink.r, tile.ink.g, tile.ink.b, mouse.pressed ? 0.16 : (mouse.containsMouse || tile.selected ? 0.10 : 0))
        border.width: tile.selected ? Math.max(1, Math.round(tile.u * 0.2)) : 0
        border.color: tile.accent
    }

    Kirigami.Icon {
        id: icon
        width: tile.u * (tile.listMode ? 6 : 7.8)
        height: width
        source: tile.iconSource
        x: tile.listMode ? tile.u * 1.6 : (tile.width - width) / 2
        y: tile.listMode ? (tile.height - height) / 2 : tile.u * 1.1
    }

    Text {
        id: name
        text: tile.label
        color: tile.ink
        font.family: tile.fontFamily
        font.pixelSize: Math.max(11, Math.round(tile.u * (tile.listMode ? 2.3 : 1.8)))
        elide: Text.ElideRight
        maximumLineCount: tile.listMode ? 1 : 2
        wrapMode: tile.listMode ? Text.NoWrap : Text.Wrap
        horizontalAlignment: tile.listMode ? Text.AlignLeft : Text.AlignHCenter
        x: tile.listMode ? icon.x + icon.width + tile.u * 1.8 : tile.width * 0.06
        width: tile.listMode ? tile.width - x - tile.u * 1.5 : tile.width * 0.88
        y: tile.listMode ? (tile.height - height) / 2 : icon.y + icon.height + tile.u * 0.6
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                const p = tile.mapToItem(null, mouse.x, mouse.y);
                tile.rightClicked(p.x, p.y);
            } else {
                tile.clicked();
            }
        }
    }
}
