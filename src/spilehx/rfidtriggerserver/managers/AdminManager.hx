package spilehx.rfidtriggerserver.managers;

import spilehx.rfidtriggerserver.managers.adminmanager.AdminRoute;
import spilehx.rfidtriggerserver.managers.adminmanager.SetConfigRoute;
import spilehx.rfidtriggerserver.managers.adminmanager.GetConfigRoute;
import spilehx.rfidtriggerserver.managers.adminmanager.http.HTTPServer;



class AdminManager extends spilehx.core.ManagerCore{
	public static final instance:AdminManager = new AdminManager();

	// private function new() {}

	public function init() {
		addRoutes();
		HTTPServer.instance.startServer(1337);
	}

	private function addRoutes() {
		HTTPServer.instance.addRoute(GetConfigRoute);
		HTTPServer.instance.addRoute(SetConfigRoute);
		HTTPServer.instance.addRoute(AdminRoute);
	}
}
