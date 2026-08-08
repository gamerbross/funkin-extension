package mikolka.helpers;

import js.lib.Promise;
import mikolka.vscode.definitions.DisposableProvider;


typedef ModeCheck = (vscode.ExtensionContext -> Thenable<Array<vscode.Uri>>);

interface IMode {
	function id():String;
	// Called when mode becomes active; return providers to manage
	// How to detect presence of this mode in a workspace
	function detector():ModeCheck;
}

class FilePatternMode implements IMode {
	var _id:String;
	var _pattern:String;

	public function new(id:String, pattern:String) {
		_id = id;
		_pattern = pattern;
	}

	public function id() return _id;
	public function detector() {
		return (context) -> Vscode.workspace.findFiles(_pattern);
	}
}

class ModeManager {

	private var _modes:Map<String, IMode> = new Map();
	private var _activeModes:Array<String> = new Array();
	private var _globalProviders:Null<Array<DisposableProvider>> = null;
	public var standbyProviders:Null<Array<DisposableProvider>> = [];

    public function new() {
        
    }

	public function registerMode(mode:IMode):Void {
		_modes.set(mode.id(), mode);
	}
	public function isModeActive(mode:String):Bool {
		return _modes.exists(mode);
	}

	public function scanForModeChanges(context:vscode.ExtensionContext):Void {
		for (modeId in _modes.keys()) {
			var mode = _modes.get(modeId);
			mode.detector()(context).then(files -> {
				var active = files.length > 0;
				var currentlyActive = _activeModes.contains(modeId);
				if (active && !currentlyActive) {
					_activeModes.push(modeId);
				} else if (!active && currentlyActive) {

					_activeModes.remove(modeId);
				}
				_checkGlobalHook(context);
			});
		}
	}
	function name() {
		
	}
	function _checkGlobalHook(context:vscode.ExtensionContext):Void {
		if (((_activeModes.length) > 0) && _globalProviders == null) {
			_globalProviders = activateGlobal(context);
		} else if (_activeModes.length == 0 && _globalProviders != null) {
			for (x in _globalProviders) x.dispose();
			_globalProviders = null;
		}
	}

	public dynamic function activateGlobal(context:vscode.ExtensionContext):Array<DisposableProvider> {
        return [];
	}
}
