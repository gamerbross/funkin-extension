package mikolka.vscode.providers.tasks;

import js.Lib;
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
class AdbTask extends DisposableProvider {
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

			var packageName = manifest.packageName;
			var modName = manifest.modName;

			// Pulling the config in case the tasks missed those
			var vscodeConfig = VsCodeConfig.instance;
			if (modName == null || modName == Lib.undefined || modName == "")
				modName = vscodeConfig.MOD_NAME;

			if (packageName == null || packageName == Lib.undefined || packageName == "")
				packageName = "me.funkin.fnf";

			if (Vscode.workspace.workspaceFolders == null || Vscode.workspace.workspaceFolders.length == 0) {
				reject("No folder seems to be opened! This is not supported!");
			} else {
				var full_project_path = Vscode.workspace.workspaceFolders[0].uri.fsPath;

				accept(OutputTerminal.makeTerminal(struct -> {
					trace("Getting cwd:");
					if (AdbServer.isAdbReady()) {
						var status = AdbServer.assureModsFolderIsWritable(packageName);
						if (status == null)
							Interaction.displayErrorAlert("FNF Mobile Error",
								"The 'mods' folder of the FNF mobile instance doesn't seem to me accessible. Try running the game or create it!");
						else {
							if (status)
								Interaction.displayInformation("The 'mods' folder had to be re-created. Existing mods were moved to 'mods-bak'");
							AdbServer.pushFiles(full_project_path, Path.join([AdbServer.getModsPath(packageName), modName]), true, struct.writeLine,
								struct.onComplete);
						}
					}
				}));
			}
		}));
	}

	public function new(context:vscode.ExtensionContext) {
		var defaultTask = new Task({type: "funk-mobile"}, TaskScope.Workspace, "Copy this V-Slice mod to mobile", "Funk ADB", getTask());

		// Register task provider
		var disposeHook = Vscode.tasks.registerTaskProvider("funk-mobile", {
			resolveTask: AdbTask.resolveTask,
			provideTasks: token -> {
				return [defaultTask];
			}
		});
		super(context, disposeHook);
	}

	static function resolveTask(task:Task, token:CancellationToken):ProviderResult<Task> {
		trace("Resolving partial task");
		if (task.execution == null || task.execution == Lib.undefined) {
			var completeTask = new Task(task.definition, TaskScope.Workspace, "Copy this V-Slice mod to mobile", "Funk ADB", getTask(), null);
			return completeTask;
		}
		return task;
	}
}
