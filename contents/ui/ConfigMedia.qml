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

    property alias cfg_rightPanel: panel.currentIndex

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Right area")
        }

        TrComboBox {
            id: panel
            lang: page.lang
            Kirigami.FormData.label: S.tr(page.lang, "Show:")
            Layout.preferredWidth: Kirigami.Units.gridUnit * 18
            model: ["Media player", "Category cards", "Nothing"]
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 28
            wrapMode: Text.WordWrap
            visible: panel.currentIndex === 0
            text: S.tr(page.lang, "Shows the cover and name of what is playing (music and video), the previous, pause and next buttons, and the active audio output, where you can also change it.")
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 28
            wrapMode: Text.WordWrap
            visible: panel.currentIndex === 1
            text: S.tr(page.lang, "One card per category of system applications (empty ones are not shown). Clicking one filters the grid to those apps; another click removes the filter. Color and opacity are set in Appearance, and the font in Fonts.")
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 28
            wrapMode: Text.WordWrap
            visible: panel.currentIndex === 2
            text: S.tr(page.lang, "The right area stays empty and no media or audio is loaded.")
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 28
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: S.tr(page.lang, "Only one of the two can be chosen: the player and the cards share the same space. The M button in the launcher switches between them.")
        }
    }
}
