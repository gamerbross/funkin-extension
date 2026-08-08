package mikolka.mode1;

import mikolka.vscode.definitions.DisposableProvider;
import mikolka.config.VsCodeConfig;
import js.lib.Promise;
import haxe.io.Path;
import mikolka.mode1.CompileTask;
import mikolka.vscode.definitions.tasks.FunkTaskDefinition;
import vscode.ProviderResult;
import vscode.CancellationToken;
import vscode.Task;
import vscode.TaskScope;
import vscode.CustomExecution;

/**
 * This class manages all tasks provided by this extension
 */
class FunkTask extends DisposableProvider {

	// This configures the code for the task
	/**
	 * Creates a CustomExecution object for the "Compile current V-Slice mod"task.
	 * 
	 * Such execution can be used to run it in the VsCode's task environment
	 * @param copyToGame Should this task also copy the compiled mod to V-Slice's "mods" folder
	 * @return CustomExecution
	 */
	static function getModCompileTask():CustomExecution {
		return new CustomExecution(resolvedDefinition -> new Promise((accept, reject) -> {
			var manifest:FunkTaskDefinition = cast resolvedDefinition;

			// Pulling the config in case the tasks missed those
			var vscodeConfig = VsCodeConfig.instance;
			if (manifest.modName == null || manifest.modName == "")
				manifest.modName = "workbench";

			if (manifest.gamePath == null || manifest.gamePath == "")
				manifest.gamePath = vscodeConfig.GAME_PATH;

			if (manifest.copyToGame == null )
				manifest.copyToGame = true;

			trace(manifest);

			if (Vscode.workspace.workspaceFolders == null || Vscode.workspace.workspaceFolders.length == 0) {
				reject("No folder seems to be opened! This is not supported!");
			} else {
				var full_project_path = Vscode.workspace.workspaceFolders[0].uri.fsPath;

				accept(OutputTerminal.makeTerminal(struct -> {
					trace("Getting cwd:");
					var isGamePathRelative = StringTools.startsWith(manifest.gamePath,".");

					var game_cwd = isGamePathRelative 
						?  Path.join([full_project_path, manifest.gamePath]) 
						:  Path.normalize(manifest.gamePath);
					trace(manifest.copyToGame);
					CompileTask.CompileCurrentMod(game_cwd, struct.writeLine, manifest.modName,manifest.copyToGame);
				}));
			}
		}));
	}

	public function new(context:vscode.ExtensionContext) {
		var defaultTask = new Task({type: "funk"}, TaskScope.Workspace, "Compile current V-Slice mod", "Funk", getModCompileTask());
		var exportTask = new Task(cast {type: "funk", copyToGame:false}, TaskScope.Workspace, "Export current V-Slice mod", "Funk", getModCompileTask());

		//Register task provider
		var disposeHook = Vscode.tasks.registerTaskProvider("funk", {
			resolveTask: FunkTask.resolveTask,
			provideTasks: token -> {
				return [defaultTask,exportTask];
			}
		});
		super(context,disposeHook);
	}

	static function resolveTask(task:Task, token:CancellationToken):ProviderResult<Task> {
		trace("Resolving partial task");

		if (task.execution == null){
			var completeTask = new Task(task.definition,TaskScope.Workspace, "Compile current V-Slice mod", "Funk",getModCompileTask(),null);
			return completeTask;
		}
		return task;
	}

}
