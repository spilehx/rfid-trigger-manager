package spilehx.rfidtriggeradmin.page;

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
	private var nowPlayingImageComponent:NowPlayingImageComponent;
	private var currentlyActive:Bool = false;
	private var nowPlayingLabel:Label;
	private var nInactive:Int = 0;

	private static final FADE_DUR:Float = .5;

	private var inactiveLabel:Label;

	private static final SHOW_IDLE_TIME_AFTER:Int = 5;

	public function new() {
		super();
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

	private function setupPage() {
		contentContainer = new VBox();
		contentContainer.horizontalAlign = contentContainer.verticalAlign = "center";
		contentContainer.percentWidth = 70;
		contentContainer.percentHeight = 60;
		this.addComponent(contentContainer);

		nowPlayingImageComponent = new NowPlayingImageComponent();

		nowPlayingImageComponent.percentHeight = 80;
		nowPlayingImageComponent.percentWidth = 100;
		nowPlayingImageComponent.horizontalAlign = "center";

		contentContainer.addComponent(nowPlayingImageComponent);

		nowPlayingLabel = new Label();
		nowPlayingLabel.percentWidth = 80;
		nowPlayingLabel.horizontalAlign = "center";

		nowPlayingLabel.textAlign = "center";
		RFIDTriggerAdminFonts.SET_FONT_XL(nowPlayingLabel, true);
		nowPlayingLabel.color = RFIDTriggerAdminSettings.NOWPLAYING_TEXT_COLOUR;
		contentContainer.addComponent(nowPlayingLabel);

		inactiveLabel = new Label();
		inactiveLabel.percentWidth = 80;
		inactiveLabel.verticalAlign = inactiveLabel.horizontalAlign = "center";
		inactiveLabel.textAlign = "center";
		RFIDTriggerAdminFonts.SET_FONT_XL(inactiveLabel, true, false);
		inactiveLabel.color = RFIDTriggerAdminSettings.NOWPLAYING_TEXT_COLOUR;
		this.addComponent(inactiveLabel);
		inactiveLabel.opacity = 1;
		inactiveLabel.text = getDateTimeString();
	}

	private function onConfigUpdate(settings:SettingsData) {
		setContent(settings);
		inactiveLabel.text = getDateTimeString();
	}

	private function setContent(settings:SettingsData) {
		var activeCard:CardData = RFIDTriggerAdminConfigManager.instance.getActiveCard();
		if (activeCard != null) {
			if (activeCardId != activeCard.id) {
				activeCardId = activeCard.id;
				setInactiveState();
				AnimateEffect.executeAfterDelay(Math.round(FADE_DUR * 1000), function() {
					setActiveState(activeCard);
				});
			}
		} else {
			activeCardId = "";
			setInactiveState();
		}
	}

	private function setActiveState(activeCard:CardData) {
		if (currentlyActive != true) {
			currentlyActive = true;
			contentContainer.opacity = 1;
			nowPlayingImageComponent.update();
			nowPlayingLabel.text = activeCard.name;

			nInactive = 0;

			hideIdleTime();

			AnimateEffect.bounceInForward(contentContainer, FADE_DUR, function() {
				contentContainer.opacity = 1;
			});
		}
	}

	private function setInactiveState() {
		if (currentlyActive != false) {
			currentlyActive = false;

			AnimateEffect.fadeOutForward(contentContainer, FADE_DUR, function() {
				contentContainer.opacity = 0;
			});
		}

		nInactive++;
		if (nInactive == SHOW_IDLE_TIME_AFTER) {
			showIdleTime();
		}
	}

	private function showIdleTime() {
		if (inactiveLabel.opacity == 0) {
			AnimateEffect.bounceInForward(inactiveLabel, FADE_DUR, function() {
				inactiveLabel.opacity = 1;
			});
		}
	}

	private function hideIdleTime() {
		if (inactiveLabel.opacity == 1) {
			inactiveLabel.opacity = 0;
		}
	}

	private function getDateTimeString():String {
		var now = Date.now();

		var day = StringTools.lpad(Std.string(now.getDate()), "0", 2);
		var month = StringTools.lpad(Std.string(now.getMonth() + 1), "0", 2);
		var year = Std.string(now.getFullYear());

		var hour = StringTools.lpad(Std.string(now.getHours()), "0", 2);
		var minute = StringTools.lpad(Std.string(now.getMinutes()), "0", 2);
		var second = StringTools.lpad(Std.string(now.getSeconds()), "0", 2);

		return '${day}/${month}/${year}\n${hour}:${minute}:${second}';
	}
}
