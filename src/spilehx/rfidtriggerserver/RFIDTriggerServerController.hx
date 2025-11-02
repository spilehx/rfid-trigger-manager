package spilehx.rfidtriggerserver;

import spilehx.rfidtriggerserver.helpers.CacheManager;
import spilehx.core.SysUtils;
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
		CacheManager.instance.init();
		ActionManager.instance.init(); // required before settings so we have a list of avalible actions
		SettingsManager.instance.init();
		SettingsManager.instance.parseApplicationArguments();
		AdminManager.instance.init();

		if (SysUtils.isRunningAsSudo() || SettingsManager.instance.isDebug == "true" || ActionCommandHelpers.isRunningInDocker() == true) {
			ActionCommandHelpers.ensureMopidyState(); // start mopidy for later

			if (SettingsManager.instance.isDebug == "false") {
				RFIDManager.instance.init(onDeviceConnected, onCardRead);
			}
		} else {
			notPrivledgedError();
		}
	}

	private function notPrivledgedError(){
		var notSudoMsg:String = "Application not being run privileged\n	prehaps try \"$ sudo hl RFIDTriggerServer.hl\" ";
			Sys.println("\033[1;" + 31 + "mSTARTUP ERROR: \033[0m"+notSudoMsg);
			Sys.exit(1);
	}

	private function onDeviceConnected() {}

	private function onCardRead(cardId:String) {
		if (SettingsManager.instance.hasCard(cardId) == false) {
			USER_MESSAGE("New card read, adding to system:" + cardId, true);
			SettingsManager.instance.addCard(cardId);
		} else {
			ActionManager.instance.doAction(cardId);
		}
	}
}
