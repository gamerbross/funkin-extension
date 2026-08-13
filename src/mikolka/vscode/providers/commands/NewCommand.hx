package mikolka.vscode.providers.commands;

import mikolka.vscode.definitions.DisposableCommand;
import vscode.Uri;

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
        Interaction.requestDirectory(Language.SELECT_DIRECTORY_TO_CREATE_PROJECT_IN,defaultDir,path ->{
            if(!FileManager.isFolderEmpty(path)){
                Interaction.displayErrorAlert(Language.FOLDER_NOT_EMPTY_TITLE, Language.folderNotEmptyDetail(path));
                return;
            }
            FileManager.copyRec(scaffold_path,path);
            Interaction.displayInformation(Language.DONE);
            if(path != defaultDir) Vscode.commands.executeCommand("vscode.openFolder", Uri.file(path));
        },() -> {});
    }
}