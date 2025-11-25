package spilehx.rfidtriggerserver.managers.adminmanager;

import wtri.Request;
import wtri.Server;
import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;



class AdminRoute extends Route {
	public function new(server:Server) {
		super("/", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		sendHTML(AdminPageTools.getAdminPageContent());
	}
}
