package mikolka;

import mikolka.helpers.ModeManager.FilePatternMode;
import mikolka.vscode.providers.commands.*;
import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.mode1.TaskRegistry;
import mikolka.vscode.providers.mode1.DebuggerSetup;
import mikolka.vscode.providers.VsHaxeProvider;
import mikolka.vscode.providers.diagnostics.DiagnosticRegistry;

class Main {
	public static final FUNK_PROJECT = "mode1";
	public static final VSLICE_MOD = "mode2";
	public static final FUNKIN_ASSETS = "mode3";
	public static var modules:ModeManager;

	static function main() {}

	@:expose("activate")
	static function activate(context:vscode.ExtensionContext) {
		trace("Active");
		modules = new ModeManager();
		modules.registerMode(new FilePatternMode(
			FUNK_PROJECT,
			"funk.cfg",
			context -> {
				trace("Mode1 activate");
				var tasks = new TaskRegistry(context);
				return [tasks];
			},
			providers -> trace("Mode1 deactivated")
		));

		// Mode2
		modules.registerMode(new FilePatternMode(
			VSLICE_MOD,
			"_polymod_meta.json",
			context -> {
				trace("Mode2 activate");
				// return providers for mode2 as you add them
				return [];
			}
		));		
		modules.registerMode(new FilePatternMode(
			FUNKIN_ASSETS,
			"exclude/data/credits.json",
			context -> {
				trace("Mode3 activate");
				// return providers for mode2 as you add them
				return [];
			}
		));
		modules.activateGlobal = context -> {
			var startup = new StartupInit(context);

			var result = [
				new DiagnosticRegistry(context), 
				startup,

				new CommandRegistry(context),
				new NewCommand(context),
				new SetHaxelibCommand(context),
				new SetupCommand(context),

				new VsHaxeProvider(context),
				new DebuggerSetup(context)
			];

			startup.runStartupChecks();
			return result;
		}

		modules.scanForModeChanges(context);
	}
}
