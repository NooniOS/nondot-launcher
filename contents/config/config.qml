import QtQuick
import org.kde.plasma.configuration

// Los nombres de las pestañas son fijos (en inglés): config.qml no puede leer el idioma
// elegido en los ajustes del plasmoide. El contenido de cada página sí lo respeta.
ConfigModel {
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-theme"
        source: "ConfigGeneral.qml"
    }
    ConfigCategory {
        name: "Fonts"
        icon: "preferences-desktop-font"
        source: "ConfigFonts.qml"
    }
    ConfigCategory {
        name: "Animations"
        icon: "preferences-desktop-effects"
        source: "ConfigAnimations.qml"
    }
    ConfigCategory {
        name: "Right area"
        icon: "view-right-pane"
        source: "ConfigMedia.qml"
    }
    ConfigCategory {
        name: "Language"
        icon: "preferences-desktop-locale"
        source: "ConfigLanguage.qml"
    }
}
