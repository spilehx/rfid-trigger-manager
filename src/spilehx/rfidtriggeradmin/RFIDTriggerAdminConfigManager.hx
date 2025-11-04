package spilehx.rfidtriggeradmin;

import spilehx.rfidtriggerserver.managers.settings.CardData;
import haxe.Json;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import spilehx.core.http.HTTPRequester;
import haxe.Timer;

class RFIDTriggerAdminConfigManager {
	private var updateFunctions:Array<SettingsData->Void>;
	private var updateTimer:Timer;

	public var settings:SettingsData;

	public static final instance:RFIDTriggerAdminConfigManager = new RFIDTriggerAdminConfigManager();

	private function new() {}

	public function init() {
		updateFunctions = new Array<SettingsData->Void>();
		startAutoUpdate();
	}

	private function startAutoUpdate() {
		updateTimer = new Timer(RFIDTriggerAdminSettings.UPDATE_INTERVAL);
		updateTimer.run = onUpdate;
	}

	private function onUpdate() {
		loadSettings(onLoadSuccess, onLoadError);
	}

	private function onLoadSuccess(sd:SettingsData) {
		settings = sd;
		sendUpdates();
	}

	private function sendUpdates() {
		for (updateFunction in updateFunctions) {
			updateFunction(settings);
		}
	}

	private function onLoadError(response:Dynamic) {}

	private function loadSettings(onSuccess:SettingsData->Void, onError:Dynamic->Void) {
		var serverUrl:String = js.Browser.document.location.href;
		var path:String = "config";

		var httpReq:HTTPRequester = new HTTPRequester(serverUrl + path, "", function(data:Dynamic) {
			var sd:SettingsData = cast Json.parse(data).config;

			onSuccess(sd);
		}, function(data) {
			onError(data);
		});

		httpReq.get();
	}

	private function updateSettings(onSuccess:SettingsData->Void, onError:Dynamic->Void) {
		var serverUrl:String = js.Browser.document.location.href;
		var path:String = "setconfig";
		var dataStr:String = Json.stringify(settings);

		var httpReq:HTTPRequester = new HTTPRequester(serverUrl + path, dataStr, function(data:Dynamic) {
			onSuccess(data);
		}, function(data) {
			onError(data);
		});

		httpReq.post();
	}

	public function registerSettingUpdate(updateFunction:SettingsData->Void) {
		updateFunctions.push(updateFunction);
	}

	public function getCardByCardId(id:String):CardData {
		var cd:CardData = null;

		for (card in settings.cards) {
			if (card.id == id) {
				return card;
			}
		}
		return cd;
	}

	public function updateCard(updatedCard:CardData, onComplete:Dynamic->Void) {
		for (i in 0...settings.cards.length) {
			var card:CardData = settings.cards[i];
			if (card.id == updatedCard.id) {
				settings.cards[i] = updatedCard;
				updateSettings(onComplete, onComplete);
			}
		}
	}
}
