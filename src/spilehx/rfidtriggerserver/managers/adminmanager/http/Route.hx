package spilehx.rfidtriggerserver.managers.adminmanager.http;

import haxe.Json;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import wtri.Server;
import wtri.Request;
import wtri.Response;

class Route {
	static var GET_METHOD:String = "GET";
	static var POST_METHOD:String = "POST";
	static var PUT_METHOD:String = "PUT";
	static var HEAD_METHOD:String = "HEAD";

	@:isVar public var path(default, null):String;
	@:isVar public var method(default, null):String;
	public var dataObjectClassName:String;
	public var dataObjectClass:Class<RestDataObject>;

	#if (!js)
	// private var response:weblink.Response;
	// private var request:weblink.Request;
	private var response:Response;
	private var request:Request;

	public function new(path:String, dataObject:RestDataObject, methodType:String, server:Server) {
		this.path = path;
		this.method = methodType;
		this.dataObjectClass = Type.getClass(dataObject);
		// if (methodType == GET_METHOD) {
		// 	server.get(path, handler);
		// 	server.post(path, notImplementedHandler);
		// 	server.put(path, notImplementedHandler);
		// } else if (methodType == POST_METHOD) {
		// 	server.post(path, handler);
		// 	server.get(path, notImplementedHandler);
		// 	server.put(path, notImplementedHandler);
		// } else if (methodType == PUT_METHOD) {
		// 	server.put(path, handler);
		// 	server.get(path, notImplementedHandler);
		// 	server.post(path, notImplementedHandler);
		// } else if (methodType == HEAD_METHOD) {
		// 	server.head(path, handler);
		// } else {
		// 	LOG_ERROR("Method Not Found");
		// }
	}

	public function isMatch(req:Request):Bool {
		// LOG("path " + req.path + "==" + path + "&& method" + req.method + "==" + method);
	
		// if(req.method == POST_METHOD){
			// LOG("req.method"+req.method);
		// }
	
		return (req.path == path && req.method == method);
	}

	// private function notImplementedHandler(request:wtri.Request, response:wtri.Response) {
	// 	var err:String = "BAD METHOD " + Date.now() + " , " + request.method + " , " + request.path;
	// 	LOG_WARN(err);
	// 	var responseObject = {err: err};
	// 	var responseContent:String = haxe.Json.stringify(responseObject, "\t");
	// 	this.response = response;
	// 	addHeadersToResponse(this.response);
	// 	// this.response.status = 400;
	// 	// this.response.send(responseContent);
	// }

	public function handler(request:wtri.Request, response:wtri.Response) {
		this.response = response;
		this.request = request;
		onRequest(request);
		// 	this.response.headers.set(Content_Length, Std.string(b.length));
		// this.response.headers.set(Content_Type, "text/plain; charset=utf-8");

		// this.response.writeHead(OK); // optional; end() would call it anyway
		// this.response.end(OK);
	}

	// private function sendGenericBadRequestResponse(?msg:String = null) {
	// 	var err:String = " Internal Server Error " + Date.now() + " , " + request.method + " , " + request.path;
	// 	LOG_WARN(err);
	// 	if (msg != null) {
	// 		err = err + " , " + msg;
	// 	}
	// 	var responseObject = {err: err};
	// 	var responseContent:String = haxe.Json.stringify(responseObject, "\t");
	// 	addHeadersToResponse(this.response);
	// 	// this.response.status = 500;
	// 	// this.response.send(responseContent);
	// }

	private function onRequest(request:wtri.Request) {
		LOG_ERROR("MUST OVERRIDE");
		// var genericRequestDataObject:RestDataObject = new RestDataObject();
		// var requestDataObjectInstance = Type.createInstance(dataObjectClass, []);
	}

	private function sendData(data:RestDataObject) {
		response.headers.set(Content_Type, "text/json; charset=utf-8");
		send(Json.stringify(data));
	}

	private function sendHTML(content:String) {
		response.headers.set(Content_Type, "text/html; charset=utf-8");
		send(content);
	}

	private function sendTxt(content:String) {
		response.headers.set(Content_Type, "text/plain; charset=utf-8");
		send(content);
	}


	private function send(content:String) {
		var b = Bytes.ofString(content);
		response.body = new BytesInput(b);
		respond(b.length);
	}

	// function onServerNewRequest(requestDataObjectInstance:Dynamic) {
	// 	LOG_WARN("onServerNewRequest -  Override in child class");
	// 	// respond(requestDataObjectInstance);
	// }
	// function onServerGetRequest(requestDataObjectInstance:Dynamic) {
	// 	LOG_WARN("onServerGetRequest -  Override in child class");
	// 	// respond(requestDataObjectInstance);
	// }
	// function onServerSetRequest(requestDataObjectInstance:Dynamic) {
	// 	LOG_WARN("onServerSetRequest -  Override in child class");
	// 	// respond(requestDataObjectInstance);
	// }

	private function respond(reponseLength:Int) {

		addHeadersToResponse(reponseLength);

		this.response.end(OK);
	


	}

	private function addHeadersToResponse(reponseLength:Int) {
		// TODO: Security issue?
		// this.response.headers.add("Access-Control-Allow-Origin", "*");

		response.headers.set(Content_Length, Std.string(reponseLength));
		// response.headers.set(Content_Type, "text/html; charset=utf-8");
		// response.headers.set(Content_Type, "text/plain; charset=utf-8");
	}
	#end
}
