package mikolka.vscode.providers.commands;

import sys.FileSystem;
import haxe.io.Path;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
import mikolka.config.VsCodeConfig;
import mikolka.helpers.Process;
import vscode.OutputChannel;
import vscode.Uri;
import mikolka.commands.*;

class CommandRegistry extends DisposableCommand {
	
	public function new(context:vscode.ExtensionContext) {
		super(context);
		addDisposable(makeCommand("haxelib.inspect", context, () -> {
			Vscode.env.openExternal(Uri.file(getHaxelibRootPath(context)));			
		}));
	}
}