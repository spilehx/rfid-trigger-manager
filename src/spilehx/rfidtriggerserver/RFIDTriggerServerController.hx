package spilehx.rfidtriggerserver;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;
import spilehx.core.logger.GlobalLoggingSettings;
import spilehx.rfidtriggerserver.managers.ActionManager;
import spilehx.rfidtriggerserver.managers.RFIDManager;
import spilehx.rfidtriggerserver.managers.AdminManager;
import spilehx.rfidtriggerserver.managers.SettingsManager;

class RFIDTriggerServerController {
	public function new() {}

	public function init() {
		GlobalLoggingSettings.settings.verbose = true;
		ActionCommandHelpers.ensureDefaultConfigFiles();
		initManagers();
	}

	private function initManagers() {
        ActionManager.instance.init(); // required before settings so we have a list of avalible actions
		SettingsManager.instance.init();
		AdminManager.instance.init();

		ActionCommandHelpers.ensureMopidyState();// start mopidy for later


		if(SettingsManager.instance.IS_DEBUG == false){
			RFIDManager.instance.init(onDeviceConnected, onCardRead);
		}
	}

	private function onDeviceConnected() {}

	private function onCardRead(cardId:String) {
		if (SettingsManager.instance.hasCard(cardId) == false) {
            USER_MESSAGE("New card read, adding to system:"+cardId,true);
			SettingsManager.instance.addCard(cardId);
		} else {
			ActionManager.instance.doAction(cardId);
		}
	}
}
