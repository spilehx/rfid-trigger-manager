package adminmanager;

import weblink.Request;
import adminmanager.http.RestDataObject;
import adminmanager.http.Route;
import weblink.Weblink;

class AdminRoute extends Route {
	private var pageTemplate:String = "";

	public function new(server:Weblink) {
		super("/", new RestDataObject(), Route.GET_METHOD, server);
		pageTemplate = loadTemplate();
	}

	override function onRequest(request:Request) {
		this.response.send(pageTemplate);
	}

	private function loadTemplate():String {
		var ADMIN_TEMPLATE_PATH:String = "./index.html";
		var template:String = sys.io.File.getContent(ADMIN_TEMPLATE_PATH);

		return template;
	}
}
