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
	private static var ADMIN_PAGE_SCRIPT_TAG:String = "$ADMIN_PAGE_SCRIPT_TAG";
	private static var ADMIN_PAGE_STYLE_TAG:String = "/*$ADMIN_PAGE_STYLE_TAG*/";
	private static var ADMIN_PAGE_HTML_CONTENT:String = macrotools.Macros.fileAsString("./assets/index.html");
	private static var ADMIN_PAGE_JS_CONTENT:String = macrotools.Macros.fileAsString("./assets/main.js");
	private static var ADMIN_PAGE_CSS_CONTENT:String = macrotools.Macros.fileAsString("./assets/style.css");

	public static function getAdminPageContent():String {
		var adminPageContentent:String = "";
		if (ADMIN_PAGE_HTML_CONTENT == "" || ADMIN_PAGE_JS_CONTENT == "") {
			return "ERROR: Sorry, Admin page content not incuded at build time";
		}

		adminPageContentent = ADMIN_PAGE_HTML_CONTENT.split(ADMIN_PAGE_SCRIPT_TAG).join(ADMIN_PAGE_JS_CONTENT);
		adminPageContentent = adminPageContentent.split(ADMIN_PAGE_STYLE_TAG).join(ADMIN_PAGE_CSS_CONTENT);

		return adminPageContentent;
	}
}
