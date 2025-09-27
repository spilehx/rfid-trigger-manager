package adminmanager;

import settings.SettingsData;
import adminmanager.http.RestDataObject;


class ConfigRouteData extends RestDataObject {
	public var config:SettingsData;
	public var logs:String;

	public function new() {
		super();
	}
}
