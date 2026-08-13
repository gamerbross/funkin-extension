package mikolka.helpers;

import vshaxe.HaxeInstallation;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

class HaxeHelper {
	static var haxeApi:Vshaxe = null;
    public static final HAXE_VERSION:String = "v1.1";
    public static final HAXE_GITHUB_TAG:String = "4.3.7-2";

    public static function getHaxelibExecutable():String {
        if(haxeApi == null) return "haxelib";
        else return haxeApi.haxelibExecutable.configuration.executable.shellPath();
    }
    public static function activate(onComplete:Void->Void) {
        Vscode.extensions.getExtension("nadako.vshaxe").activate().then((x) -> {
            haxeApi = Vscode.extensions.getExtension("nadako.vshaxe").exports;
			onComplete();
		});
    }
    static var installationStarted:Bool = false;

	public static function checkVshaxeHaxelib(context:vscode.ExtensionContext, onValid:Void->Void, onError:String->Void) {
		var store = context.getGlobalStore();
		var current_version = store.getHaxeVersion();
		if (current_version != HAXE_VERSION && current_version != null) {
			store.clearCustomHaxe();
			current_version = null;
		}

		if (current_version == null) {
            if(installationStarted){
                onError("There is a pending installation!");
                return;
            }
            installationStarted = true;
			Interaction.displayInformation("Funkin IDE Haxe installation started!");
			var system_part:Null<String> = switch (Sys.systemName()) {
				case "Windows": "windows-x64";
				case "Linux": "linux-x64";
				case "Mac": "mac-arm";
				case _: null;
			};
			if (system_part == null) {
				onError("Unknown OS. Funkin IDE Haxe will not be available!");
                installationStarted = false;
				return;
			}
			var target_file = Path.join([store.getTempPath(), "haxe.zip"]);
			var curl_out = new StringBuf();
			Process.runCurl('https://github.com/FunkinCompiler/haxe-bin/releases/download/${HAXE_GITHUB_TAG}/${system_part}.zip', target_file, null, s -> {
				curl_out.add(s);
			}, () -> {
				if (!FileSystem.exists(target_file)) {
					onError("Failed to download custom Haxe: "+curl_out.toString());
                    installationStarted = false;
					return;
				}
				ZipTools.extractZip(File.read(target_file), store.getCustomHaxeRootPath());
                if(Sys.systemName() != "Windows") {
                    var success = Process.checkCommand('chmod +x "${Path.join([store.getCustomHaxeRootPath(),"haxe"])}"',null);
                    success = success && Process.checkCommand('chmod +x "${Path.join([store.getCustomHaxeRootPath(),"haxelib"])}"',null);
                    if(!success) {
						onError("Failed to make haxe executable!");
                        installationStarted = false;
						return;
					}
                }
				store.setHaxeVersion(HAXE_VERSION);
				store.clearTempPath();
                installationStarted = false;
                onValid();
			});
            return;
		}
        installationStarted = false;
		onValid();
	}


}