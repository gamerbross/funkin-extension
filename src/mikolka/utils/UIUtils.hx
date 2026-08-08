package mikolka.utils;

import vscode.Event;
import vscode.QuickInputButton;
import haxe.ds.ReadOnlyArray;
import haxe.DynamicAccess;
import vscode.ThemeIcon;
import mikolka.vscode.ui.Interaction.QuickInputActionBtn;


typedef ButtonBox = {

	/**
	 * Buttons for actions in the UI.
	 */
	var buttons:ReadOnlyArray<QuickInputButton>;

	/**
	 * An event signaling when a button was triggered.
	 */
	var onDidTriggerButton(default, null):Event<QuickInputButton>;

    /**
	 * If the UI should show a progress indicator. Defaults to false.
	 *
	 * Change this to true, e.g., while loading more data or validating
	 * user input.
	 */
	var busy:Bool;
}
class UIUtils {
    
    public static function configureSelectFileButton(item:ButtonBox,title:String,filters:DynamicAccess<Array<String>>
            ,pickingFile:Bool,onSelect:String->Void,makeBusy:Bool = false) {
        var buttons:Array<QuickInputActionBtn> = [{
			tooltip: "Browse",
			iconPath: ThemeIcon.Folder,
			action: () -> {
				if(makeBusy) item.busy = true;
				Vscode.window.showOpenDialog({
					canSelectFolders: !pickingFile,
					canSelectFiles: pickingFile,
                    filters: filters,
                    title: title
				}).then(folders -> {
					if (folders != null && folders.length > 0) {
						onSelect(folders[0].fsPath);
					}
					if(makeBusy) item.busy = false;
				});
			}
		}];
        item.buttons = buttons;
        item.onDidTriggerButton(e -> {
			var x:QuickInputActionBtn = cast e;
			x.action();
		});
    }
}