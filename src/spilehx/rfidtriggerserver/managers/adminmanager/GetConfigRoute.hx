package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.core.logger.LogStream;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;
import weblink.Request;
import weblink.Weblink;

class GetConfigRoute extends Route {
	public function new(server:Weblink) {
		super("/config", new ConfigRouteData(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		SettingsManager.instance.updateAvalibleDevices();
		var configRouteData:ConfigRouteData = new ConfigRouteData();
		configRouteData.config = SettingsManager.instance.settings;
		configRouteData.logs = LogStream.instance.logString;
		respond(configRouteData);
	}
}
