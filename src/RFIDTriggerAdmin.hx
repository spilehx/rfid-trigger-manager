package;

import spilehx.rfidtriggeradmin.RFIDTriggerAdminConfigManager;
import spilehx.rfidtriggeradmin.RFIDTriggerAdminView;

class RFIDTriggerAdmin {
	static function main() {
		RFIDTriggerAdminView.instance.init();
		RFIDTriggerAdminConfigManager.instance.init();
	}
}
