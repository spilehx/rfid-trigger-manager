package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.rfidtriggerserver.helpers.ImageFileHelpers;
import haxe.crypto.Base64;
import sys.io.File;
import haxe.Json;
import haxe.io.Bytes;
import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;
import weblink.Request;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;
import weblink.Weblink;

class UploadImageRoute extends Route {
	public function new(server:Weblink) {
		super("/uploadimage", new RestDataObject(), Route.POST_METHOD, server);
	}

	override function onRequest(request:Request) {
		var data:Dynamic = Json.parse(Std.string(request.data));
		var cardId:String = Reflect.getProperty(data, "cardId");
		var fileString:String = Reflect.getProperty(data, "file");
		ImageFileHelpers.saveImage(fileString, cardId);
		this.response.send("OK");
	}

}
