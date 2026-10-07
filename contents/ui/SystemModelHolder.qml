import QtQuick
import org.kde.plasma.private.kicker as Kicker

// Envuelve el SystemModel de Kicker (bloquear, cerrar sesión, cambiar usuario,
// suspender, reiniciar, apagar...). Solo existen las acciones que el sistema permite.
Item {
    id: holder

    readonly property int count: systemModel.count

    // Fila de la acción cuyo icono estándar es "iconName" (-1 si no está disponible)
    function rowFor(iconName) {
        for (let i = 0; i < systemModel.count; ++i) {
            if (systemModel.data(systemModel.index(i, 0), Qt.DecorationRole) === iconName) {
                return i;
            }
        }
        return -1;
    }

    function run(row) {
        if (row >= 0) {
            systemModel.trigger(row, "", null);
        }
    }

    Kicker.SystemModel {
        id: systemModel
    }
}
