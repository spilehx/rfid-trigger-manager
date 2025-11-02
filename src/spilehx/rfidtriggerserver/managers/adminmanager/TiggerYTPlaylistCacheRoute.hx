package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.helpers.CacheManager;
import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import weblink.Request;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;
import weblink.Weblink;

class TiggerYTPlaylistCacheRoute extends Route {
	public function new(server:Weblink) {
		super("/triggerytcache", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		var query:Dynamic = request.query();
		if (query != null) {
			var cardId:String = Reflect.getProperty(query, "cardid");
			if (SettingsManager.instance.hasCard(cardId) == true) {
				var card:CardData = SettingsManager.instance.getCard(cardId);
				USER_MESSAGE("Cache Trigger " + cardId);
				if (card.action == "YTPlayListAction") {
					CacheManager.instance.cacheYouTubePlaylistToAudio(card.id, true);
				}
			}
		}

		this.response.send("OK");
	}
}
