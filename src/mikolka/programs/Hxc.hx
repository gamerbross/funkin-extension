package mikolka.programs;

import mikolka.config.MetadataParser.Metadata;
import mikolka.vscode.ui.Interaction;
import mikolka.helpers.FileManager;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
using StringTools;

class Hxc {


	var src_path:String;
	var mod_export_path:String;
	var writeLine:String -> Void;
	var config:Metadata;

	public function new(src_path:String, mod_export_path:String,config:Metadata,writeLine:String -> Void) {
		this.src_path = src_path;
		this.mod_export_path = mod_export_path; // baseGane_modDir, Mod_Directory
		this.writeLine = writeLine;
		this.config = config;
	}

	public function processDirectory() {
		FileManager.scanDirectory(src_path, processFile, s -> {});
	}

	public function processFile(file_name:String) {
		if(!file_name.toLowerCase().endsWith(".hx"))	
			return;
		
		var shard = Path.join([src_path, file_name]);

		var filter:EReg = ~/package ([a-z.]+) *;/i;
		var content:String = File.getContent(shard);
		if (!filter.match(content)) {
			Interaction.displayError('File $shard is missing "package" line');
			return;
		}

		var result = config.stripPackage ? filter.replace(content, "") : content;
		if (config.convertCasts)
			result = ~/cast *\((.*),.*\)/g.replace(result, "$1"); // strip casts (polymod doesn't need them)
		if (config.convertImports)
			result = ~/import +([a-zA-z.]*)\.[A-Z]\w+\.([A-Z]\w+);/g.replace(result, "import $1.$2;");
		if (config.mockPolymodCalls)
			result = ~/\.polymodExecFunc *\((.*),(\W*\[.*\]\W*)\)/g.replace(result, ".scriptCall($1,$2)");

		var filePackage = filter.matched(1).split(".");
		filePackage[0] = Path.join([mod_export_path, 'scripts']);

		var targetDir = Path.join(filePackage);
		FileSystem.createDirectory(targetDir);
		writeLine(file_name.substr(1));
		File.saveContent(Path.join([targetDir, Path.withoutDirectory(file_name) + "c"]), result);
	}
}
