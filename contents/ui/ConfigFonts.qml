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

    property alias cfg_fontClock: fClock.value
    property alias cfg_fontSearch: fSearch.value
    property alias cfg_fontApps: fApps.value
    property alias cfg_fontTips: fTips.value
    property alias cfg_fontMedia: fMedia.value
    property alias cfg_fontCards: fCards.value

    // La lista de fuentes del sistema se pide una sola vez y después de mostrar la página,
    // para que no se note ningún retraso al entrar.
    property var families: []
    property bool familiesLoaded: false
    Timer {
        running: true
        interval: 60
        onTriggered: {
            try {
                page.families = Qt.fontFamilies();
            } catch (e) {
                page.families = [];
            }
            page.familiesLoaded = true;
        }
    }
    readonly property bool manual: familiesLoaded && families.length === 0

    Kirigami.FormLayout {
        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 28
            wrapMode: Text.WordWrap
            text: S.tr(page.lang, "Pick an installed font for each part of the launcher. \u00ABSystem default\u00BB uses your system font. If you install a new font, restart Plasma so it shows up in the list (systemctl --user restart plasma-plasmashell).")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Fonts")
        }

        FontField {
            id: fClock
            Kirigami.FormData.label: S.tr(page.lang, "Clock and date:")
            lang: page.lang
            families: page.families
            manual: page.manual
        }

        FontField {
            id: fSearch
            Kirigami.FormData.label: S.tr(page.lang, "Search bar:")
            lang: page.lang
            families: page.families
            manual: page.manual
        }

        FontField {
            id: fApps
            Kirigami.FormData.label: S.tr(page.lang, "App names:")
            lang: page.lang
            families: page.families
            manual: page.manual
        }

        FontField {
            id: fTips
            Kirigami.FormData.label: S.tr(page.lang, "Button bubbles and active apps:")
            lang: page.lang
            families: page.families
            manual: page.manual
        }

        FontField {
            id: fCards
            Kirigami.FormData.label: S.tr(page.lang, "Category cards:")
            lang: page.lang
            families: page.families
            manual: page.manual
        }

        FontField {
            id: fMedia
            Kirigami.FormData.label: S.tr(page.lang, "Media player:")
            lang: page.lang
            families: page.families
            manual: page.manual
        }
    }
}
