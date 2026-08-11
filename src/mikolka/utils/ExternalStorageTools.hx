package mikolka.utils;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;

class ExternalStorageTools {
    private var ctx:vscode.ExtensionContext;
    public function new(context:vscode.ExtensionContext) {
        ctx = context;
    }
    public inline static function getGlobalStore(context:vscode.ExtensionContext):ExternalStorageTools {
        return new ExternalStorageTools(context);
    }

    public function getHaxelibRootPath():String{
		var path = Path.join([ctx.globalStorageUri.fsPath,"userHaxelibs"]);
		if(!FileSystem.exists(path)) FileSystem.createDirectory(path);
		return path;
	}
    public function getCustomHaxeRootPath():String{
		var path = Path.join([ctx.globalStorageUri.fsPath,"haxe"]);
		if(!FileSystem.exists(path)) FileSystem.createDirectory(path);
		return path;
	}
    public function clearCustomHaxe(){
		var path = Path.join([ctx.globalStorageUri.fsPath,"haxe"]);
		if(FileSystem.exists(path)) FileManager.deleteDirRecursively(path);
	}
    public function getTempPath():String{
		var path = Path.join([ctx.globalStorageUri.fsPath,"temp"]);
		if(!FileSystem.exists(path)) FileSystem.createDirectory(path);
		return path;
	}
    public function clearTempPath(){
		var path = Path.join([ctx.globalStorageUri.fsPath,"temp"]);
		if(FileSystem.exists(path)) FileManager.deleteDirRecursively(path);
	}
    /**
    * Get names of the installed haxelibs in the extension's registry.
    **/
    public function getInstalledHaxelibs():Array<String> {
        var base_path = getHaxelibRootPath();
        var base_list = FileSystem.readDirectory(base_path);
        return base_list.filter(s -> FileSystem.isDirectory(Path.join([base_path,s])));
    }

    public function getHaxeVersion():Null<String> {
        var path = Path.join([ctx.globalStorageUri.fsPath,"haxe","version.txt"]);
		if(FileSystem.exists(path)) return File.getContent(path);
        return null;
    }
    public function setHaxeVersion(value:String) {
        var path = Path.join([ctx.globalStorageUri.fsPath,"haxe","version.txt"]);
		File.saveContent(path,value);
    }

}