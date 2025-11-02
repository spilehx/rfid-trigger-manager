package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.rfidtriggerserver.helpers.ImageFileHelpers;
import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import weblink.Request;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;
import weblink.Weblink;

class GetImageRoute extends Route {
	public function new(server:Weblink) {
		super("/getimage", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		var query:Dynamic = request.query();
		var cardId:String = SettingsManager.instance.getActiveCardId();
		if (Reflect.hasField(query, "cardid") == true) {
			cardId = Reflect.getProperty(query, "cardid");
		}
		this.response.set_contentType("image/jpeg");
		this.response.sendBytes(ImageFileHelpers.getCardImage(cardId));
	}
}
