package runner;

import runner.targets.android.AndroidPlatform;
import runner.targets.desktop.LocalPlatform;
import runner.targets.TargetPlatform;
import runner.server.DebugServer;
import vscode.debugAdapter.DebugSession;
import vscode.debugProtocol.DebugProtocol;

using Lambda;
using StringTools;

class FunkinDebugger extends DebugSession {
	private var platform:TargetPlatform;

	public function new() {
		super();
	}

	override function initializeRequest(response:InitializeResponse, args:InitializeRequestArguments) {
		// response.body.supportsSetVariable = true;
		response.body.supportsEvaluateForHovers = true;
		response.body.supportsCompletionsRequest = true;
		response.body.supportsRestartRequest = true;
		sendResponse(response);
		postLaunchActions = [];
	}

	var server:DebugServer;
	var onProcessTerminate:() -> Void;
	var postLaunchActions:Array<(() -> Void)->Void>;
	var launchArgs:FNFLaunchRequestArguments;

	function executePostLaunchActions(callback) {
		function loop() {
			final action = postLaunchActions.shift();
			if (action == null)
				return callback();
			action(loop);
		}
		loop();
	}

	override function restartRequest(response:RestartResponse, args:RestartArguments) {
		// This is a flag for our helper mod
		server.softRestartGame();
		super.restartRequest(response, args);
	}

	override function evaluateRequest(response:EvaluateResponse, args:EvaluateArguments) {
		var command = args.expression;
		server.sendCmdCommand(command, struct -> {
			response.success = struct.wasSuccess;
			if (response.success) {
				response.body = {result: struct.data, variablesReference: 0};
			} else {
				response.message = struct.data;
			}
			sendResponse(response);
		});
	}

	override function completionsRequest(response:CompletionsResponse, args:CompletionsArguments) {
		// server.listVariablesCommand(args.text,)
		// response.body = {targets: }
		server.listVariablesCommand(args.text, struct -> {
			response.success = true;
			response.body = {
				targets: []
			};
			for (foundField in struct.completions) {
				response.body.targets.push({
					label: foundField.field,
					type: foundField.field_type,
					start: args.column - struct.fuzzyFieldLength
				});
			}
			sendResponse(response);
		});
	}

	// Launch the BF!!!
	override function launchRequest(response:LaunchResponse, args:LaunchRequestArguments) {
		final args:FNFLaunchRequestArguments = cast args;
		final io:SerialCallbacks = {
			onExit: () -> {
				sendEvent(new vscode.debugAdapter.DebugSession.TerminatedEvent(false));
			},
			onStderr: data -> {
				sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(data.toString("utf-8"), Stderr));
			},
			onStdout: data -> {
				sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(data.toString("utf-8"), Stdout));
			}
		};
		launchArgs = args;
		platform = args.isMobile ? new AndroidPlatform(args, io) : new LocalPlatform(args, io);

		// if (launchArgs.trace) {
		haxe.Log.trace = traceToOutput;
		// }

		// for (key in args.haxeExecutable.env.keys())
		// 	env[key] = args.haxeExecutable.env[key];

		server = new DebugServer(launchArgs.trace);
		server.onEvent = event -> {
			if(event.event == "trace" && event.params.length > 0){
				sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(event.params[0]+"\n", Stdout));
			}
		}
		server.start();

		// function onConnected(socket) {
		// 	trace("Haxe connected!");
		// 	connection = new Connection(socket);
		// 	connection.onEvent = onEvent;

		// 	socket.on(SocketEvent.Error, error -> trace('Socket error: $error'));

		// }
		onProcessTerminate = () -> {
			platform.close();
		}

		if (!platform.isDebugServerPresent())
			platform.installDebugServerMod();
		var success = platform.start();
		if(success){

			executePostLaunchActions(function() {
				sendEvent(new vscode.debugAdapter.DebugSession.InitializedEvent());
				sendResponse(response);
				// if (args.stopOnEntry) {
					// 	sendEvent(new vscode.debugAdapter.DebugSession.StoppedEvent("entry", 0));
					// }
				});
		}
		else{
			response.success = false;
			response.message = "FNF instance did not start successfully!";
			sendResponse(response);
			Sys.exit(1);
		}
	}

	override function disconnectRequest(response:DisconnectResponse, args:DisconnectArguments) {
		// for (id => alive in threads) {
		// 	if (alive) {
		// 		sendEvent(new vscode.debugAdapter.DebugSession.ThreadEvent("exited", id));
		// 	}
		// }
		if (onProcessTerminate != null) {
			onProcessTerminate();
			onProcessTerminate = null;
		} else {
			response.success = false;
			response.message = "No Kill hook found!";
		}
		sendResponse(response);
	}

	function respond<T>(response:Response<T>, error:Null<runner.server.Message.Error>, f:() -> Void) {
		if (error != null) {
			response.success = false;
			response.message = error.message;
		} else {
			response.success = true;
			f();
		}
		sendResponse(response);
	}

	function traceToOutput(value:Dynamic, ?infos:haxe.PosInfos) {
		var msg = Std.string(value);
		if (infos != null && infos.customParams != null) {
			msg += " " + infos.customParams.join(" ");
		}
		msg += "\n";
		sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(msg));
	}
}
