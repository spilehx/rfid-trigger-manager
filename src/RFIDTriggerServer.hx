package;

import sys.FileSystem;
import sys.io.File;
import spilehx.rfidtriggerserver.managers.SettingsManager;
import spilehx.core.SysUtils;
import spilehx.rfidtriggerserver.RFIDTriggerServerController;

class RFIDTriggerServer {
	static function main() {

		SettingsManager.instance.IS_DEBUG = setDebugMode();

		if (SysUtils.isRunningAsSudo() || SettingsManager.instance.IS_DEBUG == true) {
			USER_MESSAGE("Starting RFIDTriggerServer", true);
			var controller:RFIDTriggerServerController = new RFIDTriggerServerController();
			controller.init();
		} else {
			var notSudoMsg:String = "Application not being run privileged\n	prehaps try \"$ sudo hl RFIDTriggerServer.hl\" ";
			Sys.println("\033[1;" + 31 + "mSTARTUP ERROR: \033[0m"+notSudoMsg);
			Sys.exit(1);
		}
	}

	private static function setDebugMode():Bool{
		// is we want to run this locally with out and RFID and ignorming the current sudo issue we have
		// we will look for a local file that isnt in the repo.
		var isDebug:Bool = FileSystem.exists("./DEBUG_MODE");
		if(isDebug == true){
			trace(" --- DEBUG MODE --- DEBUG MODE --- DEBUG MODE --- ");
		}

		return isDebug;
	}
}
