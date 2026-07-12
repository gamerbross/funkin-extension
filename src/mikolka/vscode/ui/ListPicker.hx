package mikolka.vscode.ui;

import vscode.Uri;
import haxe.Json;
import haxe.Exception;
import js.html.Request;
import haxe.Http;
import mikolka.config.VsCodeConfig;
import vscode.ThemeIcon;
import vscode.QuickPickItem;

using mikolka.utils.UIUtils;

// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
typedef ListItem = {
	> QuickPickItem,
	id:String,
	?onSelect:Null<() -> Void>
}

typedef FcpkgManifest = {
	> QuickPickItem,
	url:String
}

class ListPicker {
	public static function makePickItem(title:String, options:Array<ListItem>, defaultOnSelection:(x:Null<String>) -> Void) {
        var ext = Vscode.window.createQuickPick();
        ext.title = title;
        ext.items = options;
        ext.matchOnDescription = true;
        ext.ignoreFocusOut = true;
        ext.onDidAccept(s -> {
            if(ext.selectedItems.length == 0){
                defaultOnSelection(null);
            }
            else{
                var vItem = ext.selectedItems[0];
                if (vItem.onSelect == null)
					defaultOnSelection(vItem.id);
				else
					vItem.onSelect();
            }
            ext.dispose();
        });
        return ext;
	}
    public static function pickHaxelibFolder(options:Array<ListItem>, onOptionSelection:(x:Null<String>) -> Void,onManualEntry:(path:String) -> Void) {
        var window = makePickItem("Select Funkin package to use",options,onOptionSelection);
        window.configureSelectFileButton("Select haxelib folder",null,false,s -> {
            window.dispose();
            onManualEntry(s);
        });
        window.show();
        return window;
    }

	public static function pickFcpkgUri(title:String, onResult:(target:Null<Uri>) -> Void) {
		var ext = Vscode.window.createQuickPick();
		// TODO Likely a weak point. Fix in case threads are async.
        ext.ignoreFocusOut = true;
		ext.title = title;

		var remoteRequests = new VsCodeConfig().FCPKG_SOURCES.map(s -> new Http(s));
		if (remoteRequests.length > 0)
			ext.busy = true;
		var remainingSources = remoteRequests.length;

		for (http in remoteRequests) {
			http.onError = msg -> {
				remainingSources -= 1;
				trace(msg);
			}
			http.onData = data -> {
				try {
					trace(data);
					var list:Array<FcpkgManifest> = Json.parse(data);
					ext.items = ext.items.concat(list);
					ext.show();
				} catch (x:Exception) {
					trace(x.details());
				}
				remainingSources -= 1;
				if (remainingSources <= 0)
					ext.busy = false;
			}

			http.request();
		}
        ext.onDidAccept(_ -> {
            if(ext.selectedItems.length == 0){
                onResult(null);
            }
            else{
                var vItem = ext.selectedItems[0];
				onResult(Uri.parse(vItem.url));
            }
            ext.dispose();
        });
        ext.configureSelectFileButton("Select .fcpkg file",{"Funkin Compiler package":["fcpkg"]},true,fsPath -> {
            var result = Uri.file(fsPath);
			onResult(result);
			ext.dispose();
        },false);
		ext.show();
	}
}

