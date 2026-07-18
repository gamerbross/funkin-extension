package mikolka.config;

import haxe.DynamicAccess;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
using mikolka.utils.JsonUtils;

typedef Metadata = {
    name:String,
    version:String,
    description:String,
    hxmlFile:Null<String>,
    // Once enabled strips "package" line at the beginning of each file
	// (you still need that line even if you disable that)
	stripPackage:Bool,

	// Allows you to utilise haxe's safe casts, like "cast (obj,type)"
	convertCasts:Bool,

	// Fixes imports not being recognised by polymod (especially enums)
	convertImports:Bool,

	// Allows you to utilise mock calls to polymod to fix missing method error
	mockPolymodCalls:Bool,
    importBlacklist:DynamicAccess<String>
}

class MetadataParser {
    public static function readHaxelibMetadata(haxelibTarget:String):Null<Metadata> {
        var metadata_path = Path.join([haxelibTarget,"metadata.json"]);
        if(!FileSystem.exists(metadata_path)) return null;
        var obj:Metadata = Json.parse(File.getContent(metadata_path));
        return obj;
    }
    public static function readActiveMetadata():Metadata {
        var path = VsCodeConfig.instance.HAXELIB_PATH;
        var base:Metadata = {
            name: "No name",
            version: "1.0.0",
            description: "No description",
            mockPolymodCalls: true,
            convertImports: true,
            convertCasts: true,
            stripPackage: false,
            hxmlFile:null,
            importBlacklist: new DynamicAccess<String>()
        };
        var result = base.mergeWithJson(readHaxelibMetadata(path)); 
        trace(result);
        return result;
    }
    public static function extractRegexRules(obj:Metadata) {
        var result = new Map<EReg,String>();
        for (key => value in obj.importBlacklist) {
            result.set(new EReg(key,""),value);
        }
        return result;
    }
}