package mikolka.vscode.definitions.tasks;

import vscode.TaskDefinition;

typedef FunkTaskDefinition = TaskDefinition & {
    var modName:String;
    var gamePath:String;
    var copyToGame:Bool;
}