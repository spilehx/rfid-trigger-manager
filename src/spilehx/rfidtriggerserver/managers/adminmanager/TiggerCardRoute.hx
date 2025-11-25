package spilehx.rfidtriggerserver.managers.adminmanager;

import wtri.Request;
import wtri.Server;
import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;

class TiggerCardRoute extends Route {
	public function new(server:Server) {
		super("/trigger", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
	LOG("TRIGGGER");
	
		var query:Dynamic = request.params;
		var cardId:String = Reflect.getProperty(query, "cardid");
		sendTxt("OK");

		if (SettingsManager.instance.hasCard(cardId) == true) {
			USER_MESSAGE("Manual Trigger " + cardId);
			ActionManager.instance.doAction(cardId);
		}
	}
}
