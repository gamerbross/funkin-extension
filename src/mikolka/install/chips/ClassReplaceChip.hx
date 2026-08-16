package mikolka.install.chips;

import sys.io.File;
import haxe.io.Path;
import mikolka.install.backend.TaskChips;

using StringTools;

class ClassReplaceChip {
    var haxePatchesPath:String;
    var haxelib_path:String;
    var writeLine:String ->Void;

    public function new(haxePatchesPath:String,haxelib_path:String,writeLine:String ->Void) {
        this.haxePatchesPath = haxePatchesPath;
        this.haxelib_path = haxelib_path;
        this.writeLine = writeLine;
    }
    public function task(resolve:Void->Void, deny:String->Void,ctx:TaskChips) {
        var full_path = Path.join([haxelib_path,haxePatchesPath]);
        FileManager.scanDirectory(full_path,onFile,(x) ->{});
        resolve();
    }
    private function onFile(filename:String) {
        trace(filename);
        if(filename.endsWith(".patch")){
            var sourceFileName = filename.substring(0,filename.length-(".patch".length));
            var patchFile = filename;
            var sourceContent = File.getContent(Path.join([haxelib_path,sourceFileName]));
            var patchContent = File.getContent(Path.join([haxelib_path,haxePatchesPath,patchFile]));

            var pattern = ~/-# ([^\n]*)\n(.*)/s;
            if(pattern.match(patchContent)){
                var filePattern = new EReg(pattern.matched(1),"gm");
                var replaceContent = filePattern.replace(sourceContent,pattern.matched(2));
                File.saveContent(Path.join([haxelib_path,sourceFileName]),replaceContent);
            }
            else {
                writeLine('patch file ${patchFile} doesn\'t have a valid patch! It will be ignored.');
            }
        }
        else {
            var sourceFile = Path.join([haxelib_path,filename]);
            var replacePatchFile = File.getContent(Path.join([haxelib_path,haxePatchesPath,filename]));

            File.saveContent(sourceFile, replacePatchFile);
        }
    }
}