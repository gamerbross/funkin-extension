package mikolka.install.files;

import mikolka.install.backend.TaskChips.ChipTask;
import haxe.Exception;
import haxe.ValueException;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.ds.StringMap;

import mikolka.install.chips.*;

typedef Manifest = {
    name:String,
    version:String,
    funkinReferenceTag:Null<String>,
    fullReplaceableFiles:Null<String>,
    funkinPatchRules:Null<StringMap<String>>,
    funkinPatchExclude:Null<Array<String>>,
    haxelibRemoveFolders:Null<Array<String>>,
    // 0 Draft
    // 1 Funkin downloaded
    // 2 Funkin configured
    // 3 Haxelibs downloaded
    // 4 Haxelibs configured
    // 5 Regex patched applied
    // 6 Replaces applied
    installStage:Null<Int>

}

class ManifestParser {
    static var STAGE_DRAFT = 0;
    static var STAGE_FNF_DOWNLOADED = 1;
    static var STAGE_FNF_READY = 2;
    static var STAGE_HAXELIB_DOWNLOADED = 3;
    static var STAGE_HAXELIB_READY = 4;
    static var STAGE_REGEX_PATCH_DONE = 5;
    static var STAGE_FILE_PATCH_DONE = 6;
    static var STAGE_COMPLETE = 6;

    var manifest:Null<Manifest>;
    var haxelib_repo:String;

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
        if(manifest.installStage < STAGE_HAXELIB_READY){
            var obj = new FunkinLibrariesInstall(writeLine, haxelib_repo, manifest.funkinReferenceTag);
            if(manifest.installStage < STAGE_FNF_DOWNLOADED) 
                nodes.push(obj.installFunkin);
            if(manifest.installStage < STAGE_HAXELIB_DOWNLOADED) 
                nodes.push(obj.installLibrariesFromHmm(haxelib_repo));            
            if(manifest.installStage < STAGE_HAXELIB_READY) {
                var dirNode = new DirectoryRemovalChip(manifest.haxelibRemoveFolders,haxelib_repo);
                nodes.push(dirNode.task);
            }
            nodes.push(FileTaskChips.consumeHmmFIle(haxelib_repo));
            
        }
        if(manifest.installStage < STAGE_REGEX_PATCH_DONE){
            var codePatch = new FunkinRegexPatcher(haxelib_repo,manifest.funkinPatchRules,manifest.funkinPatchExclude);
            nodes.push(codePatch.patchFnfCode);
        }
        if(manifest.installStage < STAGE_FILE_PATCH_DONE){
            var regexp = new ClassReplaceChip(this.manifest.fullReplaceableFiles, haxelib_repo);
            nodes.push(regexp.task);
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