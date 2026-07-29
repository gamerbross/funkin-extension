package runner.targets;

interface TargetPlatform {
    dynamic function onExit():Void;
    function installDebugServerMod():Void;
    function start():Void;
    function close():Void;
}
typedef SerialCallbacks = {
    onExit:Void->Void,
    onStdout:(data:Buffer)->Void,
    onStderr:(data:Buffer)->Void
} 