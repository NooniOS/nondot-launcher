.pragma library

// Textos del plasmoid. Los originales están en inglés; "es" es la traducción al español.
// Uso:  S.tr(lang, "English text %1", valor)   (lang = "en" o "es")
// Si falta una traducción, se muestra el texto en inglés.

var es = {
    // --- lanzador
    "Search apps…": "Buscar aplicaciones…",
    "No results": "Sin resultados",
    "List view": "Vista de lista",
    "Grid view": "Vista de cuadrícula",
    "Power off": "Apagar",
    "Restart": "Reiniciar",
    "Suspend": "Suspender",
    "Switch user": "Cambiar de usuario",
    "Close": "Cerrar",
    "Settings": "Ajustes",
    "No categories": "Sin categorías",
    "NO MEDIA": "SIN MEDIOS",
    "Nothing playing": "Nada en reproducción",
    "AUDIO OUTPUT · %1": "SALIDA DE AUDIO · %1",
    "No audio output": "Sin salida de audio",
    "ANALOG": "ANALÓGICA",
    "OUTPUT": "SALIDA",
    "Right area: %1 → %2": "Zona derecha: %1 → %2",
    "Media player": "Reproductor",
    "Cards": "Tarjetas",
    "Nothing": "Nada",

    // --- avisos
    "Something isn't working as it should": "Algo no funciona como debería",
    "The rest of the launcher keeps working.": "El resto del lanzador sigue funcionando.",
    "What to do: %1": "Qué hacer: %1",
    "Copy report": "Copiar informe",
    "Got it": "Entendido",
    "Copied": "Copiado",
    "NonDot Launcher: problem": "NonDot Launcher: problema",
    "Could not create the component.": "No se pudo crear el componente.",
    "Could not create the models object.": "No se pudo crear el objeto de los modelos.",
    "Could not create the window.": "No se pudo crear la ventana.",
    "App list": "Lista de aplicaciones",
    "Launcher window": "Ventana del lanzador",
    "Active apps": "Apps activas",
    "Category cards": "Tarjetas de categorías",
    "Audio output": "Salida de audio",
    "Plasmoid settings ▸ Right area": "Ajustes del plasmoide ▸ Zona derecha",
    "the Plasma components": "los componentes de Plasma",
    "%1: could not be loaded": "%1: no se pudo cargar",
    "(no details)": "(sin detalle)",
    "The module «%1» is missing on this system.": "Falta el módulo «%1» en este sistema.",
    "Install the «%1» package from your distribution and restart Plasma (systemctl --user restart plasma-plasmashell).": "Instala el paquete «%1» de tu distribución y reinicia Plasma (systemctl --user restart plasma-plasmashell).",
    " Meanwhile you can turn it off in %1.": " Mientras tanto puedes desactivarlo en %1.",
    "KDE changed something this plasmoid uses. This usually happens right after updating Plasma or Qt.": "KDE cambió algo que este plasmoide usa. Suele pasar justo después de actualizar Plasma o Qt.",
    "There is nothing to install: you need to wait for an update of this plasmoid from the developer.": "No hay nada que instalar: hay que esperar una actualización de este plasmoide por parte del desarrollador.",
    "Font not found (%1)": "Fuente no encontrada (%1)",
    "The font «%1» is not installed on this system; the system font is used instead.": "La fuente «%1» no está instalada en este sistema; se usa la del sistema en su lugar.",
    "Install the font and restart Plasma (systemctl --user restart plasma-plasmashell), or pick another one in the plasmoid settings, Fonts section.": "Instala la fuente y reinicia Plasma (systemctl --user restart plasma-plasmashell), o elige otra en los ajustes del plasmoide, sección Fuentes.",
    "ERROR": "ERROR",
    "WARNING": "AVISO",
    "What to do:": "Qué hacer:",
    "Technical detail:": "Detalle técnico:",
    "Date and time": "Fecha y hora",
    "Search": "Buscador",
    "App names": "Nombres de las apps",
    "Button bubbles": "Burbujas de los botones",

    // --- ajustes: páginas y comunes
    "Fonts": "Fuentes",
    "Animations": "Animaciones",
    "Right area": "Zona derecha",
    "Language": "Idioma",
    "Background": "Fondo",
    "Background opacity:": "Opacidad del fondo:",
    "Background color:": "Color del fondo:",
    "Grid color:": "Color de las cuadrículas:",
    "Grid opacity:": "Opacidad de las cuadrículas:",
    "Grid text becomes light or dark automatically depending on its color.": "El texto de las cuadrículas se vuelve claro u oscuro solo según su color.",
    "Bar:": "Barra:",
    "Show the active apps bar": "Mostrar la barra de apps activas",
    "Accent color:": "Color de acento:",
    "Cards and M button": "Tarjetas y botón M",
    "Color:": "Color:",
    "Opacity:": "Opacidad:",
    "This color and opacity apply to the category cards and to the M button. If the cards are not active, they only affect the button. The text turns light or dark automatically depending on the color.": "Este color y esta opacidad valen para las tarjetas de categorías y para el botón M. Si las tarjetas no están activas, solo afectan al botón. El texto se vuelve claro u oscuro solo según el color.",
    "Hour:": "Hora:",
    "Use 24-hour format": "Usar formato de 24 horas",
    "Show seconds": "Mostrar los segundos",
    "Date:": "Fecha:",
    "Written (Monday 5 Oct 2026)": "Con letras (lunes 5 de oct 2026)",
    "Numeric (05/10/2026)": "Numérica (05/10/2026)",

    // --- ajustes: fuentes
    "Pick an installed font for each part of the launcher. «System default» uses your system font. If you install a new font, restart Plasma so it shows up in the list (systemctl --user restart plasma-plasmashell).": "Elige una fuente instalada en tu sistema para cada parte del lanzador. «Predeterminada» usa la fuente del sistema. Si instalas una fuente nueva, reinicia Plasma para que aparezca en la lista (systemctl --user restart plasma-plasmashell).",
    "Clock and date:": "Fecha y hora:",
    "Search bar:": "Buscador:",
    "App names:": "Nombres de las apps:",
    "Button bubbles and active apps:": "Burbujas de los botones y apps activas:",
    "Category cards:": "Tarjetas de categorías:",
    "Media player:": "Reproductor de medios:",
    "System default": "Predeterminada del sistema",
    "Preview: Aa Bb 0123 Ññ Áé 12:34 PM": "Muestra: Aa Bb 0123 Ññ Áé 12:34 PM",
    "This font is not installed: the launcher will use the system font until you install it.": "Esta fuente no está instalada: el lanzador usará la del sistema hasta que la instales.",
    "Search font…": "Buscar fuente…",

    // --- ajustes: animaciones
    "General:": "General:",
    "Turn animations on": "Activar las animaciones",
    "Opening and closing:": "Abrir y cerrar:",
    "Fade in and out": "Fundido de entrada y de salida",
    "Date and time:": "Fecha y hora:",
    "Soft appearance": "Aparición suave",
    "Button bubbles:": "Burbujas de los botones:",
    "Text is typed letter by letter": "El texto se escribe letra a letra",
    "App grid:": "Cuadrícula de apps:",
    "Transitions when filtering and switching view": "Transiciones al filtrar y al cambiar de vista",
    "Buttons:": "Botones:",
    "Effects when hovering": "Efectos al pasar el cursor",
    "Long title and artist:": "Nombre y artista largos:",
    "Still (cut with «…»)": "Quietos (se cortan con «…»)",
    "Slide when hovering": "Se deslizan al pasar el cursor",
    "Always slide": "Siempre se deslizan",
    "Long names:": "Nombres largos:",
    "Always slide, without pauses": "Se deslizan siempre, sin pausas",

    // --- ajustes: zona derecha
    "Show:": "Mostrar:",
    "Shows the cover and name of what is playing (music and video), the previous, pause and next buttons, and the active audio output, where you can also change it.": "Muestra la portada y el nombre de lo que suena o se ve (música y vídeo), los botones anterior, pausa y siguiente, y la salida de audio activa, donde también puedes cambiarla.",
    "One card per category of system applications (empty ones are not shown). Clicking one filters the grid to those apps; another click removes the filter. Color and opacity are set in Appearance, and the font in Fonts.": "Una tarjeta por cada categoría de aplicaciones del sistema (las vacías no se muestran). Al hacer clic en una, la cuadrícula muestra solo esas apps; otro clic quita el filtro. El color y la opacidad se cambian en Apariencia, y la fuente en Fuentes.",
    "The right area stays empty and no media or audio is loaded.": "La zona derecha queda vacía y no se carga nada de multimedia ni de audio.",
    "Only one of the two can be chosen: the player and the cards share the same space. The M button in the launcher switches between them.": "Solo se puede elegir una de las dos: el reproductor y las tarjetas comparten el mismo espacio. El botón M del lanzador cambia entre ellas.",

    // --- ajustes: idioma
    "Interface language:": "Idioma de la interfaz:",
    "This choice does not depend on the system language. The names of the tabs on the left may stay in English.": "Esta elección no depende del idioma del sistema. Los nombres de las pestañas de la izquierda pueden seguir en inglés.",
    "Changes are applied after pressing Apply.": "Los cambios se aplican al pulsar Aplicar."
};

var months = {
    en: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    es: ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
};
var days = {
    en: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
    es: ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]
};

function tr(lang, text, a1, a2) {
    var s = (lang === "es" && es[text] !== undefined) ? es[text] : text;
    if (a1 !== undefined) {
        s = s.replace("%1", a1);
    }
    if (a2 !== undefined) {
        s = s.replace("%2", a2);
    }
    return s;
}

// Fecha con letras: "lunes 5 de oct 2026" / "Monday, Oct 5 2026"
function longDate(lang, d) {
    var l = lang === "es" ? "es" : "en";
    if (l === "es") {
        return days.es[d.getDay()] + " " + d.getDate() + " de " + months.es[d.getMonth()] + " " + d.getFullYear();
    }
    return days.en[d.getDay()] + ", " + months.en[d.getMonth()] + " " + d.getDate() + " " + d.getFullYear();
}
