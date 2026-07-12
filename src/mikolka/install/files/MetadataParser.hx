package mikolka.install.files;

import mikolka.install.backend.TaskChips.ChipTask;
import haxe.Exception;
import haxe.ValueException;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.ds.StringMap;

import mikolka.install.chips.*;

typedef Metadata = {
    name:String,
    version:String,
    description:String
}

class MetadataParser {

    public static function readHaxelibMetadata(haxelibTarget:String):Null<Metadata> {
        var metadata_path = Path.join([haxelibTarget,"metadata.json"]);
        if(!FileSystem.exists(metadata_path)) return null;
        var obj:Metadata = Json.parse(File.getContent(metadata_path));
        return obj;
    }

}