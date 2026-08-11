package mikolka;

import mikolka.vscode.providers.tasks.PCCopyTask;
import mikolka.vscode.providers.DebuggerSetup;
import mikolka.helpers.ModeManager.FilePatternMode;
import mikolka.vscode.providers.commands.*;
import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.tasks.AdbTask;
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
			"funk.cfg"
		));

		// Mode2
		modules.registerMode(new FilePatternMode(
			VSLICE_MOD,
			"_polymod_meta.json"
		));		
		modules.registerMode(new FilePatternMode(
			FUNKIN_ASSETS,
			"exclude/ui/credits/credits.json"
		));
		modules.activateGlobal = context -> {
			
			var result = [
				new DiagnosticRegistry(context), 
				
				
				new VsHaxeProvider(context),
				new DebuggerSetup(context),
				
				new AdbTask(context),
				new PCCopyTask(context),
			];
			
			return result;
		}
		var startup = new StartupInit(context);
		
		modules.standbyProviders = [
			startup,
			new CommandRegistry(context),
			new NewCommand(context),
			new SetHaxelibCommand(context),
			new SetupCommand(context),
			
		];
		startup.runStartupChecks();
		modules.scanForModeChanges(context);
	}
}
