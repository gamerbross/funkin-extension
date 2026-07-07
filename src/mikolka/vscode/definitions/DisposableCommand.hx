package mikolka.vscode.definitions;

import vscode.Disposable;

abstract class DisposableCommand extends DisposableProvider {
    private function makeCommand(name:String, context:vscode.ExtensionContext, action:() -> Void):Disposable
		return Vscode.commands.registerCommand("mikolka." + name, action);
}