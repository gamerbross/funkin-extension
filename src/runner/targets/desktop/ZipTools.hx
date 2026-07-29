package runner.targets.desktop;

import runner.vslice.FunkinPaths;
import sys.io.File;
import haxe.zip.Tools;
import haxe.zip.Reader;
import vscode.FileSystem;

class ZipTools {
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