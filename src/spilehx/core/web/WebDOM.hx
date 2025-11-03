package spilehx.core.web;

import js.html.DOMRect;
import haxe.ui.core.Component;
import haxe.ui.components.Label;
import js.html.Event;
import haxe.ui.events.UIEvent;
import js.html.Location;
import js.Browser;
import js.html.Window;
import js.html.Element;
import js.Browser.document;

class WebDOM {

	public static final instance:WebDOM = new WebDOM();
	@:isVar public var html(get, set):Element;
	@:isVar public var head(get, set):Element;
	@:isVar public var body(get, set):Element;
	@:isVar public var window(get, set):Window;

	private function new() {
		setElements();
	}

	public static function applyTextStyle(lable:Label, style:String){

		lable.element.classList.add(style);
	}

	public static function getGlobalPosition(positionComponent:Component,?hcenter:Bool = false,?vcenter:Bool = false):Dynamic{
		var pos:Dynamic = {};

		var viewPortRect:DOMRect = WebDOM.getElementById("gameviewport").getBoundingClientRect();
		var positionComponentRect:DOMRect = positionComponent.element.getBoundingClientRect();
		
		pos.x = positionComponentRect.left - viewPortRect.left;
		pos.y = positionComponentRect.top - viewPortRect.top;


		if(hcenter == true){
			pos.x += positionComponentRect.width/2;
			// pos.y += positionComponentRect.height/2;
		}

		if(vcenter == true){
			// pos.x += positionComponentRect.width/2;
			pos.y += positionComponentRect.height/2;
		}

		return pos;
	}


	private function setElements() {
		this.window = Browser.window;
		this.html = js.Browser.document.getElementsByTagName("html")[0];
		this.head = js.Browser.document.getElementsByTagName("head")[0];
		this.body = js.Browser.document.getElementsByTagName("body")[0];
	}

	public static function setPageTitle(title:String) {
		document.title = title;
	}

	public static function getElementById(id:String){
		return js.Browser.document.getElementById(id);
	}

	public static function refreshPage() {
		js.Browser.document.location.reload(true);
	}

	function get_window():Window {
		return window;
	}

	function set_window(window):Window {
		return this.window = window;
	}

	function get_head():Element {
		return head;
	}

	function set_head(head):Element {
		return this.head = head;
	}

	function get_body():Element {
		return body;
	}

	function set_body(body):Element {
		return this.body = body;
	}

	function get_html():Element {
		return html;
	}

	function set_html(html):Element {
		return this.html = html;
	}
}