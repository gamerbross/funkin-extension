package runner.targets.desktop;

import haxe.io.Path;
import sys.FileSystem;
import runner.vslice.FunkinPaths;
import runner.targets.TargetPlatform.SerialCallbacks;
import js.node.child_process.ChildProcess;
import js.node.stream.Readable.ReadableEvent;
import js.node.ChildProcess;
import js.node.child_process.ChildProcess as ChildProcessObject;

class LocalPlatform implements TargetPlatform {

    private final args:FNFLaunchRequestArguments;
    private final io:SerialCallbacks;
    private var proc:Null<ChildProcessObject>;
    
    public function new(args:FNFLaunchRequestArguments,io:SerialCallbacks) {
        this.args = args;
        this.io = io;
    }

    public function installDebugServerMod():Void{
		FileManager.copyRec(FunkinPaths.getDebugModPath(),
			Path.join([FunkinPaths.getModFolderPath(args.cwd), "debug"]));
    }   
	public function isDebugServerPresent():Bool{
        return FileSystem.exists(Path.join([FunkinPaths.getModFolderPath(args.cwd), "debug"]));
    }
    public function start():Bool{
		final env = new haxe.DynamicAccess();
		for (key in js.Node.process.env.keys())
			env[key] = js.Node.process.env[key];

        final executable_cwd = FunkinPaths.getExecutableFolderPath(args.cwd);
        final cwd = args.cwd;
		final execName = args.execName;
		final cmd_prefix = args.cmd_prefix;
		
		spawnProcess('$cmd_prefix ./$execName',executable_cwd,env);
		return true;
    }
    public function close():Void{
        proc?.kill();
    }

    function spawnProcess(cmd:String,cwd:String,env:Null<haxe.DynamicAccess<String>>) {	
		Sys.println(cwd+" >>> " + cmd);
		//final port = server.address().port;

		proc = ChildProcess.spawn(cmd,null,{
			cwd: cwd,
			env: env,
			stdio: Pipe,
			shell: true
		});
		proc.stdout.on(ReadableEvent.Data, io.onStdout);
		proc.stderr.on(ReadableEvent.Data, io.onStderr);
		proc.on(ChildProcessEvent.Exit, (_, _) -> io.onExit());
		
		return proc;
	}
}