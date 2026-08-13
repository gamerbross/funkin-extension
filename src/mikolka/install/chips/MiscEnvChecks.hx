package mikolka.install.chips;

import mikolka.install.backend.TaskChips;

class MiscEnvChecks {
	public function new(writeLine:String->Void) {
		this.writeLine = writeLine;
	}

	var writeLine:String->Void;

	public function testEnvironment(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		ctx.appendManyTasks([ 
			checkCurl
		]);
		resolve();
	}
	public function checkCurl(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine(Language.MSG_SETUP_CHECKING_CURL);
		if (!Process.checkCommand("curl -V"))
			deny(Language.SETUP_CURL_ERROR);
		else
			resolve();
	}


}
