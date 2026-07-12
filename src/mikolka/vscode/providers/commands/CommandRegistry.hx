package mikolka.vscode.providers.commands;

import sys.FileSystem;
import haxe.io.Path;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
import mikolka.config.VsCodeConfig;
import mikolka.config.FcpkgManager;
import mikolka.helpers.Process;
import vscode.OutputChannel;
import vscode.Uri;
import mikolka.commands.*;
import mikolka.vscode.definitions.DisposableCommand;

class CommandRegistry extends DisposableCommand {
	var fcpkg:FcpkgManager;
	public function new(context:vscode.ExtensionContext) {
		super(context);
		fcpkg = new FcpkgManager(context);
		addDisposable(makeCommand("haxelib.inspect", context, () -> {
			Vscode.env.openExternal(Uri.file(fcpkg.getHaxelibRootPath()));			
		}));
	}
}