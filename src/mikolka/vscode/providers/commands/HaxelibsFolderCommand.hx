package mikolka.vscode.providers.commands;

import vscode.Uri;
import mikolka.vscode.definitions.DisposableCommand;

class HaxelibsFolderCommand extends DisposableCommand {

	public function new(context:vscode.ExtensionContext) {
		super(context);
		addDisposable(makeCommand("haxelib.inspect", context, () -> {
			Vscode.env.openExternal(Uri.file(context.getGlobalStore().getHaxelibRootPath()));			
		}));
	}
}