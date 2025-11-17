package spilehx.rfidtriggeradmin.page.sections;

import haxe.ui.components.Label;
import haxe.ui.containers.ScrollView;
import haxe.ui.events.UIEvent;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
		<scrollview id="logsScrollView" height="98%" width="98%" contentWidth="100%" horizontalAlign="center"/>
	</box>
')
class LogsSection extends Box {
	private static final LOG_LINES_VISIBLE:Int = 10;

	private var logLines:Array<String>;

	public function new() {
		super();
		logLines = [];
		this.registerEvent(UIEvent.SHOWN, onShown);
	}

	private function onShown(e) {
		setup();
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onUpdate);
	}

	private function setup() {
		logsScrollView.backgroundColor = 0x000000;
		logsScrollView.contents.backgroundColor = logsScrollView.backgroundColor;
	}

	private function onResize(e) {
		// LOG("ON onResize     ---");
	}

	private function onUpdate(settings:SettingsData) {
		logsScrollView.removeAllComponents();
		var lines:Array<Box> = getLogsLines(settings);
		for (line in lines) {
			logsScrollView.addComponent(line);
		}
		logsScrollView.vscrollPos = logsScrollView.vscrollMax;
	}

	private function getLogsLines(settings:SettingsData):Array<Box> {
		var textLines:Array<String> = settings.logs.split("\n");
		var lines:Array<Box> = new Array<Box>();

		for (textLine in textLines) {
			lines.push(getLogsLineComponent(textLine));
		}

		return lines;
	}

	private function getLogsLineComponent(text:String):Box {
		var lineBox:Box = new Box();
		lineBox.percentWidth = 100;
		lineBox.height = logsScrollView.height / LOG_LINES_VISIBLE;
		var l:Label = new Label();
		l.percentWidth = 100;
		l.percentHeight = 95;
		l.verticalAlign = "center";
		l.text = text;
		l.color = RFIDTriggerAdminSettings.LOGS_TEXT_COLOUR;
		lineBox.addComponent(l);

		return lineBox;
	}
}
