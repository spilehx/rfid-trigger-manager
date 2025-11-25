package spilehx.rfidtriggerserver.managers.adminmanager;

import wtri.Request;
import wtri.Server;
import spilehx.core.logger.LogStream;
import spilehx.rfidtriggerserver.managers.adminmanager.http.Route;


class GetConfigRoute extends Route {
	public function new(server:Server) {
		super("/config", new ConfigRouteData(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		SettingsManager.instance.updateAvalibleDevices();
		var configRouteData:ConfigRouteData = new ConfigRouteData();
		configRouteData.config = SettingsManager.instance.settings;
		configRouteData.logs = LogStream.instance.logString;
		sendData(configRouteData);
	}
}
