package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import weblink.Request;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;
import weblink.Weblink;

class TiggerCardRoute extends Route {
	public function new(server:Weblink) {
		super("/trigger", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		var query:Dynamic = request.query();
		var cardId:String = Reflect.getProperty(query, "cardid");
		this.response.send("OK");

		if (SettingsManager.instance.hasCard(cardId) == true) {
			USER_MESSAGE("Manual Trigger " + cardId);
			ActionManager.instance.doAction(cardId);
		}
	}
}
