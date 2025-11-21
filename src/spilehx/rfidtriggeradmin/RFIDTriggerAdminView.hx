package spilehx.rfidtriggeradmin;

import spilehx.rfidtriggeradmin.page.NowPlayingPage;
import js.Browser;
import spilehx.config.RFIDTriggerAdminSettings;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.core.Component;
import spilehx.rfidtriggeradmin.page.components.modelwindow.ModalWindow;
import spilehx.core.web.WebDOM;
import haxe.ui.Toolkit;
import js.html.Element;
import haxe.ui.ToolkitAssets;
import haxe.ui.HaxeUIApp;
import spilehx.rfidtriggeradmin.page.MainPage;

class RFIDTriggerAdminView {
	public static final instance:RFIDTriggerAdminView = new RFIDTriggerAdminView();

	private var lastBuildStamp:Float;
	private var modal:ModalWindow;
	private var _app:HaxeUIApp;
	private var initalSettingsLoadComplete:Bool = false;

	private function new() {}

	public function init() {
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

	private function setPageStyle() {
		var colString:String = StringTools.replace(RFIDTriggerAdminSettings.PAGE_BG_COLOUR, "0x", "#");
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
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onConfigUpdate);
	}

	private function onConfigUpdate(settings:SettingsData) {
		if (initalSettingsLoadComplete == false) {
			initalSettingsLoadComplete = true;
			lastBuildStamp = settings.buildTime;

			routeToPage(settings);
		} else {
			// if backend has been updated refresh page
			if (lastBuildStamp != settings.buildTime) {
				Browser.location.reload();
			}
		}
	}

	private function forceConfig(settings:SettingsData) {
		if (settings.deviceID == "") {
			openModal(new ModalContentSettings());
		}
	}

	private function routeToPage(settings:SettingsData) {
		if (js.Browser.document.location.href.indexOf("currentlyplaying") > -1) {
			// set update to slower rate
			// RFIDTriggerAdminConfigManager.instance.stopAutoUpdate();
			// RFIDTriggerAdminConfigManager.instance.startAutoUpdate(RFIDTriggerAdminSettings.UPDATE_INTERVAL_SLOW);

			_app.addComponent(new NowPlayingPage());
		} else {
			_app.addComponent(new MainPage());
			forceConfig(settings);
		}
	}

	public function openModal(content:Component) {
		if (modal == null) {
			modal = new ModalWindow(content);
			_app.addComponent(modal);
		}
	}

	public function closeModal() {
		if (modal != null) {
			_app.removeComponent(modal);
			modal = null;
		}
	}
}
