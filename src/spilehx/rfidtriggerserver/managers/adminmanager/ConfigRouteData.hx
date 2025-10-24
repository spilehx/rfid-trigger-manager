package spilehx.rfidtriggerserver.managers.adminmanager;

import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import spilehx.rfidtriggerserver.managers.adminmanager.http.RestDataObject;




class ConfigRouteData extends RestDataObject {
	public var config:SettingsData;
	public var logs:String;

	public function new() {
		super();
	}
}
