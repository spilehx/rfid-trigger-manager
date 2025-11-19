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
	private var applicationArguments:Array<CommandArg> = new Array<CommandArg>();

	public var isDebug:String = "false";
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
		applicationArguments.push(new CommandArg("d", "isDebug", "Runs in debug mode, so does not require sudo, and does not look for devices."));
		applicationArguments.push(new CommandArg("p", "applicationDataFolder",
			"[PATH] Sets the path to the settings and cache folder, if there is not one you will be prompted to create"));

		this.settings = new SettingsData();
	}

	public function init() {
		FileSystemHelpers.instance.setupApplicationDataFolder(function() {
			USER_MESSAGE("Using app data at: " + applicationDataFolder);

			SETTINGS_FILE_PATH = FileSystemHelpers.instance.getFullPath(RFIDTriggerServerConfig.SETTINGS_FOLDER + "/"+ RFIDTriggerServerConfig.SETTINGS_FILE_NAME);
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

	private function saveVersion() {
		settings.version = spilehx.versionmanager.VersionManager.getVersion();
		settings.buildTime = spilehx.versionmanager.VersionManager.getBuildTime();
		USER_MESSAGE("Running version: \""+settings.version+"\" built: "+settings.buildTime, true);
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

	public function parseApplicationArguments() {
		var args:Array<String> = Sys.args();
		var argPairs:Array<Array<String>> = new Array<Array<String>>();

		if (args.length == 0) {
			return;
		}

		if (args.indexOf("--help") > -1) {
			printArgHelpAndExit();
		}

		// by definition there must be an even number of args
		if (args.length % 2 != 0) {
			printArgHelpAndExit("Bad Arguments");
		}

		while (args.length > 0) {
			var argKey:String = args.shift();
			var argValue:String = args.shift();
			argPairs.push([argKey, argValue]);
		}

		// validate args
		for (argPair in argPairs) {
			var submittedKey:String = argPair[0];
			var submittedValue:String = argPair[1];
			var foundApplicationArgument:CommandArg = Lambda.find(applicationArguments, arg -> arg.keyValue == submittedKey);

			if (foundApplicationArgument == null) {
				printArgHelpAndExit("Bad Arguments " + submittedKey + " not found");
				return;
			} else {
				if (Reflect.hasField(this, foundApplicationArgument.targetProperty) == true) {
					Reflect.setField(this, foundApplicationArgument.targetProperty, submittedValue);
				} else {
					printArgHelpAndExit("Bad Arguments " + submittedKey + " not implemented - My fault! submit an bug please!");
					return;
				}
			}
		}
	}

	public function printArgHelpAndExit(errorMessage:String = "") {
		var INDENT:String = "  \t";
		var TAB:String = "\t";
		var FG_RED:Int = 31;
		var FG_GREEN:Int = 32;

		var l:Array<String> = new Array<String>();

		var toRed:String->String = function(input:String):String {
			return "\033[1;" + FG_RED + "m" + input + " \033[0m";
		}
		var toGreen:String->String = function(input:String):String {
			return "\033[1;" + FG_GREEN + "m" + input + " \033[0m";
		}

		if (errorMessage.length > 0) {
			l.push(toRed("ERROR: " + errorMessage));
			l.push("");
		}

		l.push(toGreen("Rfid Music Trigger Server - v0.0.0-alpha"));
		l.push(toGreen("========================================"));

		l.push("");
		l.push("Usage:");
		l.push(INDENT + "hl RFIDTriggerServer.hl [options]");

		l.push("");
		l.push("Description:");
		l.push(INDENT + "The RFID Music Trigger Server and web admin interface");
		l.push(INDENT + "By scanning tags you can trigger music to play from youtube, spotify or live streams");
		l.push(INDENT + "When running, open http://localhost:1337 to setup reader and cards.");

		l.push("");
		l.push("Options:");
		l.push(INDENT + "--help" + TAB + "Display this help message and exit.");
		for (arg in applicationArguments) {
			l.push(INDENT + arg.keyValue + TAB + arg.description);
		}

		l.push("");
		l.push("Examples:");
		l.push(INDENT + "# Start server in debug mode with rfid features deactivated");
		l.push(INDENT + "hl RFIDTriggerServer.hl -d true");
		l.push("");
		l.push(INDENT + "# Display help message");
		l.push(INDENT + "hl RFIDTriggerServer.hl --help");
		l.push("");

		while (l.length > 0) {
			Sys.println(l.shift());
		}

		Sys.exit(1);
	}

	function get_settings():SettingsData {
		return settings;
	}

	function set_settings(settings):SettingsData {
		this.settings = settings;
		return this.settings;
	}
}

class CommandArg {
	@:isVar public var keyValue(default, null):String;
	@:isVar public var targetProperty(default, null):String;
	@:isVar public var description(default, null):String;

	public function new(keyValue:String, targetProperty:String, description:String) {
		this.keyValue = "-" + keyValue;
		this.targetProperty = targetProperty;
		this.description = description;
	}
}
