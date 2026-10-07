import QtQuick
import "strings.js" as S

// Tarjeta de avisos con la estética del lanzador.
// Dice qué falló, qué falta y si hay que instalar algo o esperar una actualización.
Rectangle {
    id: card

    property var problems: []
    property real u: 10
    property string fontFamily: ""
    property string fontText: ""
    property color accent: "#D71921"
    property string reportText: ""
    property string lang: "en"
    signal closeRequested()

    width: u * 62
    height: Math.min(parent ? parent.height * 0.86 : u * 70,
                     header.height + list.contentHeight + footer.height + u * 5)
    radius: u * 2.4
    color: Qt.rgba(0, 0, 0, 0.94)
    border.width: Math.max(1, Math.round(u * 0.14))
    border.color: Qt.rgba(accent.r, accent.g, accent.b, 0.8)

    // Impide que los clics lleguen al fondo
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = false
    }

    // Texto oculto para copiar el informe al portapapeles
    TextEdit {
        id: clip
        visible: false
        text: card.reportText
    }

    Item {
        id: header
        x: card.u * 2.4
        y: card.u * 2
        width: card.width - card.u * 4.8
        height: card.u * 7

        Rectangle {
            id: dot
            width: card.u * 1.6
            height: width
            radius: width / 2
            color: card.accent
            anchors.verticalCenter: title.verticalCenter
        }
        Text {
            id: title
            x: dot.width + card.u * 1.2
            text: S.tr(card.lang, "Something isn't working as it should")
            color: "white"
            font.family: card.fontFamily
            font.pixelSize: card.u * 3
        }
        Text {
            anchors.top: title.bottom
            anchors.topMargin: card.u * 0.6
            x: dot.width + card.u * 1.2
            width: parent.width - x
            text: S.tr(card.lang, "The rest of the launcher keeps working.")
            color: "#999999"
            font.family: card.fontText
            font.pixelSize: card.u * 1.9
            elide: Text.ElideRight
        }
    }

    Flickable {
        id: list
        x: card.u * 2.4
        y: header.y + header.height
        width: card.width - card.u * 4.8
        height: card.height - header.height - footer.height - card.u * 4
        clip: true
        contentHeight: listCol.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: listCol
            width: list.width
            spacing: card.u * 1.6

            Repeater {
                model: card.problems

                delegate: Rectangle {
                    id: item
                    required property var modelData
                    width: listCol.width
                    height: body.implicitHeight + card.u * 2.4
                    radius: card.u * 1.6
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)

                    Column {
                        id: body
                        x: card.u * 1.6
                        y: card.u * 1.2
                        width: item.width - card.u * 3.2
                        spacing: card.u * 0.7

                        Text {
                            width: parent.width
                            text: (item.modelData.severity === "error" ? "● " : "○ ") + item.modelData.title
                            color: item.modelData.severity === "error" ? card.accent : "#E0B000"
                            font.family: card.fontFamily
                            font.pixelSize: card.u * 2.3
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            width: parent.width
                            text: item.modelData.what
                            color: "white"
                            font.family: card.fontText
                            font.pixelSize: card.u * 1.9
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            width: parent.width
                            text: S.tr(card.lang, "What to do: %1", item.modelData.todo)
                            color: "#CCCCCC"
                            font.family: card.fontText
                            font.pixelSize: card.u * 1.9
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            width: parent.width
                            visible: item.modelData.detail !== ""
                            text: item.modelData.detail
                            color: "#777777"
                            font.pixelSize: card.u * 1.4
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    Row {
        id: footer
        anchors.right: parent.right
        anchors.rightMargin: card.u * 2.4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: card.u * 2
        spacing: card.u * 1.4
        height: card.u * 5.4

        Repeater {
            model: [
                { label: S.tr(card.lang, "Copy report"), copy: true },
                { label: S.tr(card.lang, "Got it"), copy: false }
            ]

            delegate: Rectangle {
                id: btn
                required property var modelData
                property bool copied: false
                width: label.implicitWidth + card.u * 4
                height: card.u * 5.4
                radius: height / 2
                color: Qt.rgba(card.accent.r, card.accent.g, card.accent.b,
                               btnMouse.containsMouse ? 0.55 : (modelData.copy ? 0 : 0.3))
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.3)

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: btn.copied ? S.tr(card.lang, "Copied") : btn.modelData.label
                    color: "white"
                    font.family: card.fontFamily
                    font.pixelSize: card.u * 2
                }
                Timer { id: resetCopied; interval: 1500; onTriggered: btn.copied = false }
                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (btn.modelData.copy) {
                            clip.selectAll();
                            clip.copy();
                            btn.copied = true;
                            resetCopied.restart();
                        } else {
                            card.closeRequested();
                        }
                    }
                }
            }
        }
    }
}
