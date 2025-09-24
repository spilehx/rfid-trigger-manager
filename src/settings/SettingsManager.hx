package settings;

import logger.GlobalLoggingSettings;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;

class SettingsManager {
	private static final SETTINGS_FILE_PATH:String = "settings.json";

	@:isVar public var settings(get, set):SettingsData;

	public static final instance:SettingsManager = new SettingsManager();

	private function new() {}

	public function init() {
		this.settings = new SettingsData();
		validateSettingsFileExists();
		loadSettings();

		resetCards();
		GlobalLoggingSettings.settings.verbose = this.settings.verboseLogging;
	}

	public function resetCards() {
		for (card in settings.cards) {
			card.active = card.current = false;
		}
		saveSettingsData();
	}

	public function loadSettings() {
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
				actionState: "",
				type: "",
				enabled: false,
				active: false,
				current: false,
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
					if (card.type.length > 0) { // has type
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

	function get_settings():SettingsData {
		return settings;
	}

	function set_settings(settings):SettingsData {
		this.settings = settings;
		return this.settings;
	}
}
