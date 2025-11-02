package;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;
import sys.FileSystem;
import spilehx.rfidtriggerserver.managers.SettingsManager;
import spilehx.core.SysUtils;
import spilehx.rfidtriggerserver.RFIDTriggerServerController;

class RFIDTriggerServer {
	static function main() {
		USER_MESSAGE("Starting RFIDTriggerServer", true);
		var controller:RFIDTriggerServerController = new RFIDTriggerServerController();
		controller.init();
	}
}
