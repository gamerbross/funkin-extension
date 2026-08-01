package runner.targets;

import js.node.Buffer;

interface TargetPlatform {
    function isDebugServerPresent():Bool;
    function installDebugServerMod():Void;
    function start():Bool;
    function close():Void;
}
typedef SerialCallbacks = {
    onExit:Void->Void,
    onStdout:(data:Buffer)->Void,
    onStderr:(data:Buffer)->Void
} 