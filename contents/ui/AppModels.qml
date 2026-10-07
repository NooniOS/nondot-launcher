/*
    Modelos de datos del lanzador (apps, más usadas, recientes y búsqueda).
    Usan el módulo privado de Kicker (org.kde.plasma.private.kicker, KDE, GPL-2.0-or-later).
    Están en su propio archivo para que, si KDE cambia ese módulo, el plasmoid pueda
    avisar de qué falló en vez de fallar en silencio (LauncherButton lo carga y comprueba).
*/
import QtQuick
import org.kde.plasma.private.kicker as Kicker

Item {
    id: models

    // El PlasmoidItem (lo pasa LauncherButton)
    property var applet: null

    property alias appsModel: appsRoot
    property alias popularModel: popularUsage
    property alias recentModel: recentUsage
    property alias runnerModel: searchRunner

    // Todas las aplicaciones, en una sola lista plana y ordenada alfabéticamente
    Kicker.RootModel {
        id: appsRoot
        appletInterface: models.applet
        flat: true
        sorted: true
        showAllApps: true
        showAllAppsCategorized: false
        showTopLevelItems: false
        showRecentApps: false
        showRecentDocs: false
        showRecentFolders: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        showRootSeparator: false
        highlightNewlyInstalledApps: false
        appNameFormat: 0
    }

    // Apps más usadas
    Kicker.RecentUsageModel {
        id: popularUsage
        shownItems: Kicker.RecentUsageModel.OnlyApps
        ordering: 1
        favoritesModel: appsRoot.favoritesModel
    }

    // Apps recientes
    Kicker.RecentUsageModel {
        id: recentUsage
        shownItems: Kicker.RecentUsageModel.OnlyApps
        ordering: 0
        favoritesModel: appsRoot.favoritesModel
    }

    // Búsqueda
    Kicker.RunnerModel {
        id: searchRunner
        appletInterface: models.applet
        mergeResults: true
        favoritesModel: appsRoot.favoritesModel
        runners: ["krunner_services", "krunner_systemsettings", "calculator", "unitconverter"]
    }
}
