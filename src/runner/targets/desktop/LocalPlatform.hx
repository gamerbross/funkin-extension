package runner.targets.desktop;

import runner.targets.TargetPlatform.SerialCallbacks;
import js.node.child_process.ChildProcess.ChildProcessEvent;
import js.node.stream.Readable.ReadableEvent;
import js.node.ChildProcess;

class LocalPlatform implements TargetPlatform {

    private final args:FNFLaunchRequestArguments;
    private final io:SerialCallbacks;
    private var proc:Null<ChildProcess>;
    
    public function new(args:FNFLaunchRequestArguments,io:SerialCallbacks) {
        this.args = args;
        this.io = io;
    }

    function installDebugServerMod():Void{
        ZipTools.makeSupportMod(args.cwd); // This creates a support mod
    }
    function start():Void{
		final env = new haxe.DynamicAccess();
		for (key in js.Node.process.env.keys())
			env[key] = js.Node.process.env[key];

        final executable_cwd = FunkinPaths.getExecutableFolderPath(args.cwd);
        final cwd = args.cwd;
		final execName = args.execName;
		final cmd_prefix = args.cmd_prefix;
		
		spawnProcess('$cmd_prefix ./$execName',executable_cwd,env);
    }
    function close():Void{
        proc?.kill();
    }

    function spawnProcess(cmd:String,cwd:String,env:Null<haxe.DynamicAccess<String>>) {	
		Sys.println(cwd+" >>> " + cmd);
		//final port = server.address().port;
			
		// Vscode.debug.startDebugging(null,{
		// 	{
		// 		type: type,
		// 		name: name,
		// 		request: request
		// 	}
		// });
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