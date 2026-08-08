package mikolka.helpers;

import haxe.io.Path;
using StringTools;

class AdbServer {
    private static final PERMISSIONS:String = "adb shell stat -c '%a'";
    private static final ADB:String = "adb shell";
	public static function pushFiles(source:String, target:String, inSync:Bool = false,onProgress:String -> Void,onComplete:Void -> Void) {
		var cmd = new StringBuf();
		cmd.add("adb push ");
        cmd.add("-p ");
		if (inSync)
			cmd.add("--sync ");
		cmd.addChar('"'.code);
		cmd.add(source);
		cmd.add('/." '); // Copy content, NOT the dir itself
		cmd.addChar('"'.code);
		cmd.add(target);
		cmd.add('/"');

        onProgress('>>> $cmd \n');

        Process.runCommand(cmd.toString(),null,onProgress,onComplete);
	}
    public static function isAdbReady():Bool {
        return Process.checkCommand("adb get-state",null,"The Android device/adb doesn't seem to be ready!");
    }
    public static inline function getModsPath(packageName:String):String {
        return '/sdcard/Android/data/$packageName/files/mods';
    }
    // Returns true if changes have been made
    public static function assureModsFolderIsWritable(packageName:String):Null<Bool> {
        var mods_path = getModsPath(packageName);
        var currentPermission = Process.resolveCommand('$PERMISSIONS $mods_path');
        if(!(currentPermission.startsWith("277") || currentPermission.startsWith("77"))){
            if(currentPermission.startsWith("275") || currentPermission.startsWith("75")){
                var parent_dir = Path.join([mods_path,".."]);
                var bak_dir = Path.join([parent_dir,"mods-bak"]);
                Process.resolveCommand('$ADB mv $mods_path $bak_dir');
                Process.resolveCommand('$ADB mkdir $mods_path');
                return true;
            }
            else{
                return null;
            }
        }
        return false;
    }
}