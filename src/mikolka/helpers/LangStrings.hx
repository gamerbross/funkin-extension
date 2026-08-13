package mikolka.helpers;

class LangStrings {

    public static inline final STARTUP_SETUP_MISSING:String = 
        "Looks like you don't have Funkin Compiler initialised. Would you like to do it now?";    
    public static inline final STARTUP_SETUP_MISSING_TITLE:String = 
        "Startup warning";
    public static inline final STARTUP_SETUP_DIFFERENT_HAXELIB:String = 
        "Looks like you don't have Funkin Compiler's haxelib folder set. Would you like to set it now?";

    public static inline final UTILS_SELECT_WORKSPACE_FOLDER = "Select a folder...";
        
    public static inline final MSG_SETUP_CHECKING_CURL:String = "[SETUP] Checking curl..";
    public static inline final MSG_SETUP_CHECKING_HAXE:String = "[SETUP] Checking haxe..";
    public static inline final SETUP_CURL_ERROR:String = 
    "You don't have 'curl' installed on your system! You need to install it before continuing.";
    public static inline final SETUP_HAXE_ERROR:String = 
    "You don't have haxe???\nGet it from here: https://haxe.org/download/";
    
    public static inline final SETUP_HAXELIB_ERROR_TITLE:String = "Haxelib dependencies folder is not empty!";
    public static inline final SETUP_HAXELIB_ERROR:String = 
    "You seem to have non-empty, or absent haxelib folder.\n"+
    "You can reinstall existing dependencies, or keep them as is.\n"+
    "Do you want to reinstall?";
    // Project
	public static inline final PROJECT_NAME_PROMPT:String = "Type in the name of the project:";

}