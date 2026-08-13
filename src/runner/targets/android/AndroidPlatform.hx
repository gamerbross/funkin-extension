package runner.targets.android;

import haxe.io.Path;
import runner.targets.TargetPlatform.SerialCallbacks;


class AndroidPlatform implements TargetPlatform {

    private final args:FNFLaunchRequestArguments;
    private final io:SerialCallbacks;
    private var adb:AdbTools;
    
    public function new(args:FNFLaunchRequestArguments,io:SerialCallbacks) {
        this.args = args;
        this.io = io;
        adb = new AdbTools(io,args.execName);
    }

    public function installDebugServerMod():Void{
        adb.makeSupportMod();
    }   
	public function isDebugServerPresent():Bool{
        return adb.spawnSyncProcess('ls ${Path.join([adb.mods_path,"debug-mod"])} > /dev/null') == 0;
    }
    public function start():Bool{
        adb.dropServerIPMemo();
        return adb.spawnSyncProcess(adb.RUN_FNF,null) == 0;
    }
    public function close():Void{
        adb.spawnSyncProcess(adb.STOP_FNF,null);
        io.onExit();
    }

    public function removeDebugServerMod() {
        adb.spawnSyncProcess('rm -r "${Path.join([adb.mods_path, "debug-mod"])}');
    }
}