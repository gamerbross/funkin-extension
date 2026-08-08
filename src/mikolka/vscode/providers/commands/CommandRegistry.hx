package mikolka.vscode.providers.commands;


import mikolka.config.FcpkgManager;
import vscode.Uri;
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