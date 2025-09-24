package adminmanager;

import haxe.macro.Expr;
import sys.io.File;
import weblink.Request;
import adminmanager.http.RestDataObject;
import adminmanager.http.Route;
import weblink.Weblink;

class AdminRoute extends Route {
	public function new(server:Weblink) {
		super("/", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(AdminPageTools.getAdminPageContent());
	}
}

class AdminPageTools {
	private static var ADMIN_PAGE_CONTENT:String = macrotools.Macros.fileAsString("./assets/index.html");

	public static function getAdminPageContent():String {
		if (ADMIN_PAGE_CONTENT == "") {
			return "ERROR: Sorry, Admin page content not incuded at build time";
		}

		return ADMIN_PAGE_CONTENT;
	}
}
