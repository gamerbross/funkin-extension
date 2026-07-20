package mikolka.install.chips;

import haxe.io.Path;
import mikolka.install.backend.TaskChips;
import sys.FileSystem;

class FileTaskChips {
    public static function consumeHmmFIle(haxelib_path:String) {
        return (resolve:Void->Void, deny:String->Void,ctx:TaskChips) ->{
            var base_path = Path.join([haxelib_path,"funkin","git","hmm.json"]);
            if(FileSystem.exists(base_path)){
                var bak_path = Path.join([haxelib_path,"funkin","git","hmm.bak.json"]);
                FileSystem.rename(base_path,bak_path);
            }
            resolve();
        }
    }
    public static function consumeInstallFiles(haxelib_path:String,fullReplace_path:Null<String>) {
        return (resolve:Void->Void, deny:String->Void,ctx:TaskChips) ->{
            var install_file_path = Path.join([haxelib_path,"install.json"]);
            if(FileSystem.exists(install_file_path))
                FileSystem.deleteFile(install_file_path);
            if(fullReplace_path != null)
                FileManager.deleteDirRecursively(Path.join([haxelib_path,fullReplace_path]));
            resolve();
        }
    }
}