package mikolka.vscode.ui;

import vscode.QuickInputButton;
import vscode.QuickPickItem;
import js.lib.Promise;
import vscode.Uri;
import vscode.ThemeIcon;
import js.lib.Promise.Thenable;

using mikolka.utils.UIUtils;

typedef QuickInputActionBtn = {
	> QuickInputButton,
	action:()->Void
} 
class Interaction {

	public static function displayError(msg:String):Thenable<Any> {
		return Vscode.window.showErrorMessage(msg);
	}
	public static function displayInformation(msg:String):Thenable<Any> {
		return Vscode.window.showInformationMessage(msg);
	}
	public static function displayErrorAlert(title:String,message:String):Thenable<Any> {
		return Vscode.window.showErrorMessage(title,{
			modal: true,
			detail: message
		});
	}

	// Returns the input from user (or null if canceled)
	public static function requestInput(prompt:String,next:(input:Null<String>) -> Void) {
		Vscode.window.showInputBox({
			title: prompt
		}).then(next,(out) ->{
			displayError("Action canceled!");
		});
	}
	public static function requestFile(prompt:String,initialValue:String,fileFormatName:String,fileExtension:String
			,next:(inputPath:String) -> Void,onCancel:Void -> Void){
		var box = Vscode.window.createInputBox();
		var acceptedValue = false;
		box.prompt = prompt;
		box.value = initialValue;
		box.placeholder = "Enter a path to a file (or use the folder button to pick one)";
		box.configureSelectFileButton("Pick a file",{
			'${fileFormatName}': [fileExtension]
		},true,s -> {
			box.value = s;
		},true);
		box.onDidAccept(e -> {
			acceptedValue = true;
			next(box.value);
			box.dispose();
		});
		box.ignoreFocusOut = true;
		box.onDidHide(e -> {
			if(!acceptedValue) {
				onCancel();
				box.dispose();
			}
		});
		box.show();
	}
	public static function requestDirectory(prompt:String,initialValue:String,next:(inputPath:String) -> Void,onCancel:Void -> Void) {
		var box = Vscode.window.createInputBox();
		var acceptedValue = false;
		box.prompt = prompt;
		box.value = initialValue;
		box.placeholder = "Enter a path to a directory (or use the folder button to pick one)";
		box.configureSelectFileButton("Pick a folder",null,false,s -> {
			box.value = s;
		},true);
		box.onDidAccept(e -> {
			acceptedValue = true;
			next(box.value);
			box.dispose();
		});
		box.ignoreFocusOut = true;
		box.onDidHide(e -> {
			if(!acceptedValue) {
				onCancel();
				box.dispose();
			}
		});
		box.show();
	}
	public static function requestConfirmation(title:String,prompt:String,onYes:() -> Void,onNo:() -> Void) {
		Vscode.window.showWarningMessage(title,{modal: true,detail: prompt},"Yes","No").then((result) -> {
			if(result == "Yes"){
				onYes();
			}
			else if(result == "No"){
				onNo();
			}
			else Interaction.displayError("Action aborted!");
		});
	}
}
