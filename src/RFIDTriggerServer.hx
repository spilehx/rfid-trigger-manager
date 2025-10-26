package;

import spilehx.rfidtriggerserver.managers.SettingsManager;
import spilehx.core.SysUtils;
import spilehx.rfidtriggerserver.RFIDTriggerServerController;

class RFIDTriggerServer {
	static function main() {
		if (SysUtils.isRunningAsSudo() || SettingsManager.IS_DEBUG == true) {
			USER_MESSAGE("Starting RFIDTriggerServer", true);
			var controller:RFIDTriggerServerController = new RFIDTriggerServerController();
			controller.init();
		} else {
			
			var notSudoMsg:String = "Application not being run privileged\n	prehaps try \"$ sudo hl RFIDTriggerServer.hl\" ";
			Sys.println("\033[1;" + 31 + "mSTARTUP ERROR: \033[0m"+notSudoMsg);
			Sys.exit(1);
		}
	}
}
