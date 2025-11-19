package spilehx.rfidtriggerserver;

import spilehx.config.RFIDTriggerServerConfig;
import spilehx.versionmanager.VersionManager;
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

		checkForUpdates(function(updateAvalible:Bool) {
			if (updateAvalible == true) {
				
				USER_MESSAGE_WARN("Download here: " + RFIDTriggerServerConfig.REPO_RELEASE_URL);
				Sys.sleep(2);
			} else {
				USER_MESSAGE("Running newest version!");
			}
			ActionCommandHelpers.ensureDefaultConfigFiles();

			initManagers();

			SettingsManager.instance.settings.updateAvalible = updateAvalible;
			SettingsManager.instance.saveSettingsData();
		});
	}

	private function checkForUpdates(onUpdateCheck:Bool->Void) {
		USER_MESSAGE("Checking for avalible updates", true);

		var runningVersion:String = VersionManager.getVersion();
		if (new SomanticVersion(runningVersion).valid == true) {
			VersionManager.getLatestReleaseName(RFIDTriggerServerConfig.REPO_ORG, RFIDTriggerServerConfig.REPO_NAME, newestVersion -> {
				var isNewerVersion:Bool = VersionManager.isNewerVersion(runningVersion, newestVersion);
				if(isNewerVersion == true){
					USER_MESSAGE_WARN("Newer version Avalible! "+newestVersion);
				}
				onUpdateCheck(isNewerVersion);
			});
		} else {
			onUpdateCheck(false);
		}
	}

	private function initManagers() {
		ActionManager.instance.init(); // required before settings so we have a list of avalible actions
		SettingsManager.instance.parseApplicationArguments();
		SettingsManager.instance.init();

		CacheManager.instance.init();
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

	private function notPrivledgedError() {
		var notSudoMsg:String = "Application not being run privileged\n	prehaps try \"$ sudo hl RFIDTriggerServer.hl\" ";
		Sys.println("\033[1;" + 31 + "mSTARTUP ERROR: \033[0m" + notSudoMsg);
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
