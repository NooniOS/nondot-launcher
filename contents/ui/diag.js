.pragma library
.import "strings.js" as S

// Diagnóstico de fallos: convierte el error técnico de Qt en un aviso que dice
// qué falta y qué debe hacer la persona (instalar algo o esperar una actualización).
// Todos los textos salen de strings.js, en el idioma elegido en los ajustes (lang).

// Los módulos privados de KDE que usa el plasmoid y el paquete que los trae
var MODULES = {
    "org.kde.plasma.private.kicker": { pkg: "plasma-desktop" },
    "org.kde.plasma.private.mpris": { pkg: "plasma-workspace" },
    "org.kde.plasma.private.volume": { pkg: "plasma-pa" },
    "org.kde.taskmanager": { pkg: "plasma-workspace" },
    "org.kde.plasma.plasma5support": { pkg: "plasma-workspace" }
};

function missingModule(err) {
    var m = /module "([^"]+)" is not installed/.exec(String(err || ""));
    return m ? m[1] : "";
}

// feature: nombre legible de la función que falló; off: cómo desactivarla (o "")
function describe(lang, id, feature, err, off) {
    var mod = missingModule(err);
    var offText = off !== "" ? S.tr(lang, " Meanwhile you can turn it off in %1.", off) : "";
    var p = {
        id: id,
        severity: "error",
        title: S.tr(lang, "%1: could not be loaded", feature),
        what: "",
        todo: "",
        detail: String(err || S.tr(lang, "(no details)"))
    };
    if (mod !== "") {
        var info = MODULES[mod];
        var pkg = info ? info.pkg : S.tr(lang, "the Plasma components");
        p.what = S.tr(lang, "The module «%1» is missing on this system.", mod);
        p.todo = S.tr(lang, "Install the «%1» package from your distribution and restart Plasma (systemctl --user restart plasma-plasmashell).", pkg) + offText;
    } else {
        p.what = S.tr(lang, "KDE changed something this plasmoid uses. This usually happens right after updating Plasma or Qt.");
        p.todo = S.tr(lang, "There is nothing to install: you need to wait for an update of this plasmoid from the developer.") + offText;
    }
    return p;
}

function fontProblem(lang, category, name) {
    return {
        id: "font:" + category,
        severity: "warning",
        title: S.tr(lang, "Font not found (%1)", category),
        what: S.tr(lang, "The font «%1» is not installed on this system; the system font is used instead.", name),
        todo: S.tr(lang, "Install the font and restart Plasma (systemctl --user restart plasma-plasmashell), or pick another one in the plasmoid settings, Fonts section."),
        detail: ""
    };
}

// Texto plano para copiar y pegar en un informe de error
function report(lang, version, qtVersion, problems) {
    var lines = ["NonDot Launcher " + version, "Qt " + qtVersion, ""];
    for (var i = 0; i < problems.length; ++i) {
        var p = problems[i];
        lines.push("[" + (p.severity === "error" ? S.tr(lang, "ERROR") : S.tr(lang, "WARNING")) + "] " + p.title);
        lines.push("  " + p.what);
        lines.push("  " + S.tr(lang, "What to do:") + " " + p.todo);
        if (p.detail && p.detail !== "") {
            lines.push("  " + S.tr(lang, "Technical detail:") + " " + p.detail);
        }
        lines.push("");
    }
    return lines.join("\n");
}
