/*
    Reproductor de medios: portada, nombre y botones básicos.
    Usa el módulo MPRIS de Plasma (org.kde.plasma.private.mpris), el mismo del widget
    "Controles multimedia" de KDE: sirve para cualquier reproductor de música o vídeo.
*/
import QtQuick
import org.kde.plasma.private.mpris as Mpris
import "strings.js" as S

Item {
    id: mp

    property real u: 10
    property string lang: "en"
    property color tint: "#000000"
    property color ink: "white"
    readonly property color inkDim: Qt.rgba(ink.r, ink.g, ink.b, 0.6)
    readonly property color inkFaint: Qt.rgba(ink.r, ink.g, ink.b, 0.4)
    property real alpha: 0.6
    property string fontFamily: ""
    property color accent: "#D71921"
    // Medidas que fija el lanzador para alinear el panel con las cuadrículas
    property real cardHeight: u * 40
    property real controlsHeight: u * 8.4
    property real gap: u * 1.6
    // Carrusel: 0 = quieto, 1 = al pasar el cursor, 2 = siempre
    property int marqueeMode: 1
    property bool animated: true

    implicitHeight: cardHeight + gap + controlsHeight

    Mpris.Mpris2Model { id: mprisModel }

    readonly property var player: mprisModel.currentPlayer
    readonly property string track: player ? (player.track ?? "") : ""
    readonly property string artist: player ? (player.artist ?? "") : ""
    readonly property string artUrl: player ? (player.artUrl ?? "") : ""
    readonly property bool playing: player ? player.playbackStatus === Mpris.PlaybackStatus.Playing : false
    readonly property bool active: player ? player.playbackStatus > Mpris.PlaybackStatus.Stopped : false

    Column {
        width: parent.width
        spacing: mp.gap

        // Portada + nombre + artista
        Bubble {
            tint: mp.tint
            id: card
            width: parent.width
            height: mp.cardHeight
            alpha: mp.alpha
            u: mp.u

            readonly property real pad: mp.u * 1.6
            readonly property real innerW: width - pad * 2
            readonly property real innerH: height - pad * 2
            readonly property real titleH: mp.u * 3.4
            readonly property real artistH: mp.u * 2.6
            readonly property real textH: titleH + mp.u * 0.2 + artistH
            // La portada es cuadrada y deja sitio al texto debajo
            readonly property real artSide: Math.max(0, Math.min(innerW, innerH - textH - mp.u * 2.4))

            // El carrusel se activa al pasar el cursor por cualquier parte de la tarjeta
            HoverHandler { id: cardHover }

            Item {
                x: card.pad
                y: card.pad
                width: card.innerW
                height: card.innerH

                Item {
                    id: artBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: card.artSide
                    height: card.artSide

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(mp.ink.r, mp.ink.g, mp.ink.b, 0.05)
                        border.width: 1
                        border.color: Qt.rgba(mp.ink.r, mp.ink.g, mp.ink.b, 0.12)

                        Text {
                            anchors.centerIn: parent
                            text: S.tr(mp.lang, "NO MEDIA")
                            visible: art.status !== Image.Ready
                            color: mp.inkFaint
                            font.family: mp.fontFamily
                            font.pixelSize: mp.u * 2.6
                        }
                    }

                    Image {
                        id: art
                        anchors.fill: parent
                        source: mp.active ? mp.artUrl : ""
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                    }
                }

                // Nombre y artista: pegados entre sí, centrados en el espacio bajo la portada
                Column {
                    x: 0
                    width: parent.width
                    y: artBox.height + (parent.height - artBox.height - card.textH) / 2
                    spacing: mp.u * 0.2

                    MarqueeText {
                        width: parent.width
                        text: mp.active && mp.track !== "" ? mp.track : S.tr(mp.lang, "Nothing playing")
                        color: mp.active ? mp.ink : mp.inkFaint
                        fontFamily: mp.fontFamily
                        pixelSize: mp.u * 2.6
                        mode: mp.marqueeMode
                        hovered: cardHover.hovered
                    }

                    MarqueeText {
                        width: parent.width
                        text: mp.active ? mp.artist : ""
                        color: mp.inkDim
                        fontFamily: mp.fontFamily
                        pixelSize: mp.u * 1.9
                        mode: mp.marqueeMode
                        hovered: cardHover.hovered
                    }
                }
            }
        }

        // Botones: anterior, pausa/reproducir, siguiente
        Bubble {
            tint: mp.tint
            width: parent.width
            height: mp.controlsHeight
            alpha: mp.alpha
            u: mp.u

            Row {
                anchors.centerIn: parent
                spacing: mp.u * 3

                GlyphButton {
                    size: mp.u * 5.6
                    glyph: "<"
                    glyphColor: mp.ink
                    ink: mp.ink
                    fontFamily: mp.fontFamily
                    accent: mp.accent
                    animated: mp.animated
                    enabled: mp.player ? mp.player.canGoPrevious : false
                    onClicked: mp.player.Previous()
                }
                GlyphButton {
                    size: mp.u * 5.6
                    glyph: mp.playing ? "||" : "▶"
                    glyphColor: mp.accent
                    ink: mp.ink
                    fontFamily: mp.fontFamily
                    accent: mp.accent
                    animated: mp.animated
                    enabled: mp.player ? (mp.player.canPlay || mp.player.canPause) : false
                    onClicked: mp.player.PlayPause()
                }
                GlyphButton {
                    size: mp.u * 5.6
                    glyph: ">"
                    glyphColor: mp.ink
                    ink: mp.ink
                    fontFamily: mp.fontFamily
                    accent: mp.accent
                    animated: mp.animated
                    enabled: mp.player ? mp.player.canGoNext : false
                    onClicked: mp.player.Next()
                }
            }
        }
    }
}
