package mikolka.config;

import vscode.WorkspaceConfiguration;

class VsCodeConfig {
    public static var instance:VsCodeConfig = new VsCodeConfig();
    
    var projectConfig:WorkspaceConfiguration;
    private function new() {
        projectConfig = Vscode.workspace.getConfiguration();
    }
    public var MOD_NAME(get,null):String;
    function get_MOD_NAME():String {
        return projectConfig.get("funkinCompiler.modName","workbench");
    }    
    public var FCPKG_SOURCES(get,null):Array<String>;
    function get_FCPKG_SOURCES():Array<String> {
        return projectConfig.get("funkinCompiler.fcpkgSources",[""]);
    }            
    public var DEBUG(get,null):Bool;
    function get_DEBUG():Bool {
        return projectConfig.get("funkinCompiler.debug",false);
    }    

    public var GAME_PATH(get,set):String;
    function get_GAME_PATH():String {
        return projectConfig.get("funkinCompiler.gamePath","../funkinGame/");
    }

    // Cache the value in case Vscode lags behind with the update
    public var HAXELIB_PATH(get,set):String;
    private var _haxelib_path:String = null;
    function get_HAXELIB_PATH():String {
        return _haxelib_path ?? projectConfig.get("funkinCompiler.haxelibPath","");
    }
    function set_HAXELIB_PATH(value:String):String {
        _haxelib_path = value;
        projectConfig.update("funkinCompiler.haxelibPath",value,true);
        return value;
    }
    function set_GAME_PATH(value:String):String {
        projectConfig.update("funkinCompiler.gamePath",value,true);
        return value;
    }
}