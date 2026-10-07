import QtQuick

// Burbuja del estilo Nothing: negro translúcido con borde fino blanco.
Rectangle {
    id: bubble

    property real u: 10   // unidad relativa (1 % del alto de la pantalla)
    property real alpha: 0.60
    property color tint: "#000000"   // color de la cuadrícula

    color: Qt.rgba(tint.r, tint.g, tint.b, alpha)
    radius: u * 2.4
    border.width: Math.max(1, Math.round(u * 0.12))
    border.color: Qt.rgba(1, 1, 1, 0.12)

    // Evita que un clic dentro de la burbuja llegue al fondo y cierre el lanzador
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = false
    }
}
