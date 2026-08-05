package runner;

import vscode.debugProtocol.DebugProtocol.LaunchRequestArguments;

typedef FNFLaunchRequestArguments = LaunchRequestArguments & {
	final cwd:String;
	final cmd_prefix:String;
	final execName:String;
	final args:Array<String>;
	final isMobile:Bool;
	final trace:Bool; // if set to true sends trace messages as DebugSession.OutputEvents
}