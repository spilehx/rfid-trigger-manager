package spilehx.rfidtriggerserver;

import spilehx.rfidtriggerserver.managers.AdminManager;
import spilehx.rfidtriggerserver.managers.SettingsManager;

class RFIDTriggerServerController {
    public function new() {
        
    }

    public function init() {
        initManagers();
    }

    private function initManagers() {
        SettingsManager.instance.init();
        AdminManager.instance.init();
    }
}