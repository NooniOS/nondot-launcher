import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

// Apps en ejecución. Está en su propio archivo para cargarse con un Loader:
// si el módulo de la barra de tareas fallara, el resto del lanzador sigue funcionando.
Item {
    id: bar

    property real u: 10
    property string fontFamily: ""     // fuente Ndot
    property string fontText: ""       // fuente de texto
    property bool animated: true
    property color accent: "#D71921"   // color de acento de las apps activas
    property color ink: "white"
    signal activatedApp()

    // Ancho que necesita el contenido (la burbuja se ajusta a él)
    implicitWidth: Math.max(u * 8, list.contentWidth) + u * 3

    // Ventanita con el nombre de la app bajo el cursor
    property string tipLabel: ""
    property real tipCenterX: 0
    // Se recuerda el último nombre para que no quede vacío mientras la burbuja se desvanece
    property string tipShown: ""
    onTipLabelChanged: if (tipLabel !== "") tipShown = tipLabel

    TextMetrics {
        id: tipMetrics
        text: bar.tipShown
        font.family: bar.fontText
        font.pixelSize: bar.u * 2.1
    }

    TaskManager.TasksModel {
        id: tasks
        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
        separateLaunchers: false
        filterByVirtualDesktop: false
        filterByScreen: false
        filterByActivity: false
        filterNotMinimized: false
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.leftMargin: bar.u * 1.5
        anchors.rightMargin: bar.u * 1.5
        orientation: ListView.Horizontal
        clip: true
        spacing: 0
        model: tasks
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: cell
            required property int index
            required property var model

            // No mostrar la propia ventana del lanzador ni ventanas ocultas de la barra
            readonly property bool shown: model.SkipTaskbar !== true
                                          && model.display !== "NonDot Launcher"
            readonly property string appLabel: {
                const n = model.AppName;
                return (n !== undefined && n !== "") ? n : model.display;
            }

            visible: shown
            width: shown ? bar.u * 8.2 : 0
            height: list.height

            // Fondo rojo traslúcido (50 %) detrás de cada app
            Rectangle {
                anchors.centerIn: parent
                width: bar.u * 7.4
                height: bar.u * 7.4
                radius: bar.u * 1.8
                color: Qt.rgba(bar.accent.r, bar.accent.g, bar.accent.b, tip.containsMouse ? 0.7 : 0.5)
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                width: bar.u * 5.6
                height: width
                source: cell.model.decoration
            }

            // Punto blanco bajo la app que tiene el foco
            Rectangle {
                visible: cell.model.IsActive === true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: bar.u * 0.3
                width: bar.u * 0.8
                height: width
                radius: width / 2
                color: bar.ink
            }

            MouseArea {
                id: tip
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    bar.tipLabel = cell.appLabel;
                    bar.tipCenterX = cell.mapToItem(bar, cell.width / 2, 0).x;
                }
                onExited: {
                    if (bar.tipLabel === cell.appLabel) {
                        bar.tipLabel = "";
                    }
                }
                onClicked: {
                    tasks.requestActivate(tasks.makeModelIndex(cell.index));
                    bar.activatedApp();
                }
            }
        }
    }

    // Nombre flotante encima de la barra, como en una barra de tareas normal
    Rectangle {
        z: 100
        opacity: bar.tipLabel !== "" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: bar.animated ? 160 : 0 } }
        height: tipMetrics.height + bar.u * 1.6
        width: Math.min(tipMetrics.width + bar.u * 3, bar.u * 40)
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.9)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.25)
        x: bar.tipCenterX - width / 2
        y: -height - bar.u * 0.8

        Text {
            x: bar.u * 1.5
            width: parent.width - bar.u * 3
            anchors.verticalCenter: parent.verticalCenter
            text: bar.tipShown
            color: "white"
            elide: Text.ElideRight
            font: tipMetrics.font
        }
    }

    Text {
        anchors.centerIn: parent
        visible: list.count === 0
        text: "—"
        color: Qt.rgba(bar.ink.r, bar.ink.g, bar.ink.b, 0.4)
        font.family: bar.fontFamily
        font.pixelSize: bar.u * 3
    }
}
