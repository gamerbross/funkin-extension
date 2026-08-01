package mikolka.vscode.definitions.tasks;

import vscode.TaskDefinition;

typedef AdbCopyTaskDefinition = TaskDefinition & {
    var packageName:String;
    var modName:String;
}