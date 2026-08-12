package mikolka.vscode.providers;

import vscode.ProgressLocation;
import mikolka.config.MetadataParser;
import mikolka.config.VsCodeConfig;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import mikolka.vscode.definitions.DisposableProvider;

using StringTools;

class VsHaxeProvider extends DisposableProvider {
	public var haxeApi:Vshaxe;

	private var haveIAskedAboutHxc:Bool = false;

	public function new(context:vscode.ExtensionContext) {
		Vscode.extensions.getExtension("nadako.vshaxe").activate().then((x) -> {
			trace(Vscode.extensions.getExtension("nadako.vshaxe").extensionPath);
			onVshaxeActive(context);
		});

		super(context, Vscode.window.onDidChangeActiveTextEditor(e -> {
			if (e.document.fileName.endsWith(".hxc") && !haveIAskedAboutHxc) {
				haveIAskedAboutHxc = true;
				checkVshaxePatch();
			}
		}));
	}

	private function onVshaxeActive(context:vscode.ExtensionContext) {
		haxeApi = Vscode.extensions.getExtension("nadako.vshaxe").exports;

		addDisposable(haxeApi.registerDisplayArgumentsProvider("Funkin", {
			description: "Activates Autocompletion using FNF source code",
			activate: provideArguments -> {
				var current_manifest = MetadataParser.readActiveMetadata();
				var hxml_path = current_manifest.hxmlFile != null ? Path.join([VsCodeConfig.instance.HAXELIB_PATH, current_manifest.hxmlFile]) : context.asAbsolutePath("assets/funkin-index.hxml");
				if (VsCodeConfig.instance.DEBUG)
					trace(hxml_path);
				var hxml = File.getContent(hxml_path);
				provideArguments(haxeApi.parseHxmlToArguments(hxml));
			},
			deactivate: () -> {}
		}));
		addDisposable(haxeApi.registerHaxeInstallationProvider("Funkin IDE Haxe", {
			activate: provideInstallation -> {
				checkVshaxeHaxelib(context, () -> {
					var file = Sys.systemName() == "Windows" ? "haxe.exe" : "haxe";

					provideInstallation({
						haxeExecutable: Path.join([context.getGlobalStore().getCustomHaxeRootPath(), file])
					});
				}, error -> {
					Interaction.displayError(error);
					provideInstallation({});
				});
			},
			deactivate: () -> {}
		}));
	}

	/**
		Checks and asks to apply a patch for the .hxc files.

		This also makes a backup in case anything goes wrong.
	**/
	private function checkVshaxePatch() {
		//
		final jsPath = Path.join([Vscode.extensions.getExtension("nadako.vshaxe").extensionPath, "server/bin/"]);
		final jsBakPath = Path.join([jsPath, "server.js.bak"]);

		if (FileSystem.exists(jsBakPath))
			return;
		Interaction.requestConfirmation("Funkin Compiler",
			"Looks like you don't have a patch applied to 'vshaxe language server' yet!\n" +
			"The program will now add support for .hxc files to it.\n\nDo you want to proceed?",
			() -> {
				final jsScriptPath = Path.join([jsPath, "server.js"]);
				// Make a backup
				File.copy(jsScriptPath, jsBakPath);

				var vshaxeJsServerCode = File.getContent(jsScriptPath);
				vshaxeJsServerCode = ~/function ([A-Z][a-z])\(e\){return e\.endsWith\("\.hx"\)}/g.replace(vshaxeJsServerCode,
					'function $1(e){return e.endsWith(".hx") || e.endsWith(".hxc")}');

				File.saveContent(jsScriptPath, vshaxeJsServerCode);
				Vscode.commands.executeCommand("workbench.action.reloadWindow");
			}, () -> {});
	}

	private function checkVshaxeHaxelib(context:vscode.ExtensionContext, onValid:Void->Void, onError:String->Void) {
		var store = context.getGlobalStore();
		var current_version = store.getHaxeVersion();
		if (current_version != "1.0.0" && current_version != null) {
			store.clearCustomHaxe();
			current_version = null;
		}
		if (current_version == null) {
			Interaction.displayInformation("Funkin IDE Haxe installation started!");
			var system_part:Null<String> = switch (Sys.systemName()) {
				case "Windows": "windows-x64";
				case "Linux": "linux-x64";
				case "Mac": "mac-arm";
				case _: null;
			};
			if (system_part == null) {
				onError("Unknown OS. Funkin IDE Haxe will not be available!");
				return;
			}
			var target_file = Path.join([store.getTempPath(), "haxe.zip"]);
			var curl_out = new StringBuf();
			Process.runCurl('https://github.com/FunkinCompiler/haxe-bin/releases/download/4.3.7/${system_part}.zip', target_file, null, s -> {
				curl_out.add(s);
			}, () -> {
				if (!FileSystem.exists(target_file)) {
					onError("Failed to download custom Haxe: "+curl_out.toString());
					return;
				}
				ZipTools.extractZip(File.read(target_file), store.getCustomHaxeRootPath());
                if(Sys.systemName() != "Windows") {
                    var success = Process.checkCommand('chmod +x "${Path.join([store.getCustomHaxeRootPath(),"haxe"])}"',null);
                    if(!success) {
						onError("Failed to make haxe executable!");
						return;
					}
                }
				store.setHaxeVersion("1.0.0");
				store.clearTempPath();
				
			});
		}
		onValid();
	}
}
