package spilehx.rfidtriggeradmin.page.components;

import haxe.ui.components.Image;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
		<hbox id="content" width="100%" height="100%" horizontalAlign="center" verticalAlign="center">
			<vbox height="70%" width="100%" verticalAlign="center">
				<label text="Device ID" verticalAlign="center" />
				<label id="deviceIDValueLable" verticalAlign="center" />
			</vbox>
			
			<vbox height="70%" width="100%" verticalAlign="center">
				<label text="Last Updated" verticalAlign="center" />
				<label id="lastUpdatedValueLable" verticalAlign="center" />
			</vbox>

			<box height="100%" width="100%" verticalAlign="center">
				 <image id="nowPlayingImg" width="100%" height="100%" scaleMode="fitheight" verticalAlign="center"/>
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
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onUpdate);
	}

	private function onUpdate(settings:SettingsData) {
		deviceIDValueLable.text = settings.deviceID;
		lastUpdatedValueLable.text = getDateTimeString();
	




		
		nowPlayingImg.resource = js.Browser.document.location.href+"getimage";
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
