package;

import adminmanager.AdminManager;
import actionmanager.ActionManager;
import settings.SettingsManager;
import rfid.RFIDManager;

class RFIDTriggerServer {
	static function main() {
		SettingsManager.instance.init();
		USER_MESSAGE("Starting RFIDTriggerServer", true);

		RFIDManager.instance.onDeviceConnected = function() {
			LOG("Device Ready " + SettingsManager.instance.settings.deviceID);
		}

		RFIDManager.instance.onRead = function(cardId:String) {
			if (SettingsManager.instance.hasCard(cardId) == false) {
				LOG("NEW CARD "+cardId);



				SettingsManager.instance.addCard(cardId);
			} else {

				LOG("current CARD "+cardId);
				ActionManager.instance.doAction(cardId);
			}
		}

		AdminManager.instance.init();
		RFIDManager.instance.init();
	}
}
