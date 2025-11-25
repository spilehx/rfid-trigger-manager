package spilehx.rfidtriggerserver.managers.adminmanager.http;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Input;
import wtri.Response;
import wtri.Request;
import wtri.Server;

// import weblink.Weblink;
class HTTPServer {
	// private var server:Weblink;
	private var server:Server;
	private var routeClasses:Array<Class<Route>>;

	public var routes:Array<Route>;

	private var port:Int;

	public static final instance:HTTPServer = new HTTPServer();

	// private for singleton use only
	private function new() {
		routeClasses = new Array<Class<Route>>();
		routes = new Array<Route>();
		server = new wtri.Server(onHandle);
	}

	public function startServer(?port:Int = 1337) {
		this.port = port;
		instantiateRoutes();
		// server.listen(port, false);
		server.listen(port,"localhost", true);
	}

	private function onHandle(req:Request, res:Response) {
		var path:String = req.path;
		var method:String = req.method;

		var route = findRoute(req);
		if (route == null) {
			// LOG_WARN("404 route requested " + method + " " + path);
			res.end(BAD_REQUEST);
		} else {
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
