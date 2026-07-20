package mikolka.install.chips;

import mikolka.install.files.ManifestParser.Manifest;
import haxe.DynamicAccess;
import haxe.io.Path;
import mikolka.install.backend.TaskChips;
import sys.io.File;

using StringTools;

// Patcher
// !! make sure to put "polymodExecFunc" in Module.hx
// !! THIS IS NOT AUTOMATIC
//"haxe -main CodePatcher --interp  "
class FunkinRegexPatcher
{
    var full_code_path:String;
    var regex_rules:DynamicAccess<String>;
    var regex_exclude:Array<String>;
    public function new(haxelib_path:String,funkinPatchRules:DynamicAccess<String>,regex_exclude:Array<String>) {
        this.full_code_path = Path.join([haxelib_path,"funkin","git","funkin"]);
        this.regex_rules = funkinPatchRules;
        this.regex_exclude = regex_exclude;
    }
  public function patchFnfCode(resolve:Void->Void, deny:String->Void,ctx:TaskChips)
  {
    FileManager.scanDirectory(this.full_code_path,inspectFile,(x) ->{});

    // For haxe UI
    resolve();
  }

  private function inspectFile(path:String)
  {
    var fullPath:String = Path.join([full_code_path,path]);
    for (x in regex_exclude)
    {
      if (path.startsWith(x)) return;
    }
    var content = File.getContent(fullPath);
    trace(fullPath);

    for (regex_content in regex_rules.keys())
    {
      var eregItem = new EReg(regex_content,"gm");
      content = eregItem.replace(content, regex_rules.get(regex_content));
    }
    File.saveContent(fullPath, content);
  }
}