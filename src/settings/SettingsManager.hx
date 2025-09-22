package settings;

import logger.GlobalLoggingSettings;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;

class SettingsManager {
	private static final SETTINGS_FILE_PATH:String = "settings.json";

	// private static final DEVICE_ID:String = "pci-0000:00:14.0-usb-0:1:1.0-event-kbd";
	@:isVar public var settings(get, set):SettingsData;

	public static final instance:SettingsManager = new SettingsManager();

	// private var onDeviceFollowOn:Function;
	// private for singleton use only
	private function new() {}

	public function init() {
		this.settings = new SettingsData();
		validateSettingsFileExists();
		loadSettings();
		GlobalLoggingSettings.settings.verbose = this.settings.verboseLogging;
	}

	private function loadSettings() {
		loadSettingsFromFile();
	}

	private function validateSettingsFileExists() {
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
				type: "",
			});
			saveSettingsData();
		}
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

	function get_settings():SettingsData {
		return settings;
	}

	function set_settings(settings):SettingsData {
		this.settings = settings;
		return this.settings;
	}
}
