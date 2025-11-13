package spilehx.rfidtriggeradmin;

import spilehx.core.web.WebDOM;
import haxe.ui.Toolkit;
import js.html.Element;
import haxe.ui.ToolkitAssets;
import haxe.ui.HaxeUIApp;
import spilehx.rfidtriggeradmin.page.MainPage;

class RFIDTriggerAdminView {
	var _app:HaxeUIApp;

	public function new() {
		LOG("RFIDTriggerAdminView - Starting");
		if (js.Browser.document.readyState == "complete") {
			onDomLoaded();
		} else {
			WebDOM.instance.window.onload = onDomLoaded;
		}
	}

	private function onDomLoaded() {
		setupHaxeApp("app");
		setPageStyle();
	}

	private function setPageStyle(){
		var colString:String = StringTools.replace(RFIDTriggerAdminSettings.PAGE_BG_COLOUR,"0x","#");
		js.Browser.document.body.style.backgroundColor = colString;
	}

	private function setupHaxeApp(appContainerId:String) {
		var appDiv:Element = js.Browser.document.getElementById(appContainerId);
		Toolkit.init({
			container: appDiv
		});

		_app = new HaxeUIApp(ToolkitAssets.instance.options);
		_app.ready(haxeUiAppReady);
	}

	private function haxeUiAppReady() {
		_app.start();
		onReady();
	}

	private function onReady() {
        _app.addComponent(new MainPage());
	}
}
