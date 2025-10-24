package;

import spilehx.rfidtriggerserver.RFIDTriggerServerController;


// import adminmanager.AdminManager;
// import spilehx.rfidtriggerserver.managers.ActionManager;
// import spilehx.rfidtriggerserver.managers.SettingsManager;
// import rfid.RFIDManager;

class RFIDTriggerServer {
	static function main() {

		// 	SettingsManager.instance.init();
		// RegisterDevice.instance.getDevices();

		// AdminManager.instance.init();




		USER_MESSAGE("Starting RFIDTriggerServer", true);
		var controller:RFIDTriggerServerController = new RFIDTriggerServerController();
		controller.init();


		// actionmanager.ActionManager.instance.init();
		// SettingsManager.instance.init();

		// // RFIDManager.instance.onDeviceConnected = function() {
		// // 	USER_MESSAGE("Device Ready " + SettingsManager.instance.settings.deviceID);
		// // }

		// // RFIDManager.instance.onRead = function(cardId:String) {
		// // 	LOG("ON READ "+cardId);
		// // 	if (SettingsManager.instance.hasCard(cardId) == false) {
		// // 		SettingsManager.instance.addCard(cardId);
		// // 	} else {
		// // 		ActionManager.instance.doAction(cardId);
		// // 	}
		// // }

		// adminmanager.AdminManager.instance.init();
		// rfid.RFIDManager.instance.init();

		
	}
}
