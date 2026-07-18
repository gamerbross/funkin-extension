package mikolka.vscode.providers;

import mikolka.config.MetadataParser;
import mikolka.config.VsCodeConfig;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
using StringTools;

class VsHaxeProvider extends DisposableProvider {
    public var haxeApi:Vshaxe;
    private var haveIAskedAboutHxc:Bool = false;
    public function new(context:vscode.ExtensionContext) {
        Vscode.extensions.getExtension("nadako.vshaxe").activate().then((x) ->{
            trace(Vscode.extensions.getExtension("nadako.vshaxe").extensionPath);
            onVshaxeActive(context);
        });

        super(context,Vscode.window.onDidChangeActiveTextEditor(e ->{
            if(e.document.fileName.endsWith(".hxc") && !haveIAskedAboutHxc){
                haveIAskedAboutHxc = true;
                checkVshaxePatch();
            }
        }));
    }

    private function onVshaxeActive(context:vscode.ExtensionContext) {
        haxeApi = Vscode.extensions.getExtension("nadako.vshaxe").exports;

        var cancelHook = haxeApi.registerDisplayArgumentsProvider("Funkin",{
            description: "Activates Autocompletion using FNF source code",
            activate: provideArguments -> {
                var current_manifest = MetadataParser.readActiveMetadata();
                var hxml_path = current_manifest.hxmlFile != null 
                    ? Path.join([VsCodeConfig.instance.HAXELIB_PATH,current_manifest.hxmlFile])
                    : context.asAbsolutePath("assets/funkin-index.hxml");
                if(VsCodeConfig.instance.DEBUG) 
                    trace(hxml_path);
                var hxml = File.getContent(hxml_path);
                provideArguments(haxeApi.parseHxmlToArguments(hxml));
            },
            deactivate: () -> {}
        });
        addDisposable(cancelHook);
    }
    /**
        Checks and asks to apply a patch for the .hxc files.

        This also makes a backup in case anything goes wrong.
    **/
    private function checkVshaxePatch() {
        // 
        final jsPath = Path.join([Vscode.extensions.getExtension("nadako.vshaxe").extensionPath,"server/bin/"]);
        final jsBakPath = Path.join([jsPath,"server.js.bak"]);
        
        if(FileSystem.exists(jsBakPath)) return;
        Interaction.requestConfirmation(
            "Funkin Compiler",
            "Looks like you don't have a patch applied to 'vshaxe language server' yet!\n"+
            "The program will now add support for .hxc files to it.\n\nDo you want to proceed?",
            () -> {
                final jsScriptPath = Path.join([jsPath,"server.js"]);
                // Make a backup
                File.copy(jsScriptPath,jsBakPath);

                var vshaxeJsServerCode = File.getContent(jsScriptPath);
                vshaxeJsServerCode = ~/function ([A-Z][a-z])\(e\){return e\.endsWith\("\.hx"\)}/g
                    .replace(vshaxeJsServerCode,'function $1(e){return e.endsWith(".hx") || e.endsWith(".hxc")}');

                File.saveContent(jsScriptPath,vshaxeJsServerCode);
                Vscode.commands.executeCommand("workbench.action.reloadWindow");
            },
            () ->{}
            );
    }
}