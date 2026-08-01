package runner.targets.android;

import haxe.extern.EitherType;
import runner.vslice.FunkinPaths;
import js.node.Buffer;
import runner.targets.TargetPlatform.SerialCallbacks;
import haxe.io.Path;
import js.node.child_process.ChildProcess as ChildProcessObject;
import js.node.ChildProcess;

class AdbTools {
	public static final mods_path:String = "/sdcard/Android/data/me.funkin.fnf/files/mods";
	public static final RUN_FNF:String = "am start -W -a android.intent.action.VIEW -c android.intent.category.DEFAULT -n me.funkin.fnf/.MainActivity";
	public static final STOP_FNF:String = "am force-stop me.funkin.fnf";

	private final io:SerialCallbacks;

	public function new(io:SerialCallbacks) {
		this.io = io;
	}

	public function makeSupportMod() {
		pushFiles(FunkinPaths.getDebugModPath(), Path.join([mods_path, "debug-mod"]));
	}

	public function dropServerIPMemo() {
		spawnSyncProcess('echo "${NetUtil.getFirstLocalIP()}" > ${Path.join([mods_path, "debug-mod/server.txt"])} ', null);
	}

	public function pushFiles(source:String, target:String, inSync:Bool = false):Int {
		var cmd = new StringBuf();
		cmd.add("adb push ");
		if (inSync)
			cmd.add("--sync ");
		cmd.addChar('"'.code);
		cmd.add(source);
		cmd.add('/." "'); // Copy content, NOT the dir itself!
		cmd.add(target);
		cmd.add('/"');
		io.onStdout(new Buffer('>>> $cmd \n'));

		var proc = ChildProcess.spawnSync(cmd.toString(), null, {
			stdio: Pipe,
			shell: true
		});

		if (hadData(proc.stdout))
			io.onStdout(Buffer.from(proc.stdout));

		if (hadData(proc.stderr))
			io.onStderr(Buffer.from(proc.stderr));

		return proc.status;
	}

	public function spawnSyncProcess(cmd:String, ?env:Null<haxe.DynamicAccess<String>>):Int {
		io.onStdout(new Buffer(" <*>> " + cmd + "\n"));

		var proc = ChildProcess.spawnSync('adb shell "$cmd"', null, {
			env: env,
			stdio: Pipe,
			shell: true
		});

		if (hadData(proc.stdout))
			io.onStdout(Buffer.from(proc.stdout));

		if (hadData(proc.stderr))
			io.onStderr(Buffer.from(proc.stderr));

		return proc.status;
	}
    private function hadData(x:EitherType<Buffer, String>):Bool {
        if(x == null) return false;
        if(Std.isOfType(x,Buffer)){
            var z = cast (x,Buffer);
            return z.length != 0;
        }
        else{
            var z = cast (x,String);
            return z.length != 0;
        }
    }
}
