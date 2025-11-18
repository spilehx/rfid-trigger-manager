package spilehx.rfidtriggeradmin.page.sections;

import spilehx.config.RFIDTriggerAdminSettings;
import haxe.ui.events.UIEvent;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
		<hbox id="content" width="100%" height="100%" horizontalAlign="center" verticalAlign="center">
			<vbox height="70%" width="100%" verticalAlign="center">
				<label id="deviceIDLable" text="Device ID" verticalAlign="center" />
				<box id="deviceIDValueDropdownBox" width="100%" horizontalAlign="left">
					<dropdown id="deviceIDValueDropdown" horizontalAlign="left" verticalAlign="center" height="95%" width="100%" text="device"/>
				</box>
			</vbox>
			
			<vbox height="70%" width="100%" verticalAlign="center">
				<label id="lastUpdatedLable" text="Last Updated" verticalAlign="center" />
				<label id="lastUpdatedValueLable" verticalAlign="center" />
			</vbox>

			<box id="nowPlayingContainer" height="100%" width="100%" verticalAlign="center">
				 <NowPlayingComponent id="nowPlayingComponent" width="100%" height="100%" verticalAlign="center" horizontalAlign="center"/>
			</box>
		</hbox>
	</box>
')
class OverViewSection extends Box {
	public function new() {
		super();
		setup();
	}

	private function setup() {
		RFIDTriggerAdminSettings.SET_FONT_S(deviceIDLable, true);
		RFIDTriggerAdminSettings.SET_FONT_S(lastUpdatedLable, true);
		RFIDTriggerAdminSettings.SET_FONT_S(lastUpdatedValueLable, false);

		this.registerEvent(UIEvent.SHOWN, onShown);

		deviceIDValueDropdown.registerEvent(UIEvent.CHANGE, function(e) {
			deviceIDValueDropdownChanges();
		});
	}

	private function deviceIDValueDropdownChanges() {
		LOG("VAL  " + deviceIDValueDropdown.text);
		var value:String = deviceIDValueDropdown.text;

		var currentVal:String = RFIDTriggerAdminConfigManager.instance.settings.deviceID;
		if (currentVal != value) {
			RFIDTriggerAdminConfigManager.instance.updateDevice(value, function(e) {
				LOG("UPDATED");
			});
		}
	}

	private function onShown(e) {
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onUpdate);
	}

	private function setupSetDevice(settings:SettingsData) {
		deviceIDValueDropdown.text = Std.string(settings.deviceID);
		var options:Array<Dynamic> = new Array<Dynamic>();
		for (device in settings.avalibleDevices) {
			options.push({
				text: device
			});
		}

		deviceIDValueDropdown.dataSource.data = options;
		// deviceIDValueDropdown
		// deviceIDEditButton.borderRadius = 5;
		// deviceIDEditButton.backgroundColor = RFIDTriggerAdminSettings.SECTION_FIELD_BG_COLOUR;
		// deviceIDEditButton.registerEvent(MouseEvent.CLICK, onEditDeviceButtonClick);
	}

	private function onUpdate(settings:SettingsData) {
		setupSetDevice(settings);
		lastUpdatedValueLable.text = getDateTimeString();
		nowPlayingComponent.update();
	}

	private function getDateTimeString():String {
		var now = Date.now();

		var day = StringTools.lpad(Std.string(now.getDate()), "0", 2);
		var month = StringTools.lpad(Std.string(now.getMonth() + 1), "0", 2);
		var year = Std.string(now.getFullYear());

		var hour = StringTools.lpad(Std.string(now.getHours()), "0", 2);
		var minute = StringTools.lpad(Std.string(now.getMinutes()), "0", 2);
		var second = StringTools.lpad(Std.string(now.getSeconds()), "0", 2);

		return '${day}/${month}/${year}, ${hour}:${minute}:${second}';
	}
}
