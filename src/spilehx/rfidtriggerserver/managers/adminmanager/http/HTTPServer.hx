package spilehx.rfidtriggerserver.managers.adminmanager.http;

import wtri.Response;
import wtri.Request;
import wtri.Server;

class HTTPServer {
	private var server:Server;
	private var routeClasses:Array<Class<Route>>;

	public var routes:Array<Route>;

	private var port:Int;

	public static final instance:HTTPServer = new HTTPServer();

	// private for singleton use only
	private function new() {
		routeClasses = new Array<Class<Route>>();
		routes = new Array<Route>();
	}

	public function startServer(?port:Int = 1337) {
		this.port = port;
		instantiateRoutes();
		server = new wtri.Server(onHandle);
		server.listen(port, "localhost");

		// server = new wtri.Server(onHandle).listen(port, "localhost");
	}

	private function onHandle(req:Request, res:Response) {
		var route = findRoute(req);
		if (route == null) {
			// LOG_WARN("404 route requested " + method + " " + path);
			res.end(BAD_REQUEST);
		} else {
			// trace("BEFOR "+req.path);
			route.handler(req, res);
		}
	}

	private function findRoute(req:Request):Route {
		for (route in routes) {
			if (route.isMatch(req)) {
				return route;
			}
		}

		return null;
	}

	public function addRoute(routeClass:Class<Route>) {
		routeClasses.push(routeClass);
	}

	private function instantiateRoutes() {
		for (routeClass in routeClasses) {
			var route:Route = Type.createInstance(routeClass, [server]);
			routes.push(route);
		}
	}
}
