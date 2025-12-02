package spilehx.rfidtriggerserver.managers;

import spilehx.rfidtriggerserver.helpers.FileSystemHelpers;
import spilehx.rfidtriggerserver.managers.rfid.DeviceDetection;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import spilehx.core.logger.GlobalLoggingSettings;
import spilehx.rfidtriggerserver.managers.ActionManager;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import spilehx.config.RFIDTriggerServerConfig;

class SettingsManager extends spilehx.core.ManagerCore {
	// values set from cli args
	public var isDebug:String = "false";
	public var newVersionCheck:String = "true";
	public var headless:String = "false";

	private var initTriggered:Bool = false;
	private var prePopulatedValues:Dynamic = {};

	public var applicationDataFolder:String = RFIDTriggerServerConfig.APP_DATA_FOLDER_DEFAULT_PATH;
	public var IMAGE_FOLDER_PATH:String;

	private var SETTINGS_FILE_PATH:String;

	public var FILE_CACHE_PATH:String;
	public var YT_FILE_CACHE_PATH:String;

	@:isVar public var settings(get, set):SettingsData;
	@:isVar public var verboseLogging(get, set):Bool;

	public static final instance:SettingsManager = new SettingsManager();

	private override function new() {
		super();
		this.settings = new SettingsData();
	}

	public function init() {
		initTriggered = true;
		setValuesFromPrepopulatedDate();
		FileSystemHelpers.instance.setupApplicationDataFolder(function() {
			USER_MESSAGE("Using app data at: " + applicationDataFolder);

			SETTINGS_FILE_PATH = FileSystemHelpers.instance.getFullPath(RFIDTriggerServerConfig.SETTINGS_FOLDER + "/"
				+ RFIDTriggerServerConfig.SETTINGS_FILE_NAME);
			IMAGE_FOLDER_PATH = FileSystemHelpers.instance.getFullPath(RFIDTriggerServerConfig.IMAGE_FOLDER);
			FILE_CACHE_PATH = FileSystemHelpers.instance.getFullPath(RFIDTriggerServerConfig.CACHE_FOLDER);
			YT_FILE_CACHE_PATH = FileSystemHelpers.instance.getFullPath(RFIDTriggerServerConfig.YT_CACHE_FOLDER);

			validateSettingsFileExists();
			loadSettings();
			updateAvalibleDevices();
			GlobalLoggingSettings.settings.verbose = this.settings.verboseLogging;
			resetCards();
			validateCardActions();
			saveVersion();
		});
	}

	public function addPrePopulateValue(field:String, value:Dynamic) {
		// used to set values before the manager has started,
		// for example if we get cli args
		// they will then be used after init

		if (initTriggered == true) {
			LOG_ERROR("Only run this before settings init!");
			Sys.exit(0);
		}

		Reflect.setField(prePopulatedValues, field, value);
		setValuesFromPrepopulatedDate();
	}

	private function setValuesFromPrepopulatedDate() {
		var fields = Reflect.fields(prePopulatedValues);

		// Cache valid fields for this instance's class
		var validFields = Type.getInstanceFields(Type.getClass(this));

		for (field in fields) {
			if (validFields.indexOf(field) != -1) {
				Reflect.setField(this, field, Reflect.getProperty(prePopulatedValues, field));
			} else {
				LOG_ERROR("Cant set settings " + field + " - My fault! submit a bug please!");
			}
		}
	}

	private function saveVersion() {
		settings.version = spilehx.versionmanager.VersionManager.getVersion();
		settings.buildTime = spilehx.versionmanager.VersionManager.getBuildTime();
		USER_MESSAGE("Running version: \"" + settings.version + "\" built: " + settings.buildTime, true);
		saveSettingsData();
	}

	function get_verboseLogging():Bool {
		return verboseLogging;
	}

	function set_verboseLogging(verboseLogging):Bool {
		this.verboseLogging = verboseLogging;
		GlobalLoggingSettings.settings.verbose = this.settings.verboseLogging = verboseLogging;
		return this.verboseLogging = verboseLogging;
	}

	public function updateAvalibleDevices() {
		settings.avalibleDevices = DeviceDetection.getDeviceNames();
		saveSettingsData();
	}

	public function resetCards() {
		for (card in settings.cards) {
			card.active = card.current = false;
		}
		saveSettingsData();
	}

	public function getActiveCardId():String {
		for (card in settings.cards) {
			if (card.active == true) {
				return card.id;
			}
		}
		return "";
	}

	private function validateCardActions() {
		settings.avalibleCardActions = ActionManager.instance.avaliableActionTypes;

		if (settings.avalibleCardActions != null) {
			var userMsgIndentStr:String = "\n    - ";
			USER_MESSAGE("  " + settings.avalibleCardActions.length + " actions found " + userMsgIndentStr
				+ settings.avalibleCardActions.join(userMsgIndentStr));

			for (card in settings.cards) {
				if (card.action.length < 1) {
					card.enabled = false;
					continue;
				}

				if (settings.avalibleCardActions.indexOf(card.action) == -1) {
					USER_MESSAGE("Bad action found for card: " + card.id + " resetting");
					card.action = "";
					card.enabled = false;
				}
			}
		}

		SettingsManager.instance.saveSettingsData();
	}

	public function loadSettings() {
		loadSettingsFromFile();
	}

	private function validateSettingsFileExists() {
		// FileSystemHelpers.ensurePath(SETTINGS_PATH);
		if (FileSystem.exists(SETTINGS_FILE_PATH) == false) {
			// no file, so save a new one with defaults
			saveSettingsData();
		}
	}

	private function loadSettingsFromFile() {
		if (FileSystem.exists(SETTINGS_FILE_PATH) == true) {
			this.settings = new SettingsData();
			var settingsJson:String = File.getContent(SETTINGS_FILE_PATH);
			var loadedData:Dynamic = cast Json.parse(settingsJson);

			var settingsFields:Array<String> = Reflect.fields(settings);

			for (settingsField in settingsFields) {
				if (Reflect.hasField(loadedData, settingsField)) {
					var prop = Reflect.getProperty(loadedData, settingsField);
					Reflect.setField(this.settings, settingsField, prop);
				}
			}
		}
	}

	public function saveSettingsData() {
		File.saveContent(SETTINGS_FILE_PATH, getSettingsJson());
	}

	private function getSettingsJson():String {
		var jsonContent:String = Json.stringify(this.settings);
		return jsonContent;
	}

	public function addCard(id:String) {
		if (hasCard(id) == false) {
			settings.cards.push({
				id: id,
				name: "",
				action: "",
				actionState: "",
				command: "",
				enabled: false,
				active: false,
				current: false,
				playList: []
			});
			saveSettingsData();
		}
	}

	public function updateCard(updatedCard:CardData) {
		if (hasCard(updatedCard.id) == true) {
			for (i in 0...settings.cards.length) {
				if (updatedCard.id == settings.cards[i].id) {
					updatedCard.enabled = validateCardEnabledState(updatedCard);
					settings.cards[i] = updatedCard;

					break;
				}
			}

			saveSettingsData();
		}
	}

	public function validateCardEnabledState(card:CardData):Bool {
		// this function will look at a cards enabled state,
		// if it is enabled but it should not be as its not set up, it will return false
		if (card.enabled == true) { // wanted it to be true
			if (card.name.length > 0) { // has a name
				if (card.action.length > 0) { // has action
					if (card.command.length > 0) { // has type
						return true; // wanted it to be true, and all fields ok so retruning true
					}
				}
			}
		}

		return false;
	}

	public function hasCard(id:String) {
		for (card in settings.cards) {
			trace("hs card" + id + " " + card.id);
			if (card.id == id) {
				return true;
			}
		}

		return false;
	}

	public function getCard(id:String):CardData {
		for (card in settings.cards) {
			if (card.id == id) {
				return card;
			}
		}

		return null;
	}

	function get_settings():SettingsData {
		return settings;
	}

	function set_settings(settings):SettingsData {
		this.settings = settings;
		return this.settings;
	}
}
