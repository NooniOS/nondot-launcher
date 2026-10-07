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

    property alias cfg_animations: master.checked
    property alias cfg_animFade: fade.checked
    property alias cfg_animClock: clock.checked
    property alias cfg_animTyping: typing.checked
    property alias cfg_animFilter: filter.checked
    property alias cfg_animHover: hover.checked
    property alias cfg_marqueeMode: marquee.currentIndex
    property alias cfg_animCardsMarquee: cardsMarquee.checked

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Animations")
        }

        QQC2.CheckBox {
            id: master
            Kirigami.FormData.label: S.tr(page.lang, "General:")
            text: S.tr(page.lang, "Turn animations on")
        }

        QQC2.CheckBox {
            id: fade
            Kirigami.FormData.label: S.tr(page.lang, "Opening and closing:")
            text: S.tr(page.lang, "Fade in and out")
            enabled: master.checked
        }

        QQC2.CheckBox {
            id: clock
            Kirigami.FormData.label: S.tr(page.lang, "Date and time:")
            text: S.tr(page.lang, "Soft appearance")
            enabled: master.checked
        }

        QQC2.CheckBox {
            id: typing
            Kirigami.FormData.label: S.tr(page.lang, "Button bubbles:")
            text: S.tr(page.lang, "Text is typed letter by letter")
            enabled: master.checked
        }

        QQC2.CheckBox {
            id: filter
            Kirigami.FormData.label: S.tr(page.lang, "App grid:")
            text: S.tr(page.lang, "Transitions when filtering and switching view")
            enabled: master.checked
        }

        QQC2.CheckBox {
            id: hover
            Kirigami.FormData.label: S.tr(page.lang, "Buttons:")
            text: S.tr(page.lang, "Effects when hovering")
            enabled: master.checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Media player")
        }

        TrComboBox {
            id: marquee
            lang: page.lang
            Kirigami.FormData.label: S.tr(page.lang, "Long title and artist:")
            enabled: master.checked
            model: ["Still (cut with «…»)", "Slide when hovering", "Always slide"]
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: S.tr(page.lang, "Category cards")
        }

        QQC2.CheckBox {
            id: cardsMarquee
            Kirigami.FormData.label: S.tr(page.lang, "Long names:")
            text: S.tr(page.lang, "Always slide, without pauses")
            enabled: master.checked
        }
    }
}
