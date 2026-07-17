package mikolka.install.chips;

import haxe.io.Path;
import mikolka.install.backend.TaskChips;

class DirectoryRemovalChip {
    var directoriesToRemove:Array<String>;
    var haxelib_path:String;
    public function new(directoriesToRemove:Array<String>,haxelib_path:String) {
        this.directoriesToRemove = directoriesToRemove;
        this.haxelib_path = haxelib_path;
    }
    public function task(resolve:Void->Void, deny:String->Void,ctx:TaskChips) {
        for (item in directoriesToRemove) {
            var full_dir = Path.join([haxelib_path,item]);
            FileManager.deleteDirRecursively(full_dir);
        }
        resolve();
    }
}