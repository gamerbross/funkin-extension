package mikolka.vscode.providers.commands;

import mikolka.vscode.definitions.DisposableCommand;

class NewCommand extends DisposableCommand {
    var scaffold_path:String;
    public function new(context:vscode.ExtensionContext) {
		super(context);
        scaffold_path = context.asAbsolutePath("./assets/scaffold");
        addDisposable(makeCommand("new", context, command_new));
    }
    function command_new() {
		var defaultDir = (Vscode.workspace.workspaceFolders?.length ?? 0 )>0 ?  
            Vscode.workspace.workspaceFolders[0].uri.fsPath : "";
        Interaction.requestDirectory("Select a directory to create the project in",defaultDir,path ->{
            if(!FileManager.isFolderEmpty(path)){
                Interaction.displayErrorAlert("Folder not empty", 'Make sure that ${path} doesn\'t have any files in it.');
                return;
            }
            FileManager.copyRec(scaffold_path,path);
            Interaction.displayInformation("Done!");
            if(path != defaultDir) Vscode.commands.executeCommand("vscode.openFolder", Uri.file(path));
        },() -> {});
    }
}