import QtQuick

// Rejilla (o lista) desplazable con la rueda del ratón.
GridView {
    id: view

    property real u: 10
    property bool listMode: false
    property int fixedColumns: 6
    property real rowHeight: u * 14
    property string fontFamily: ""
    property bool animated: true
    // true mientras se navega con las flechas del teclado
    property bool showCurrent: false
    property color accent: "#D71921"
    property color ink: "white"
    signal launch(int index)
    signal context(int index, real sceneX, real sceneY)

    readonly property int columns: listMode ? 1 : fixedColumns

    onCurrentIndexChanged: if (currentIndex >= 0) positionViewAtIndex(currentIndex, GridView.Contain)

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.VerticalFlick
    cellWidth: width / columns
    cellHeight: listMode ? rowHeight * 0.6 : rowHeight
    // Una rueda "normal" mueve ~3 filas
    flickDeceleration: 3000
    maximumFlickVelocity: 4000

    // Las apps que entran se desvanecen hacia dentro; las que se filtran, hacia fuera
    // Con las animaciones apagadas NO se usa ninguna transición (null): una transición de
    // duración 0 deja elementos huérfanos en la cuadrícula al filtrar o cambiar de vista.
    add: view.animated ? addTransition : null
    remove: view.animated ? removeTransition : null
    displaced: view.animated ? displacedTransition : null

    Transition {
        id: addTransition
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
    }
    Transition {
        id: removeTransition
        NumberAnimation { property: "opacity"; to: 0; duration: 140 }
    }
    Transition {
        id: displacedTransition
        NumberAnimation { properties: "x,y"; duration: 180; easing.type: Easing.OutCubic }
    }

    delegate: AppTile {
        required property int index
        required property string display
        required property var decoration

        width: view.cellWidth
        height: view.cellHeight
        u: view.u
        label: display
        iconSource: decoration
        listMode: view.listMode
        selected: view.showCurrent && GridView.isCurrentItem
        accent: view.accent
        ink: view.ink
        fontFamily: view.fontFamily
        onClicked: view.launch(index)
        onRightClicked: (sx, sy) => view.context(index, sx, sy)
    }
}
