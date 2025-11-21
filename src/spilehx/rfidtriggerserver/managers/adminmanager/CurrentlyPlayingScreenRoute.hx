package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;
import haxe.macro.Expr;
import sys.io.File;
import weblink.Request;

import weblink.Weblink;

class CurrentlyPlayingScreenRoute extends Route {
	public function new(server:Weblink) {
		super("/currentlyplaying", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(AdminPageTools.getAdminPageContent());
	}
}

