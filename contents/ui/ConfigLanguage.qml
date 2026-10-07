import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import "strings.js" as S

KCM.SimpleKCM {
    id: page

    // "en" o "es". No depende del idioma del sistema.
    property string cfg_language: Plasmoid.configuration.language
    readonly property string lang: Plasmoid.configuration.language

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Language")
        }

        QQC2.ComboBox {
            id: languageBox
            Kirigami.FormData.label: S.tr(page.lang, "Interface language:")
            model: ["English", "Español"]
            currentIndex: page.cfg_language === "es" ? 1 : 0
            onActivated: page.cfg_language = currentIndex === 1 ? "es" : "en"
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 26
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: S.tr(page.lang, "This choice does not depend on the system language. The names of the tabs on the left may stay in English.")
                + "\n\n" + S.tr(page.lang, "Changes are applied after pressing Apply.")
        }
    }
}
