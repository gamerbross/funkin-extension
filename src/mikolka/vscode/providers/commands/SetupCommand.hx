package mikolka.vscode.providers.commands;

import vscode.Uri;
import mikolka.install.backend.TaskChips;
import mikolka.install.chips.MiscEnvChecks;
import mikolka.install.files.ManifestParser;
import vscode.OutputChannel;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.Exception;
import mikolka.config.VsCodeConfig;
import mikolka.config.FcpkgManager;
import mikolka.vscode.definitions.DisposableCommand;

class SetupCommand extends DisposableCommand {
	var commandOutput:OutputChannel;

	var fcpkg:FcpkgManager;

	public function new(context:vscode.ExtensionContext) {
		fcpkg = new FcpkgManager(context);
		commandOutput = Vscode.window.createOutputChannel("Funkin compiler");
		super(context, makeCommand("setup", context, command_setup));
	}

	private function writeLine(txt:String) {
		trace(txt);
		commandOutput.appendLine(txt);
	}

	private function command_setup() {
		// var console = Out
		commandOutput.show();
		var taskResult = TaskChips.runChips([pickHaxelibRepo]);
		taskResult.then(onSetupDone, onSetupFail);
	}

	function onSetupFail(reason:String) {
		commandOutput.show();
		Interaction.displayError(reason).then(_ -> {
			commandOutput.hide();
			commandOutput.clear();
		});
	}

	function onSetupDone(_:Dynamic) {
		Interaction.displayInformation("Funkin setup completed successfully!").then(_ -> {
			commandOutput.hide();
		});
	}

	function chip_done(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine("[SETUP] Setup done!");
		resolve();
	}

	function installFcpkg(ctx:TaskChips, path:String) {
		var haxelib_name = Path.withoutExtension(Path.withoutDirectory(path));
		var cfg = new VsCodeConfig();
		var haxelib_path = Path.join([fcpkg.getHaxelibRootPath(), haxelib_name]);
		var environmentTesting = new MiscEnvChecks(writeLine);
		cfg.HAXELIB_PATH = haxelib_path;

		FileSystem.createDirectory(haxelib_path);
		Process.setHaxelibPath(haxelib_path);

		ctx.appendTask(environmentTesting.testEnvironment);
		ctx.appendTask((_resolve, _deny, _ctx) -> {
			try {
				ZipTools.extractZip(File.read(path), haxelib_path);
				var manifest = new ManifestParser(haxelib_path);
				var installTasks = manifest.buildTaskList(writeLine);
				if (cfg.DEBUG) {
					writeLine('[DEBUG] Built ${installTasks.length} install tasks.');
					writeLine('[DEBUG] Starting from stage ${manifest.manifest.installStage}');
				}
				_ctx.appendManyTasks(installTasks);
				_resolve();
			} catch (x:Exception) {
				_deny("Unpacking fcpkg zip failed! " + x.message);
			}
		});
		ctx.appendTask(chip_done);
	}

	function downloadFcpkg(remote_source:Uri, onComplete:(fcpkgPath:String) -> Void) {
		var name = Path.withoutDirectory(remote_source.path);
		var agent = "Mozilla/5.0 (X11; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0";
		var haxelib_path = Path.join([fcpkg.getHaxelibRootPath(), Path.withoutExtension(name)]);
		FileSystem.createDirectory(haxelib_path);

		writeLine("Downloading fcpkg...");
		Process.runCommand('curl -o temp.fcpkg -A ${agent} "${remote_source.toString()}"', haxelib_path, writeLine,
			onComplete.bind(Path.join([haxelib_path, "temp.fcpkg"])));
	}

	function pickHaxelibRepo(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		var cfg = new VsCodeConfig();

		trace("Request setup");
		ListPicker.pickFcpkgUri("Select fcpkg package to install", target -> {
			if (target == null)
				deny("No haxelib folder was set");
			else if (target.scheme == "file") {
				var path = target.fsPath;
				if (!FileSystem.exists(path)) {
					deny("This fcpkg does not exist!");
				} else {
					installFcpkg(ctx, path);
					resolve();
				}
			} else {
				downloadFcpkg(target, fcpkgPath -> {
					if (!FileSystem.exists(fcpkgPath)) {
						deny("Could not download the package!");
					} else {
						installFcpkg(ctx, fcpkgPath);
						resolve();
					}
				});
			}
		});
	}

	override function dispose() {
		super.dispose();
		commandOutput.dispose();
	}
}
