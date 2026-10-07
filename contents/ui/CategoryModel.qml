/*
    Categorías de aplicaciones (Desarrollo, Gráficos, Multimedia...): son las del menú de
    aplicaciones del sistema, ya traducidas. Usa el módulo privado de Kicker
    (org.kde.plasma.private.kicker, KDE, GPL-2.0-or-later). Va en su propio archivo para que,
    si KDE cambia ese módulo, solo se desactiven las tarjetas y se avise de qué falló.
*/
import QtQuick
import org.kde.plasma.private.kicker as Kicker

Item {
    id: holder

    property var applet: null
    property alias model: categories

    Kicker.AppsModel {
        id: categories
        flat: true
        sorted: true
        showSeparators: false
        appletInterface: holder.applet
    }
}
