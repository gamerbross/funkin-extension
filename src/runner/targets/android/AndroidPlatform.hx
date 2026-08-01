package runner.targets.android;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.FileSeek;
import runner.vslice.FunkinPaths;
import runner.targets.TargetPlatform.SerialCallbacks;


class AndroidPlatform implements TargetPlatform {

    private final args:FNFLaunchRequestArguments;
    private final io:SerialCallbacks;
    private var adb:AdbTools;
    
    public function new(args:FNFLaunchRequestArguments,io:SerialCallbacks) {
        this.args = args;
        this.io = io;
        adb = new AdbTools(io);
    }

    public function installDebugServerMod():Void{
        adb.makeSupportMod();
    }   
	public function isDebugServerPresent():Bool{
        return adb.spawnSyncProcess('ls ${Path.join([AdbTools.mods_path,"debug-mod"])} > /dev/null') == 0;
    }
    public function start():Bool{
        adb.dropServerIPMemo();
        return adb.spawnSyncProcess(AdbTools.RUN_FNF,null) == 0;
    }
    public function close():Void{
        adb.spawnSyncProcess(AdbTools.STOP_FNF,null);
        io.onExit();
    }
}