package spilehx.rfidtriggeradmin.page;

import haxe.Constraints.Function;
import haxe.ui.core.Component;
import spilehx.rfidtriggeradmin.page.components.nowplayingidleclock.NowPlayingIdleClockComponent;
import spilehx.config.RFIDTriggerAdminSettings;
import spilehx.config.RFIDTriggerAdminFonts;
import haxe.ui.components.Label;
import spilehx.rfidtriggeradmin.tools.AnimateEffect;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import haxe.ui.containers.VBox;
import spilehx.rfidtriggeradmin.page.components.nowplaying.NowPlayingImageComponent;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;

class NowPlayingPage extends Box {
	private var contentContainer:VBox;
	private var activeCardId:String;
	private var nowPlayingLabel:Label;

	private static final FADE_DUR:Float = 1;
	private static final TRANSITION_MID_PAUSE:Float = .5;

	private var nowPlayingImageComponent:NowPlayingImageComponent;
	private var nowPlayingIdleClockComponent:NowPlayingIdleClockComponent;
	private var transitionInProgress:Bool = false;

	public function new() {
		super();
		activeCardId = "";
		init();
	}

	private function init() {
		this.percentHeight = this.percentWidth = 100;
		this.registerEvent(UIEvent.SHOWN, onPageShown);
	}

	private function onPageShown(e) {
		this.unregisterEvent(UIEvent.SHOWN, onPageShown);
		setupPage();
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onConfigUpdate);
	}

	private function onConfigUpdate(settings:SettingsData) {
		updateContent(settings);
	}

	private function setupPage() {
		contentContainer = new VBox();
		contentContainer.horizontalAlign = contentContainer.verticalAlign = "center";
		contentContainer.percentWidth = 70;
		contentContainer.percentHeight = 60;
		this.addComponent(contentContainer);

		nowPlayingIdleClockComponent = new NowPlayingIdleClockComponent();
		nowPlayingIdleClockComponent.percentHeight = 80;
		nowPlayingIdleClockComponent.verticalAlign = nowPlayingIdleClockComponent.horizontalAlign = "center";
		this.addComponent(nowPlayingIdleClockComponent);

		nowPlayingImageComponent = new NowPlayingImageComponent();
		nowPlayingImageComponent.percentHeight = 80;
		nowPlayingImageComponent.percentWidth = 100;
		nowPlayingImageComponent.horizontalAlign = "center";
		contentContainer.addComponent(nowPlayingImageComponent);

		nowPlayingLabel = new Label();
		nowPlayingLabel.percentHeight = 80;
		nowPlayingLabel.horizontalAlign = "center";

		nowPlayingLabel.textAlign = "center";
		RFIDTriggerAdminFonts.SET_FONT_XL(nowPlayingLabel, true);
		nowPlayingLabel.color = RFIDTriggerAdminSettings.NOWPLAYING_TEXT_COLOUR;
		contentContainer.addComponent(nowPlayingLabel);
	}

	private function updateContent(settings:SettingsData) {
		var activeCard:CardData = RFIDTriggerAdminConfigManager.instance.getActiveCard();
		var updatedActiveCardId = activeCard?.id ?? "";
		var stateChange:Bool = (activeCardId != updatedActiveCardId);
		var stateChangeWhilePlaying:Bool = (stateChange == true && activeCardId != "");

		if (stateChange == true && transitionInProgress == false) {
			transitionInProgress = true;
			activeCardId = updatedActiveCardId;

			if (activeCardId != "") {
				setActiveState(activeCard, stateChangeWhilePlaying);
			} else {
				setInactiveState();
			}
		}
	}

	private function setActiveState(activeCard:CardData, stateChangeWhilePlaying:Bool = false) {
		var toShow:Component = contentContainer;
		var toHide:Component = nowPlayingIdleClockComponent;

		if (stateChangeWhilePlaying == true) {
			toHide = contentContainer;
		}

		transitionSwap(toShow, toHide, function() {
			nowPlayingImageComponent.update();
			nowPlayingLabel.text = activeCard.name;
		});
	}

	private function setInactiveState() {
		transitionSwap(nowPlayingIdleClockComponent, contentContainer);
	}

	private function transitionSwap(toShow:Component, toHide:Component, intermediateFunction:Function = null) {
		AnimateEffect.fadeOutForward(toHide, FADE_DUR, function() {
			if (intermediateFunction != null) {
				intermediateFunction();
			}

			toShow.hidden = true;
			var pauseInMs:Int = Math.round(TRANSITION_MID_PAUSE * 1000);

			AnimateEffect.executeAfterDelay(pauseInMs, function() {
				AnimateEffect.bounceInForward(toShow, FADE_DUR, function() {
					transitionInProgress = false;
				});
			});
		});
	}
}
