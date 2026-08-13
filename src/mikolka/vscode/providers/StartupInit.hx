package mikolka.vscode.providers;

import sys.FileSystem;
import sys.io.File;
import mikolka.vscode.definitions.DisposableProvider;
import haxe.io.Path;
import mikolka.helpers.Process;
import mikolka.helpers.LangStrings;
import mikolka.config.VsCodeConfig;
using StringTools;

/**
 * This class manages the startup of the Funkin compiler
 */
class StartupInit extends DisposableProvider {
    var ctx:vscode.ExtensionContext;
    public function new(context:vscode.ExtensionContext) {
        super(context);
        ctx = context;
    }
    public function runStartupChecks() {
        var cfg = VsCodeConfig.instance;
        if(cfg.HAXELIB_PATH == null || cfg.HAXELIB_PATH == ""){
            // Haxelib not inited
            Vscode.window.showWarningMessage(LangStrings.STARTUP_SETUP_MISSING_TITLE,{
                detail: LangStrings.STARTUP_SETUP_MISSING,
                modal: true
            },"Yes","No").then(s ->{
                if(s == "Yes") Vscode.commands.executeCommand("mikolka.setup");
            });
            return;
        }

        Vscode.window.showInformationMessage("Funkin Compiler is now running!");
        //
    }
}