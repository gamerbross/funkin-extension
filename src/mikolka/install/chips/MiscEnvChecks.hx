package mikolka.install.chips;

import sys.FileSystem;
import mikolka.install.backend.TaskChips;

class MiscEnvChecks {
	public function new(writeLine:String->Void) {
		this.writeLine = writeLine;
	}

	var writeLine:String->Void;

	public function testEnvironment(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		ctx.appendManyTasks([
			checkHaxe, 
			checkCurl
		]);
		resolve();
	}
	public function checkCurl(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine(LangStrings.MSG_SETUP_CHECKING_CURL);
		if (!Process.checkCommand("curl -V"))
			deny(LangStrings.SETUP_CURL_ERROR);
		else
			resolve();
	}

	public function checkHaxe(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine(LangStrings.MSG_SETUP_CHECKING_HAXE);
		if (!Process.checkCommand("haxe --version"))
			deny(LangStrings.SETUP_HAXE_ERROR);
		else
			resolve();
	}

}
