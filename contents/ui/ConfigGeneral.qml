import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import "strings.js" as S

KCM.SimpleKCM {
    id: page

    // Idioma elegido en los ajustes (se actualiza al pulsar Aplicar en la página Idioma)
    readonly property string lang: Plasmoid.configuration.language

    property alias cfg_bgOpacityPct: bgOpacity.value
    property alias cfg_bubbleOpacityPct: bubbleOpacity.value
    property alias cfg_bgColor: bgColorField.value
    property alias cfg_bubbleColor: bubbleColorField.value
    property alias cfg_accentColor: accentField.value
    property alias cfg_use24Hour: hour24.checked
    property alias cfg_dateStyle: dateStyle.currentIndex
    property alias cfg_showTaskbar: showTaskbar.checked
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_cardColor: cardColorField.value
    property alias cfg_cardOpacityPct: cardOpacity.value

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Background")
        }

        RowLayout {
            Kirigami.FormData.label: S.tr(page.lang, "Background opacity:")
            QQC2.Slider {
                id: bgOpacity
                from: 0
                to: 100
                stepSize: 1
                Layout.preferredWidth: Kirigami.Units.gridUnit * 12
            }
            QQC2.SpinBox {
                from: 0
                to: 100
                stepSize: 1
                editable: true
                value: Math.round(bgOpacity.value)
                onValueModified: bgOpacity.value = value
            }
            QQC2.Label { text: "%" }
        }

        ColorField {
            id: bgColorField
            Kirigami.FormData.label: S.tr(page.lang, "Background color:")
        }

        ColorField {
            id: bubbleColorField
            Kirigami.FormData.label: S.tr(page.lang, "Grid color:")
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 26
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: S.tr(page.lang, "Grid text becomes light or dark automatically depending on its color.")
        }

        RowLayout {
            Kirigami.FormData.label: S.tr(page.lang, "Grid opacity:")
            QQC2.Slider {
                id: bubbleOpacity
                from: 0
                to: 100
                stepSize: 1
                Layout.preferredWidth: Kirigami.Units.gridUnit * 12
            }
            QQC2.SpinBox {
                from: 0
                to: 100
                stepSize: 1
                editable: true
                value: Math.round(bubbleOpacity.value)
                onValueModified: bubbleOpacity.value = value
            }
            QQC2.Label { text: "%" }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Active apps")
        }

        QQC2.CheckBox {
            id: showTaskbar
            Kirigami.FormData.label: S.tr(page.lang, "Bar:")
            text: S.tr(page.lang, "Show the active apps bar")
        }

        ColorField {
            id: accentField
            Kirigami.FormData.label: S.tr(page.lang, "Accent color:")
            value: "#D71921"
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Cards and M button")
        }

        ColorField {
            id: cardColorField
            Kirigami.FormData.label: S.tr(page.lang, "Color:")
            value: "#FFFFFF"
            swatches: ["#FFFFFF", "#D71921", "#8AB4F8", "#81C995", "#FDD663", "#F28B82", "#C58AF9", "#808080"]
        }

        RowLayout {
            Kirigami.FormData.label: S.tr(page.lang, "Opacity:")
            QQC2.Slider {
                id: cardOpacity
                from: 0
                to: 100
                stepSize: 1
                Layout.preferredWidth: Kirigami.Units.gridUnit * 12
            }
            QQC2.SpinBox {
                from: 0
                to: 100
                stepSize: 1
                editable: true
                value: Math.round(cardOpacity.value)
                onValueModified: cardOpacity.value = value
            }
            QQC2.Label { text: "%" }
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 26
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: S.tr(page.lang, "This color and opacity apply to the category cards and to the M button. If the cards are not active, they only affect the button. The text turns light or dark automatically depending on the color.")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Date and time")
        }

        QQC2.CheckBox {
            id: hour24
            Kirigami.FormData.label: S.tr(page.lang, "Hour:")
            text: S.tr(page.lang, "Use 24-hour format")
        }

        QQC2.CheckBox {
            id: showSeconds
            text: S.tr(page.lang, "Show seconds")
        }

        TrComboBox {
            id: dateStyle
            lang: page.lang
            Kirigami.FormData.label: S.tr(page.lang, "Date:")
            model: ["Written (Monday 5 Oct 2026)", "Numeric (05/10/2026)"]
        }
    }
}
