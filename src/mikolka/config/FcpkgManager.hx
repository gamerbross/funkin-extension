package mikolka.config;

import haxe.io.Path;
import sys.FileSystem;

class FcpkgManager {
    private var ctx:vscode.ExtensionContext;
    public function new(context:vscode.ExtensionContext) {
        ctx = context;
        
    }

    public function getHaxelibRootPath():String{
		var path = Path.join([ctx.globalStorageUri.fsPath,"userHaxelibs"]);
		if(!FileSystem.exists(path)) FileSystem.createDirectory(path);
		return path;
	}
    /**
    * Get names of the installed haxelibs in the extension's registry.
    **/
    public function getInstalledHaxelibs():Array<String> {
        var base_path = getHaxelibRootPath();
        var base_list = FileSystem.readDirectory(base_path);
        return base_list.filter(s -> FileSystem.isDirectory(Path.join([base_path,s])));
    }
}