package runner;

import haxe.io.BytesOutput;
import mikolka.helpers.ZipTools;
import haxe.Exception;
import runner.vslice.FunkinPaths;
import haxe.zip.Tools;
import haxe.io.Path;
import haxe.io.Input;
import haxe.zip.Reader;
import sys.FileSystem;
import haxe.crypto.Base64;
import haxe.io.BytesInput;
import sys.io.File;
using StringTools;

class DebugFiles {
    public static macro function getBaseZip():haxe.macro.Expr.ExprOf<String> {
        #if !display
        
        var zip_nodes = new List<haxe.zip.Entry>();
        if(!FileSystem.exists("./debug-mod/export/")){
            var pos = haxe.macro.Context.currentPos();
            haxe.macro.Context.error("Debug mod is not compiled!", pos);
        }
        var out = new BytesOutput();
        
        var nodes = ZipTools.getZipFileEntries("./debug-mod/export/",zip_nodes,"debug-mod/export/");
        ZipTools.bundleZipNodes(nodes,out);
        var baseString = Base64.encode(out.getBytes());

        // Generates a string expression
        return macro $v{baseString};
        #else 
        // `#if display` is used for code completion. In this case returning an
        // empty string is good enough; We don't want to call git on every hint.
        var baseString:String = "";
        return macro $v{baseString};
        #end
  }

	public static function makeSupportMod(cwd_path:String) {
        trace("mac: "+cwd_path);
        var script_folder = Path.join([FunkinPaths.getModFolderPath(cwd_path), "debug"]);

            if (!FileSystem.exists(script_folder))
                extractZip(new BytesInput(Base64.decode(getBaseZip())), script_folder);
	}

	public static function extractZip(file:Input, target:String) {
		var zip = Reader.readZip(file);
		FileSystem.createDirectory(target);
		for (node in zip) {
			if (node.crc32 == null || node.crc32 == 0) {
				FileSystem.createDirectory(Path.join([target, node.fileName]));
			} else {
				Tools.uncompress(node);
                var target_file_path = Path.join([target, node.fileName]);
                FileSystem.createDirectory(Path.directory(target_file_path));
				File.saveBytes(target_file_path, node.data);
			}
		}
	}
}
