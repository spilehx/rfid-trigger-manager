package adminmanager;

import logger.LogStream;
import settings.SettingsManager;
import weblink.Request;
import adminmanager.http.Route;
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
