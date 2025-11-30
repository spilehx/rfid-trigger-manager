package spilehx.rfidtriggeradmin;

import spilehx.config.RFIDTriggerAdminSettings;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import haxe.Json;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import spilehx.core.http.HTTPRequester;
import haxe.Timer;

class RFIDTriggerAdminConfigManager {
	private var updateFunctions:Array<SettingsData->Void>;
	private var updateTimer:Timer;
	public var settings:SettingsData;
	private var serverUrl:String;
	public static final instance:RFIDTriggerAdminConfigManager = new RFIDTriggerAdminConfigManager();

	private function new() {}

	public function init() {
		updateFunctions = new Array<SettingsData->Void>();
		serverUrl = js.Browser.document.location.origin + "/";
		startAutoUpdate();
	}

	private function startAutoUpdate(interval:Int = 0) {
		loadSettings(onLoadSuccess, onLoadError);
	}

	private function reloadSettings() {
		var delay:Timer = new Timer(RFIDTriggerAdminSettings.UPDATE_INTERVAL);
		delay.run = function() {
			delay.stop();
			delay = null;
			loadSettings(onLoadSuccess, onLoadError);
		}
	}

	private function onLoadSuccess(sd:SettingsData) {
		RFIDTriggerAdminView.instance.hideNoConnectComponent();
		settings = sd;
		sendUpdates();
	}

	private function sendUpdates() {
		for (updateFunction in updateFunctions) {
			updateFunction(settings);
		}
	}

	private function onLoadError(response:Dynamic) {
		LOG_ERROR("onLoadError");
		RFIDTriggerAdminView.instance.showNoConnectComponent();
	}

	private function loadSettings(onSuccess:SettingsData->Void, onError:Dynamic->Void) {
		var path:String = "config";
		var httpReq:HTTPRequester = new HTTPRequester(serverUrl + path, "", function(data:Dynamic) {
			var sd:SettingsData = cast Json.parse(data).config;
			sd.logs = cast Json.parse(data).logs;
			onSuccess(sd);
			reloadSettings();
		}, function(data) {
			onError(data);
			reloadSettings();
		}, RFIDTriggerAdminSettings.REQUEST_TIMEOUT);

		httpReq.get();
	}

	public function sendTriggerRequest(cardId:String) {
		var path:String = "trigger?cardid=" + cardId;

		var httpReq:HTTPRequester = new HTTPRequester(serverUrl + path, "", function(data:Dynamic) {}, function(data) {});

		httpReq.get();
	}

	public function sendCacheRequest(cardId:String) {
		var path:String = "triggerytcache?cardid=" + cardId;

		var httpReq:HTTPRequester = new HTTPRequester(serverUrl + path, "", function(data:Dynamic) {}, function(data) {});

		httpReq.get();
	}

	public function sendImgUploadRequest(cardId:String, imgData:String) {
		var path:String = "uploadimage";

		var data = {
			cardId: cardId,
			file: imgData
		};

		var httpReq:HTTPRequester = new HTTPRequester(serverUrl + path, Json.stringify(data), function(data:Dynamic) {}, function(data) {});

		httpReq.post();
	}

	private function updateSettings(onSuccess:SettingsData->Void, onError:Dynamic->Void) {
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

	public function updateDevice(device:String, onComplete:Dynamic->Void) {
		settings.deviceID = device;
		updateSettings(onComplete, onComplete);
	}

	public function getActiveCard():CardData {
		for (i in 0...settings.cards.length) {
			var card:CardData = settings.cards[i];
			if (card.active == true) {
				return card;
			}
		}

		return null;
	}
}
