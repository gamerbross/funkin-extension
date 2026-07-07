package mikolka.vscode.providers.commands;

import mikolka.vscode.definitions.DisposableCommand;
import mikolka.config.VsCodeConfig;
import mikolka.install.files.MetadataParser;
import mikolka.vscode.ui.ListPicker.ListItem;
import haxe.io.Path;
import mikolka.config.FcpkgManager;

class SetHaxelibCommand extends DisposableCommand {

    var fcpkg:FcpkgManager;
    public function new(context:vscode.ExtensionContext) {
		super(context);
        fcpkg = new FcpkgManager();
        addDisposable(makeCommand("setHaxelib", context, command_setHaxelib));
    }
    function command_setHaxelib() {
        var cfg = new VsCodeConfig();
        var folder_list = fcpkg.getInstalledHaxelibs();
        if(folder_list.length == 0)
            Interaction.displayError("No Fcpkg package was installed!");
        else if (folder_list == 1) 
            setHaxelibFolder(folder_list[0]);
        else {
            var base_list:Array<ListItem> = makeHaxelibList();
            if(cfg.HAXELIB_PATH != "") 
                base_list.insert(0,{label: "Use previous",id: "last",onSelect:setConfigHaxelib});
            ListPicker.pickItem("Select haxelib to set",base_list,setHaxelibFolder);
        }
		
    }
    function makeHaxelibList(folders:Array<String>):Array<ListItem> {
        return folders.map(folder_name -> {
            var full_path = Path.join([fcpkg.getHaxelibRootPath(),folder_name]);
            var meta = MetadataParser.readHaxelibMetadata(full_path);
            var x:ListItem = {
                id: folder_name,
                label: meta?.name ?? folder_name,
                description: meta?.description
            };
            return x;
        });
        
    }
    function setHaxelibFolder(folder_name:String) {
        var full_path = Path.join([fcpkg.getHaxelibRootPath(),folder_name]);
        setHaxelibPath(full_path);
        
    }
    function setConfigHaxelib() {
        setHaxelibPath(new VsCodeConfig().HAXELIB_PATH);
    }
    function setHaxelibPath(full_path:String) {
        var cfg = new VsCodeConfig();
        var result = Process.setHaxelibPath(full_path);
		if (!result)
			Interaction.displayError("Failed to set haxelib path!");
		else{
            cfg.HAXELIB_PATH = full_path;
			Vscode.commands.executeCommand("haxe.restartLanguageServer");
        }
    }
}