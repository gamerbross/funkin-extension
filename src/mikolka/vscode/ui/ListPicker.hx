package mikolka.vscode.ui;

import vscode.ThemeIcon;

// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
typedef ListItem = {
    label:String,
    ?description:String,
	?detail:String,
    id:String,
    onSelect:Null<() -> Void>
} 
class ListPicker {
    public static function pickItem(title:String,options:Array<ListItem>,defaultOnSelection:(x:Null<String>) -> Void){
        //var vscodeOptions:List<
		return Vscode.window.showQuickPick(options,{
			title: title,
            matchOnDescription:true
		}).then(s -> {
            if(s.onSelect == null) defaultOnSelection(s.id);
            else s.onSelect();
        },(z) -> defaultOnSelection(null));
	}
}