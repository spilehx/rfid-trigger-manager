package;

import adminmanager.AdminManager;
import actionmanager.ActionManager;
import settings.SettingsManager;
import rfid.RFIDManager;

class RFIDTriggerServer {
	static function main() {
		USER_MESSAGE("Starting RFIDTriggerServer", true);
		ActionManager.instance.init();
		SettingsManager.instance.init();

		RFIDManager.instance.onDeviceConnected = function() {
			USER_MESSAGE("Device Ready " + SettingsManager.instance.settings.deviceID);
		}

		RFIDManager.instance.onRead = function(cardId:String) {
			if (SettingsManager.instance.hasCard(cardId) == false) {
				SettingsManager.instance.addCard(cardId);
			} else {
				ActionManager.instance.doAction(cardId);
			}
		}

		AdminManager.instance.init();
		RFIDManager.instance.init();
	}
}
