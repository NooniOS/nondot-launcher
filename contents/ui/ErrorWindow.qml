import QtQuick
import QtQuick.Window
import "strings.js" as S

// Ventana de aviso independiente: se usa cuando el lanzador no puede ni abrirse
// (por ejemplo, si falta el módulo de aplicaciones de Plasma).
Window {
    id: win

    property var problems: []
    property string reportText: ""
    property string lang: "en"

    title: S.tr(win.lang, "NonDot Launcher: problem")
    width: 760
    height: 560
    color: "#050505"
    flags: Qt.Dialog

    ProblemsCard {
        anchors.centerIn: parent
        u: 10
        width: parent.width - 40
        height: parent.height - 40
        problems: win.problems
        reportText: win.reportText
        lang: win.lang
        onCloseRequested: win.close()
    }
}
