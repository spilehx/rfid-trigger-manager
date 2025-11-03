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
	}

	private function setupHaxeApp(appContainerId:String) {
		LOG("setupHaxeApp");
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
