package adminmanager;

import settings.CardData;
import settings.SettingsManager;
import weblink.Request;
import adminmanager.http.Route;
import weblink.Weblink;

class SetConfigRoute extends Route {
	public function new(server:Weblink) {
		super("/setconfig", new ConfigRouteData(), Route.POST_METHOD, server);
	}

	override function onRequest(request:Request) {
		var requestDataObj:Dynamic = haxe.Json.parse(Std.string(request.data));
		var newCardArray:Array<CardData> = requestDataObj.cards;

		if(SettingsManager.instance.settings.deviceID != requestDataObj.deviceID){
			USER_MESSAGE("Updated device: " + requestDataObj.deviceID);
			SettingsManager.instance.settings.deviceID = requestDataObj.deviceID;
		}

		SettingsManager.instance.verboseLogging = requestDataObj.verboseLogging;

		var cardFieldsToUpdate:Array<String> = ["name", "enabled", "action", "command",];

		for (newCard in newCardArray) {
			var updated:Bool = false;
			if (SettingsManager.instance.hasCard(newCard.id) == true) {
				for (field in cardFieldsToUpdate) {
					var storedCard:CardData = SettingsManager.instance.getCard(newCard.id);
					var currentValue:Dynamic = Reflect.getProperty(storedCard, field);
					var newValue:Dynamic = Reflect.getProperty(newCard, field);
					if (currentValue != newValue) {
						updated = true;
						Reflect.setField(storedCard, field, newValue);
						SettingsManager.instance.updateCard(storedCard);
					}
				}
			}

			if (updated == true) {
				USER_MESSAGE("Updated card: " + newCard.id);
			}
		}
		var configRouteData:ConfigRouteData = new ConfigRouteData();
		configRouteData.config = SettingsManager.instance.settings;
		respond(configRouteData);
	}
}
