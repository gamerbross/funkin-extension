package mikolka.helpers;

import js.node.ChildProcess;
import mikolka.vscode.ui.Interaction;

class Process {
	public static function runCurl(sourceUrl:String,target_file:String,cwd:Null<String> = null,onInput:String -> Void,onComplete:Void -> Void) {
		runCommand('curl',['-L', '-o' ,target_file.shellPath(), sourceUrl],cwd,onInput,onComplete);
	}
	public static function checkCommand(execName:String,cwd:Null<String> = null):Bool {
		trace(cwd);
        var proc = ChildProcess.spawnSync(execName,{
			cwd: cwd,
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		if( code != 0){
			Interaction.displayError(proc.output.toString());
		}
		return code == 0;
    }

	public static function setHaxelibPath(path:String):Bool {
        var proc = ChildProcess.spawnSync("haxelib setup",[path],{
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		if( code != 0){
			Interaction.displayError(proc.output.toString());
		}
		return code == 0;
    }
	public static function runCommand(execName:String,args:Array<String> = null,cwd:Null<String> = null,onInput:String -> Void,onComplete:Void -> Void) {
		trace(cwd);
        var proc = ChildProcess.spawn(execName,args,{
			cwd: cwd,
			stdio: Pipe,
			shell: true
		});

		//proc.on('SIGINT',);
    	proc.on('exit',onComplete);
		proc.stdout.on("data", (data) -> {
			onInput(data);
		});
    }

	public static function isPureHaxelib():Bool {
        var proc = ChildProcess.spawnSync("haxelib list",{
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		var out = Std.string(proc.stdout);
		return code == 0 && out.length == 0;
    }
	public static function resolveCommand(command:String):String {
		trace("*>> "+command);
        var proc = ChildProcess.spawnSync(command,{
			cwd: Sys.getCwd(),
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		var out = Std.string(proc.stdout);
		return out;
    }
}