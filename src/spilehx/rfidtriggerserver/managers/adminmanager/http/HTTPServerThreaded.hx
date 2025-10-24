package spilehx.rfidtriggerserver.managers.adminmanager.http;

import weblink.Weblink;
import sys.thread.Thread;
import sys.thread.Mutex;

class HTTPServerThreaded {
	private var server:Weblink;
	private var routeClasses:Array<Class<Route>>;
	public var routes:Array<Route>;
	private var port:Int;

	// threading bits
	private var worker:Thread = null;
	private var started:Bool = false;
	private var mtx:Mutex = new Mutex();

	public static var instance(default, null) = new HTTPServerThreaded();

	private function new() {
		routeClasses = [];
		routes = [];
	}

	/** Register all routes before startAsync */
	public function addRoute(routeClass:Class<Route>) {
		routeClasses.push(routeClass);
	}

	/** Launch server on a background thread (non-blocking main thread). */
	public function startServer(port:Int):Void {
		// quick check without locking (best-effort)
		if (started) return;

		this.port = port;

		// mark started inside a small critical section
		mtx.acquire();
		if (started) { mtx.release(); return; }
		started = true;
		mtx.release();

		worker = Thread.create(() -> {
			server = new Weblink();
			instantiateRoutes();

			try {
				// run the blocking listen on this worker thread
				// (adjust signature if your Weblink.listen differs)
				server.listen(port);
			} catch (e:Dynamic) {
				trace('HTTPServer thread error: $e');
			}

			// cleanup ("finally"-like)
			mtx.acquire();
			started = false;
			mtx.release();
		});
	}

	/** Attempt graceful shutdown if Weblink exposes it. */
	// public function stop():Void {
	// 	// fast path: if not started or no server, nothing to do
	// 	if (!started || server == null) return;

	// 	for (m in ["shutdown", "close", "stop"]) {
	// 		if (Reflect.hasField(server, m)) {
	// 			var fn = Reflect.field(server, m);
	// 			try Reflect.callMethod(server, fn, []) catch (e:Dynamic) {
	// 				trace('HTTPServer.$m failed: $e');
	// 			}
	// 			break;
	// 		}
	// 	}
	// }

	private function instantiateRoutes():Void {
		for (routeClass in routeClasses) {
			var route:Route = Type.createInstance(routeClass, [server]);
			routes.push(route);
		}
	}
}
