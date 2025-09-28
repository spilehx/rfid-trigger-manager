// package adminmanager;

// import adminmanager.http.HTTPServerThreaded;

// class AdminManager {
// 	public static final instance:AdminManager = new AdminManager();

// 	private function new() {}

// 	public function init() {
// 		addRoutes();
// 		HTTPServerThreaded.instance.startServer(1337);
// 	}

// 	private function addRoutes() {
// 		HTTPServerThreaded.instance.addRoute(GetConfigRoute);
// 		HTTPServerThreaded.instance.addRoute(SetConfigRoute);
// 		HTTPServerThreaded.instance.addRoute(AdminRoute);
// 	}
// }



package adminmanager;

import adminmanager.http.HTTPServer;

class AdminManager {
	public static final instance:AdminManager = new AdminManager();

	private function new() {}

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
