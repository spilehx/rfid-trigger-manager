package;

import spilehx.rfidtriggerserver.RFIDTriggerServerController;

class RFIDTriggerServer {
	static function main() {
		USER_MESSAGE("Starting RFIDTriggerServer", true);
		var controller:RFIDTriggerServerController = new RFIDTriggerServerController();
		controller.init();
	}
}
