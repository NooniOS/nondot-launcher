/*
    NonDot Launcher
    Este archivo no importa módulos privados de KDE a propósito: los modelos de datos
    (AppModels.qml), el reproductor y la salida de audio se cargan aparte, para que si
    alguno falla se pueda mostrar un aviso claro en lugar de que todo deje de funcionar.
*/
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: launcher

    anchors.fill: parent

    preferredRepresentation: fullRepresentation
    compactRepresentation: null
    fullRepresentation: buttonComponent

    Plasmoid.icon: "start-here-kde"

    Component {
        id: buttonComponent
        LauncherButton {
            applet: launcher
        }
    }

    Component.onCompleted: {
        if (Plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            Plasmoid.activationTogglesExpanded = false;
        }
    }
}
