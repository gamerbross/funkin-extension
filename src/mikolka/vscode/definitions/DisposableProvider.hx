package mikolka.vscode.definitions;

import vscode.Disposable;

abstract class DisposableProvider {
    private var disposables:Array<Disposable> = [];
    private var extensionSubscriptions:Array<{function dispose():Void;}>;
    public function new(context:vscode.ExtensionContext,...hook:Disposable) {
        extensionSubscriptions = context.subscriptions;
        hook.forEach(addDisposable);
        
    }
    private function addDisposable(item:Disposable) {
        disposables.push(item);
        extensionSubscriptions.push(item);
    }
    public function dispose():Void{
        disposables.forEach(x -> {
            extensionSubscriptions.remove(x);
            x.dispose();
        });
    }
}