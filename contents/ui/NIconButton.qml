import QtQuick

// Botón redondo que usa uno de los iconos SVG del paquete (icons/<nombre>.svg).
// Los iconos ya traen su círculo y su acento rojo, así que no se tiñen.
// Si tiene toolTip, al pasar el cursor muestra una ventanita flotante con ese texto.
Item {
    id: btn

    property string iconName: ""
    property real size: 60
    property string toolTip: ""
    property string tipSide: "right"      // "right" o "left" del botón
    property string fontFamily: ""
    property bool typing: true      // el texto se escribe letra a letra
    property bool hoverFx: true     // efecto de escala al pasar el cursor
    signal clicked()

    width: size
    height: size

    Image {
        id: img
        anchors.centerIn: parent
        width: btn.size
        height: btn.size
        source: btn.iconName !== "" ? "icons/" + btn.iconName + ".svg" : ""
        sourceSize: Qt.size(256, 256)
        smooth: true
        mipmap: true
        scale: !btn.hoverFx ? 1.0 : (mouse.pressed ? 0.93 : (mouse.containsMouse ? 1.07 : 1.0))
        Behavior on scale { NumberAnimation { duration: btn.hoverFx ? 90 : 0 } }
    }

    property bool tipOn: false
    property int typed: 0

    Timer {
        id: tipDelay
        interval: 350
        onTriggered: btn.tipOn = true
    }

    // Mide el texto completo para que la burbuja no cambie de tamaño mientras se "escribe"
    TextMetrics {
        id: tipMetrics
        text: btn.toolTip
        font.family: btn.fontFamily
        font.pixelSize: Math.max(12, Math.round(btn.size * 0.3))
    }

    NumberAnimation {
        id: typeAnim
        target: btn
        property: "typed"
        from: 1
        to: btn.toolTip.length
        duration: Math.max(1, btn.toolTip.length) * 26
    }

    onTipOnChanged: {
        if (tipOn) {
            if (typing) {
                typed = 1;
                typeAnim.restart();
            } else {
                typed = toolTip.length;
            }
        } else {
            typeAnim.stop();
        }
    }

    Rectangle {
        id: tip
        z: 100
        opacity: btn.tipOn && btn.toolTip !== "" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: btn.typing || btn.hoverFx ? 120 : 0 } }
        height: tipMetrics.height + btn.size * 0.4
        width: tipMetrics.width + btn.size * 0.6
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.9)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.25)
        anchors.verticalCenter: parent.verticalCenter
        x: btn.tipSide === "left" ? -width - btn.size * 0.2 : btn.width + btn.size * 0.2

        Text {
            x: btn.size * 0.3
            anchors.verticalCenter: parent.verticalCenter
            text: btn.toolTip.substring(0, btn.typed)
            color: "white"
            font: tipMetrics.font
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
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
