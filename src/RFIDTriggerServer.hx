package;

import adminmanager.AdminManager;
import actionmanager.ActionManager;
import settings.SettingsManager;
import rfid.RFIDManager;

class RFIDTriggerServer {
	static function main() {
		SettingsManager.instance.init();
		USER_MESSAGE("Starting RFIDTriggerServer", true);

		AdminManager.instance.init();

		RFIDManager.instance.onDeviceConnected = function() {
			LOG("Device Ready " + SettingsManager.instance.settings.deviceID);
		}

		RFIDManager.instance.onRead = function(cardId:String) {
			if (SettingsManager.instance.hasCard(cardId) == false) {
				SettingsManager.instance.addCard(cardId);
			}

			ActionManager.instance.doAction(cardId);
		}

		RFIDManager.instance.init();
	}
}
