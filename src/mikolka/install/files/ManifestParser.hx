package mikolka.install.files;

import thx.semver.Version;
import haxe.DynamicAccess;
import mikolka.install.backend.TaskChips.ChipTask;
import haxe.Exception;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

import mikolka.install.chips.*;

typedef Manifest = {
    name:String,
    version:String,
    funkinReferenceTag:Null<String>,
    fullReplaceableFiles:Null<String>,
    funkinPatchRules:Null<DynamicAccess<String>>,
    funkinPatchExclude:Null<Array<String>>,
    haxelibRemoveFolders:Array<String>,
    // 0 Draft
    // 1 Funkin downloaded
    // 2 Haxelibs downloaded
    // 3 Haxelibs configured
    // 4 Funkin configured
    // 5 Regex patched applied
    // 6 Replaces applied
    installStage:Null<Int>

}

class ManifestParser {
    public static final MANIFEST_VERSION:Version = Version.stringToVersion("1.0.0");

    static var STAGE_DRAFT = 0;
    static var STAGE_FNF_DOWNLOADED = 1;
    static var STAGE_HAXELIB_DOWNLOADED = 2;
    static var STAGE_HAXELIB_READY = 3;
    static var STAGE_FNF_READY = 4;
    static var STAGE_REGEX_PATCH_DONE = 5;
    static var STAGE_FILE_PATCH_DONE = 6;
    static var STAGE_COMPLETE = 7;

    var manifest:Null<Manifest>;
    var haxelib_repo:String;

    public var installJsonVersion(get,null):Version;
    function get_installJsonVersion():Version {
        if(manifest == null) return MANIFEST_VERSION;
        return Version.stringToVersion(manifest.version);
    }

    public var installStage(get,null):Int;
    function get_installStage():Int {
        if(manifest == null) return STAGE_COMPLETE;
        return manifest.installStage;
    }

    public function new(haxelibTarget:String) {
        this.manifest = readHaxelibManifest(haxelibTarget);
        this.haxelib_repo = haxelibTarget;
    }

    public function buildTaskList(writeLine:String->Void):Array<ChipTask> {
        if(manifest == null) return [];

        var nodes = new Array<ChipTask>();
        if(manifest.installStage < STAGE_FNF_READY){
            var obj = new FunkinLibrariesInstall(writeLine, haxelib_repo, manifest.funkinReferenceTag);
            if(manifest.installStage < STAGE_FNF_DOWNLOADED) 
                nodes.push(obj.downloadFunkin);
            if(manifest.installStage < STAGE_HAXELIB_DOWNLOADED) 
                nodes.push(obj.installLibrariesFromHmm(haxelib_repo));              
            if(manifest.installStage < STAGE_HAXELIB_READY) {
                var dirNode = new DirectoryRemovalChip(manifest.haxelibRemoveFolders,haxelib_repo);
                nodes.push(dirNode.task);
                nodes.push(FileTaskChips.consumeHmmFIle(haxelib_repo));
                
            }        
            nodes.push(obj.configureFunkin);
            
        }       
        if(manifest.installStage < STAGE_REGEX_PATCH_DONE){
            var codePatch = new FunkinRegexPatcher(haxelib_repo,manifest.funkinPatchRules,manifest.funkinPatchExclude);
            nodes.push(codePatch.patchFnfCode);
        }
        if(manifest.installStage < STAGE_FILE_PATCH_DONE){
            var regexp = new ClassReplaceChip(this.manifest.fullReplaceableFiles, haxelib_repo);
            nodes.push(regexp.task);
            nodes.push(FileTaskChips.consumeInstallFiles(haxelib_repo,manifest.fullReplaceableFiles));
        }
        return nodes;
    }

    private function readHaxelibManifest(haxelibTarget:String):Null<Manifest> {
        if(!FileSystem.exists(Path.join([haxelibTarget,"install.json"]))){
            return null;
        }
        var obj:Manifest = Json.parse(File.getContent(Path.join([haxelibTarget,"install.json"])));
        if(obj.installStage == null){
            obj.installStage = STAGE_DRAFT;
            if(obj.funkinReferenceTag == null){
                if(!FileSystem.exists(Path.join([haxelibTarget,"funkin","git"]))){
                    throw new Exception("Both 'funkinReferenceTag' is not set AND there is no funkin installation included!");
                }
                obj.installStage = STAGE_FNF_READY;
                if(!FileSystem.exists(Path.join([haxelibTarget,"funkin","git","hmm.json"]))){
                    //* No HMM, we probably installed it (or it's not needed)
                    obj.installStage = STAGE_HAXELIB_READY;
                }
            }
        }
        if(obj.haxelibRemoveFolders == null)
            obj.haxelibRemoveFolders = [];
        return obj;
    }

}