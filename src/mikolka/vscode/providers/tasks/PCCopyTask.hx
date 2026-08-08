package mikolka.vscode.providers.tasks;

import js.Lib;
import mikolka.helpers.FileManager;
import mikolka.vscode.definitions.tasks.AdbCopyTaskDefinition;
import mikolka.vscode.definitions.DisposableProvider;
import mikolka.config.VsCodeConfig;
import js.lib.Promise;
import haxe.io.Path;
import vscode.ProviderResult;
import vscode.CancellationToken;
import vscode.Task;
import vscode.TaskScope;
import vscode.CustomExecution;

/**
 * This class manages all tasks provided by this extension
 */
class PCCopyTask extends DisposableProvider {
	// This configures the code for the task

	/**
	 * Creates a CustomExecution object for the "Compile current V-Slice mod"task.
	 * 
	 * Such execution can be used to run it in the VsCode's task environment
	 * @param copyToGame Should this task also copy the compiled mod to V-Slice's "mods" folder
	 * @return CustomExecution
	 */
	static function getTask():CustomExecution {
		return new CustomExecution(resolvedDefinition -> new Promise((accept, reject) -> {
			var manifest:AdbCopyTaskDefinition = cast resolvedDefinition;
			var vscodeConfig = VsCodeConfig.instance;

			var modName = manifest.modName;
            var modsFolder = FunkinPaths.getModFolderPath(vscodeConfig.GAME_PATH);
			// Pulling the config in case the tasks missed those

			if (Vscode.workspace.workspaceFolders == null || Vscode.workspace.workspaceFolders.length == 0) {
				reject("No folder seems to be opened! This is not supported!");
			} else {
				var full_project_path = Vscode.workspace.workspaceFolders[0].uri.fsPath;
                if (modName == null || modName == Lib.undefined || modName == "")
					modName = Path.withoutDirectory(full_project_path);

				accept(OutputTerminal.makeTerminal(struct -> {
                    FileManager.syncRec(full_project_path,Path.join([modsFolder,modName]),file -> {
						struct.writeLine('Copied: '+file);
					});
				}));
			}
		}));
	}

	public function new(context:vscode.ExtensionContext) {
		var defaultTask = new Task({type: "funk-pc"}, TaskScope.Workspace, "Copy this V-Slice mod to local FNF", "Funk", getTask());

		// Register task provider
		var disposeHook = Vscode.tasks.registerTaskProvider("funk-pc", {
			resolveTask: PCCopyTask.resolveTask,
			provideTasks: token -> {
				return [defaultTask];
			}
		});
		super(context, disposeHook);
	}

	static function resolveTask(task:Task, token:CancellationToken):ProviderResult<Task> {
		trace("Resolving partial task");
		if (task.execution == null || task.execution == Lib.undefined) {
			var completeTask = new Task(task.definition, TaskScope.Workspace, "Copy this V-Slice mod to local FNF", "Funk", getTask(), null);
			return completeTask;
		}
		return task;
	}
}
