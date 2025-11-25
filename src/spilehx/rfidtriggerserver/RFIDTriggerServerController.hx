package spilehx.rfidtriggerserver;

// import spilehx.rfidtriggerserver.serverview.RFIDTriggerServerView;
import spilehx.rfidtriggerserver.helpers.ApplicationArgHelper;
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

		startView();

		checkForUpdates(function(updateAvalible:Bool) {
			if (updateAvalible == true) {
				USER_MESSAGE_WARN("Download here: " + RFIDTriggerServerConfig.REPO_RELEASE_URL);
				Sys.sleep(2);
			} else {
				USER_MESSAGE("Running newest version!");
			}

			setupCLIArgs();
			ActionCommandHelpers.ensureDefaultConfigFiles();

			initManagers();

			SettingsManager.instance.settings.updateAvalible = updateAvalible;
			SettingsManager.instance.saveSettingsData();
		});
	}

	private function startView() {
		// RFIDTriggerServerView.instance.init();
	}

	private function checkForUpdates(onUpdateCheck:Bool->Void) {
		// TODO: move this later in flow
		USER_MESSAGE("Checking for avalible updates", true);

		var runningVersion:String = VersionManager.getVersion();
		if (new SomanticVersion(runningVersion).valid == true) {
			VersionManager.getLatestReleaseName(RFIDTriggerServerConfig.REPO_ORG, RFIDTriggerServerConfig.REPO_NAME, newestVersion -> {
				var isNewerVersion:Bool = VersionManager.isNewerVersion(runningVersion, newestVersion);
				if (isNewerVersion == true) {
					USER_MESSAGE_WARN("Newer version Avalible! " + newestVersion);
				}
				onUpdateCheck(isNewerVersion);
			});
		} else {
			onUpdateCheck(false);
		}
	}

	private function setupCLIArgs() {
		ApplicationArgHelper.instance.helpText_appName = RFIDTriggerServerConfig.CLI_HELP_CONTENT_APP_NAME;
		ApplicationArgHelper.instance.helpText_version = VersionManager.getVersion();
		ApplicationArgHelper.instance.helpText_usage = RFIDTriggerServerConfig.CLI_HELP_CONTENT_CLI_USAGE;
		ApplicationArgHelper.instance.helpText_description = RFIDTriggerServerConfig.CLI_HELP_CONTENT_DESCRIPTION;
		ApplicationArgHelper.instance.helpText_examples = RFIDTriggerServerConfig.CLI_HELP_CONTENT_EXAMPLES;

		ApplicationArgHelper.instance.parseApplicationArguments(RFIDTriggerServerConfig.APP_ARGS, onValidArgSubmitted);
	}

	private function initManagers() {
		ActionManager.instance.init(); // required before settings so we have a list of avalible actions

		SettingsManager.instance.init();
		CacheManager.instance.init();
		AdminManager.instance.init();

		if (SettingsManager.instance.isDebug == "true") {
			USER_MESSAGE_WARN("Running in Debug mode! RFID device will not be used");
		}

		if (SysUtils.isRunningAsSudo() || SettingsManager.instance.isDebug == "true" || ActionCommandHelpers.isRunningInDocker() == true) {
			ActionCommandHelpers.ensureMopidyState(); // start mopidy for later

			if (SettingsManager.instance.isDebug == "false") {
				RFIDManager.instance.init(onDeviceConnected, onCardRead);
			}
		} else {
			notPrivledgedError();
		}
	}

	private function onValidArgSubmitted(targetProperty:String, value:String) {
		SettingsManager.instance.addPrePopulateValue(targetProperty, value);
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
