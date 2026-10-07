import QtQuick
import QtQuick.Controls as QQC2
import "strings.js" as S

// Lista desplegable cuyas opciones se traducen sin cambiar el modelo.
// Si se reemplazara el modelo al cambiar de idioma, ComboBox reiniciaría currentIndex
// y se perdería el valor guardado; por eso el modelo (en inglés) no cambia y solo
// se traduce lo que se muestra.
QQC2.ComboBox {
    id: combo

    property string lang: "en"

    displayText: S.tr(lang, currentText)

    delegate: QQC2.ItemDelegate {
        required property var modelData
        required property int index
        width: combo.width
        text: S.tr(combo.lang, modelData)
        highlighted: combo.highlightedIndex === index
    }
}
