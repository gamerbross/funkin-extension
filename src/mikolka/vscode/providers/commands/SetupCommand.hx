package mikolka.vscode.providers.commands;

import mikolka.install.backend.TaskChips;
import vscode.OutputChannel;
import mikolka.vscode.definitions.DisposableCommand;

class SetupCommand extends DisposableCommand {
	var commandOutput:OutputChannel;

	public function new(context:vscode.ExtensionContext) {
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

	function onSetupDone() {
		Interaction.displayInformation("Funkin setup completed successfully!").then(_ -> {
			commandOutput.hide();
		});
	}

	function chip_done(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine("[SETUP] Setup done!");
		resolve();
	}

	function pickHaxelibRepo(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		var cfg = new VsCodeConfig();

		trace("Request setup");

		Interaction.requestFile("Select fcpkg package to install", "", "Funkin Compiler Package", "fcpkg", path -> {
			if (!FileSystem.exists(path)) {
				deny("This fcpkg does not exist!");
			} else {
				var haxelib_name = Path.withoutExtension(Path.withoutDirectory(path));
				var haxelib_path = Path.join([internalHaxelibsRoot, haxelib_name]);
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

				resolve();
			}
		}, deny.bind("No haxelib folder was set"));
	}

	override function dispose() {
		super.dispose();
		commandOutput.dispose();
	}
}
