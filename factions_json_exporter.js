function chat(e) {
    if (e.message == "!export_factions") {
        e.setCanceled(true)
        var API = Java.type('noppes.npcs.api.NpcAPI').Instance()
        var factions = API.getFactions().list()
        var faction_dict = ''

        for (var f = 0; f < factions.size(); f++) {
            if (f == factions.size() - 1) {
                faction_dict += JSON.stringify(factions[f].name) + ': ' + factions[f].id + "\n"
            }
            else {
                faction_dict += JSON.stringify(factions[f].name) + ': ' + factions[f].id + ",\n"
            }
        }
        var JSON_FILEPATH = 'exported_factions/factions_' + e.player.getWorld().name + '.json';
        mkPath(JSON_FILEPATH)
        writeToFile(JSON_FILEPATH, "{\n" + faction_dict + "}")
        e.player.message("&dFaction data has been exported. Check your .minecraft or server folder for the folder 'exported_factions'")
    }
}

function escapeRegex(string) {
    return string.replace(/[/\-\\^$*+?.()|[\]{}]/g, '\\$&');
}

var File = Java.type("java.io.File");
var Files = Java.type("java.nio.file.Files");
var Paths = Java.type("java.nio.file.Paths");
var CHARSET_UTF_8 = Java.type("java.nio.charset.StandardCharsets").UTF_8;





function mkPath(path) { //This will create a path, if you provide a path with non-existend directories it will create them, very handy
    var expath = path.split("/");
    var curpath = "";
    for (var ex in expath) {
        var expt = expath[ex];
        curpath += (curpath == "" ? "" : "/") + expt;
        var pfile = new File(curpath);
        if (!pfile.exists()) {
            if (expt.match(/[\w]+\.[\w]+/) === null) { //is dir?
                pfile.mkdir();
            } else {
                pfile.createNewFile();
            }
        }
    }
}

function writeToFile(filePath, text) {
    var path = Paths.get(filePath);
    try {
        var writer = Files.newBufferedWriter(path, CHARSET_UTF_8);
        writer.write(text);
        writer.close();
        return true;
    } catch (exc) {
        return false
    }
}
