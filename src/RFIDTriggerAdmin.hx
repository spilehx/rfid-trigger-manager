package;

import spilehx.rfidtriggeradmin.RFIDTriggerAdminConfigManager;
import spilehx.rfidtriggeradmin.RFIDTriggerAdminView;

class RFIDTriggerAdmin {
	static function main() {
		var view:RFIDTriggerAdminView = new RFIDTriggerAdminView();
		RFIDTriggerAdminConfigManager.instance.init();
	}
}
