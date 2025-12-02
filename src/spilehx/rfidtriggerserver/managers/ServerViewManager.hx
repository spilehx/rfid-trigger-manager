package spilehx.rfidtriggerserver.managers;

import haxe.ui.events.MouseEvent;
import haxe.Timer;
import spilehx.rfidtriggeradmin.tools.TweenTools;
import spilehx.rfidtriggerserver.managers.serverviewmanager.LogoSplashServerViewPage;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;
import haxe.Constraints.Function;
import haxe.ui.HaxeUIApp;

class ServerViewManager extends spilehx.core.ManagerCore {
	public static final instance:ServerViewManager = new ServerViewManager();

	private var content:Box;
	private var currentPage:ServerViewPage;
	private var app:HaxeUIApp;

	private var viewDisabled:Bool = false;

	public function init(onViewAppReady:Function, viewDisabled:Bool = false) {
		this.viewDisabled = viewDisabled;

		if (this.viewDisabled == true) {
			USER_MESSAGE("Server running in headless mode");
			onViewAppReady();
			return;
		}

		content = new Box();
		content.percentHeight = 100;
		content.percentWidth = 100;
		app = new HaxeUIApp();
	
		app.ready(function() {
			app.addComponent(content);
			app.start();
			onViewAppReady();
		});
	}

	private function clearContent() {
		if (currentPage != null) {
			if (content.containsComponent(currentPage) == true) {
				content.removeComponent(currentPage, true);
				currentPage = null;
			}
		}
	}

	private function showPage(serverViewPageClass:Class<ServerViewPage>) {
		if (this.viewDisabled == true) {
			return;
		}

		clearContent();
		currentPage = Type.createInstance(serverViewPageClass, []);
		content.addComponent(currentPage);
	}

	public function showSplashPage() {
		showPage(LogoSplashServerViewPage);
	}
}

@:build(haxe.ui.ComponentBuilder.build("assets/serverViewAssets/ServerViewPage.xml"))
class ServerViewPage extends Box {
	public function new() {
		super();
		this.registerEvent(UIEvent.SHOWN, onPageShown);
		this.registerEvent(UIEvent.HIDDEN, onPageHidden);
	}

	private function onPageShown(e) {
		this.percentHeight = this.percentWidth = 100;
		this.backgroundColor = 0xB1B1B1;
		setupContent();
	}

	private function onPageHidden(e) {}

	private function setupContent() {}

	public function tweenWindowSize(windowWidthTarget:Int, windowHeightTarget:Int, duration = 1000) {
		var startW:Int = hxd.Window.getInstance().width;
		var startH:Int = hxd.Window.getInstance().height;
		var steps:Int = 150;
		var timeStep:Int = Math.round(duration / steps);

		var maxW:Int = hxd.Window.getInstance().getCurrentDisplaySetting().width;
		var maxH:Int = hxd.Window.getInstance().getCurrentDisplaySetting().height;

		if (windowWidthTarget > maxW) {
			windowWidthTarget = maxW;
		}

		if (windowHeightTarget > maxH) {
			windowHeightTarget = maxH;
		}

		var wTweenVals:Array<Float> = TweenTools.getTweenValueArray(startW, windowWidthTarget, steps);
		var hTweenVals:Array<Float> = TweenTools.getTweenValueArray(startH, windowHeightTarget, steps);

		var timer:Timer = new Timer(timeStep);
		timer.run = function() {
			if (wTweenVals.length > 0) {
				var newW:Int = Math.round(wTweenVals.shift());
				var newH:Int = Math.round(hTweenVals.shift());
				setWindowSize(newW, newH);
			} else {
				timer.stop();
				// Ensure exact final value
				setWindowSize(windowWidthTarget, windowHeightTarget);
			}
		};
	}

	private function setWindowSize(windowWidth:Int, windowHeight:Int) {
		hxd.Window.getInstance().resize(windowWidth, windowHeight);
	}

	private function setWindowSizeToPercent(wCent:Int, hCent:Int) {
		var w:Int = Math.round(hxd.Window.getInstance().getCurrentDisplaySetting().width*(wCent/100));
		var h:Int = Math.round(hxd.Window.getInstance().getCurrentDisplaySetting().height*(hCent/100));
		hxd.Window.getInstance().resize(w, h);
	}
}
