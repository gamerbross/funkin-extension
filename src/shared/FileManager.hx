package shared;

import js.node.Fs;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File as SysFile;
#if vscode
import mikolka.helpers.Language;
#end

using shared.ShellUtils;


class FileManager {
	public static function deleteDirRecursively(path:String):Void {
		scanDirectory(path, s -> FileSystem.deleteFile(Path.join([path, s])), s -> FileSystem.deleteDirectory(Path.join([path, s])));
		FileSystem.deleteDirectory(path);
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
			entries.forEach(entry -> {
				if (FileSystem.isDirectory(fullPath + '/' + entry)) {
					scanDirectory(prefix, onFile, onDir, path + "/" + entry);
					onDir(path + '/' + entry);
				} else {
					onFile(path + '/' + entry);
				}
			});
		}
	}

	public static function isFolderEmpty(path:String) {
		var list = FileSystem.readDirectory(path);
		list.remove(".git");
		return list.length == 0;
	}
	public static function safelyCopyFile(from:String, to:String) {
		FileSystem.createDirectory(Path.directory(to));
		SysFile.copy(from, to);
	}

	#if vscode
	/**
		Converts given target to the path from the current workspace folder,
		If not opened, request a user to select one.
	**/
	// Copied from vshaxe extension
	public static function getProjectPath(onResult:(String) -> Void) {
		switch Vscode.workspace.workspaceFolders {
			case null | []:
				Vscode.window.showOpenDialog({
					canSelectFolders: true,
					canSelectFiles: false
				}).then(folders -> {
					if (folders != null && folders.length > 0) {
						Vscode.commands.executeCommand("vscode.openFolder", folders[0]);
						onResult(folders[0].fsPath);
					}
				});
			case [folder]:
				onResult(folder.uri.fsPath);
			case folders:
				final options = {
					placeHolder: Language.UTILS_SELECT_WORKSPACE_FOLDER,
				}
				Vscode.window.showWorkspaceFolderPick(options).then(function(folder) {
					if (folder == null)
						return;
					onResult(folder.uri.fsPath);
				});
		}
	}
	#end
	public static function copyRec(from:String, to:String):Void {
		FileSystem.createDirectory(from);
		FileManager.scanDirectory(from, s -> {
			FileSystem.createDirectory(Path.join([to, Path.directory(s)]));
			SysFile.copy('$from/$s', Path.join([to, s]));
		}, s -> {});
	}
	public static function syncRec(from:String, to:String,onFileCopied:String -> Void = null,onFIleRemoved:String -> Void) {

			FileSystem.createDirectory(from);
			FileManager.scanDirectory(from, s -> {
				if(StringTools.contains(s,".git")) return;
				
				var sourcePath = '$from/$s';
				var targetPath = Path.join([to, s]);
				var shouldCopy = true;
				if(FileSystem.exists(targetPath)){
					var sourceProbe:Date = Fs.statSync(sourcePath).mtime;
					var targetProbe:Date = Fs.statSync(targetPath).mtime;
					shouldCopy = sourceProbe.getTime() > targetProbe.getTime();
				}
				if(shouldCopy){
					if(onFileCopied != null) onFileCopied(s);
					FileSystem.createDirectory(Path.join([to, Path.directory(s)]));
					SysFile.copy(sourcePath, targetPath);
				}
			}, s -> {});
			FileManager.scanDirectory(to,s ->{
				var sourcePath = '$from/$s';
				var targetPath = Path.join([to, s]);
				if(!FileSystem.exists(sourcePath)){
					FileSystem.deleteFile(targetPath);
					onFIleRemoved(s);
				}
			},s ->{});
	}
	public static function moveRec(from:String, to:String):Void {
		FileSystem.createDirectory(from);
		FileManager.scanDirectory(from, s -> {
			FileSystem.createDirectory(Path.join([to, Path.directory(s)]));
			FileSystem.rename('$from/$s', Path.join([to, s]));
		}, s -> {});
	}

}
