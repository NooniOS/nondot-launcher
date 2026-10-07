import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

// Selector de color sencillo: muestras predefinidas + código hexadecimal (#RRGGBB).
RowLayout {
    id: field

    property color value: "#000000"
    property var swatches: ["#000000", "#0A0A0A", "#1A1A1A", "#D71921", "#FFFFFF", "#0B1E3F", "#123524", "#2B1055"]

    spacing: 6

    onValueChanged: hex.text = String(value).toUpperCase().substring(0, 7)

    Repeater {
        model: field.swatches
        delegate: Rectangle {
            required property string modelData
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: 11
            color: modelData
            border.width: Qt.colorEqual(field.value, modelData) ? 3 : 1
            border.color: Qt.colorEqual(field.value, modelData) ? "#D71921" : "#808080"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: field.value = parent.color
            }
        }
    }

    Rectangle {
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
        radius: 3
        color: field.value
        border.width: 1
        border.color: "#808080"
    }

    QQC2.TextField {
        id: hex
        Layout.preferredWidth: 90
        maximumLength: 7
        text: String(field.value).toUpperCase().substring(0, 7)
        placeholderText: "#RRGGBB"
        onEditingFinished: {
            if (/^#[0-9a-fA-F]{6}$/.test(text)) {
                field.value = text;
            } else {
                text = String(field.value).toUpperCase().substring(0, 7);
            }
        }
    }
}
