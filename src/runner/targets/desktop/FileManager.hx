package runner.targets.desktop;

import sys.io.File;
import haxe.zip.Entry;
import haxe.io.Path;
import sys.FileSystem;

class FileManager {
	public static function deleteDirRecursively(path:String):Void {
		scanDirectory(path, s -> FileSystem.deleteFile(Path.join([path, s])), s -> FileSystem.deleteDirectory(Path.join([path, s])));
	}

	public static function isManifestPresent(modAssetsDir:String):Bool {
		var manifestPath = '$modAssetsDir/_polymod_meta.json';

		if (!FileSystem.exists(manifestPath)) {
			return false;
		}
		return true;
	}

	public static function scanDirectory(prefix:String, onFile:String->Void, onDir:String->Void, path:String = "") {
		var fullPath = Path.join([prefix, path]);
		if (FileSystem.exists(fullPath) && FileSystem.isDirectory(fullPath)) {
			var entries = FileSystem.readDirectory(fullPath);
			for (entry in entries) {
				if (FileSystem.isDirectory(fullPath + '/' + entry)) {
					scanDirectory(prefix, onFile, onDir, path + "/" + entry);
					onDir(path + '/' + entry);
				} else {
					onFile(path + '/' + entry);
				}
			}
		}
	}

	public static function isFolderEmpty(path:String) {
		var list = FileSystem.readDirectory(path);
		list.remove(".git");
		return list.length == 0;
	}
	public static function safelyCopyFile(from:String, to:String) {
		FileSystem.createDirectory(Path.directory(to));
		File.copy(from, to);
	}

	public static function copyRec(from:String, to:String):Void {
		FileSystem.createDirectory(from);
		FileManager.scanDirectory(from, s -> {
			FileSystem.createDirectory(Path.join([to, Path.directory(s)]));
			File.copy('$from/$s', Path.join([to, s]));
		}, s -> {});
	}
	public static function moveRec(from:String, to:String):Void {
		FileSystem.createDirectory(from);
		FileManager.scanDirectory(from, s -> {
			FileSystem.createDirectory(Path.join([to, Path.directory(s)]));
			FileSystem.rename('$from/$s', Path.join([to, s]));
		}, s -> {});
	}

}
