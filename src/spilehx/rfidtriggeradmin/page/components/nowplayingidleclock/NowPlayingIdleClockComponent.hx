package spilehx.rfidtriggeradmin.page.components.nowplayingidleclock;

import spilehx.config.RFIDTriggerAdminSettings;
import haxe.ui.components.Label;
import haxe.Timer;
import spilehx.config.RFIDTriggerAdminFonts;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;

@:xml('
   	<box height="100%" verticalAlign="center" horizontalAlign="center">
		<vbox id="numberGrid" width="100%" height="100%" verticalAlign="center" horizontalAlign="center" verticalSpacing="0">
            <hbox width="100%" height="50%" horizontalAlign="center">
                <label id="hour1Label" textAlign="center" width="50%" verticalAlign="center" horizontalAlign="center" text="3"/>
                <label id="hour2Label" textAlign="center" width="50%" verticalAlign="center" horizontalAlign="center" text="6"/>
            </hbox>
            <hbox id="test2" width="100%" height="50%" horizontalAlign="center">
                <label id="min1Label" textAlign="center" width="50%" verticalAlign="center" horizontalAlign="center" text="3"/>
                <label id="min2Label" textAlign="center" width="50%" verticalAlign="center" horizontalAlign="center" text="6"/>
            </hbox>
        </vbox>
	</box>
')
class NowPlayingIdleClockComponent extends Box {
	private var updateTimer:Timer;

	public function new() {
		super();
		this.registerEvent(UIEvent.SHOWN, onComponentShown);
		this.registerEvent(UIEvent.HIDDEN, onComponentHidden);
	}

	private function onComponentShown(e) {
		this.unregisterEvent(UIEvent.SHOWN, onComponentShown);
		setFontStyle(hour1Label);
		setFontStyle(hour2Label);
		setFontStyle(min1Label);
		setFontStyle(min2Label);
		this.width = this.height * .6;

		// set initial values
		update();

		startUpdateInterval();
	}

	private function setFontStyle(label:Label) {
		RFIDTriggerAdminFonts.SET_FONT_CLOCK(label);
		label.color = RFIDTriggerAdminSettings.NOWPLAYING_TEXT_COLOUR;
	}

	function resizeTextToFit(label:Label) {
		var targetHeight:Float = label.parentComponent.height * .8;
		while (label.height < targetHeight) {
			label.invalidateComponentStyle();
			label.validateNow();
			label.fontSize += .2;
		}
	}

	private function onComponentHidden(e) {
		this.unregisterEvent(UIEvent.HIDDEN, onComponentHidden);
		stopUpdateInterval();
	}

	private function startUpdateInterval() {
		updateTimer = new Timer(1000);
		updateTimer.run = update;
	}

	private function stopUpdateInterval() {
		if (updateTimer != null) {
			updateTimer.stop();
			updateTimer = null;
		}
	}

	private function update() {
		updateTimeFields();
		updateTextSize();
	}

	private function updateTextSize() {
		resizeTextToFit(hour1Label);
		resizeTextToFit(hour2Label);
		resizeTextToFit(min1Label);
		resizeTextToFit(min2Label);
	}

	private function updateTimeFields() {
		var now = Date.now();

		// var day = StringTools.lpad(Std.string(now.getDate()), "0", 2);
		// var month = StringTools.lpad(Std.string(now.getMonth() + 1), "0", 2);
		// var year = Std.string(now.getFullYear());

		var hour = StringTools.lpad(Std.string(now.getHours()), "0", 2);
		var minute = StringTools.lpad(Std.string(now.getMinutes()), "0", 2);
		var second = StringTools.lpad(Std.string(now.getSeconds()), "0", 2);

		hour1Label.text = hour.substr(0, 1);
		hour2Label.text = hour.substr(1, 1);
		min1Label.text = minute.substr(0, 1);
		min2Label.text = minute.substr(1, 1);
	}
}
