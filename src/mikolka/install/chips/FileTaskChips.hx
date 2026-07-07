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
}