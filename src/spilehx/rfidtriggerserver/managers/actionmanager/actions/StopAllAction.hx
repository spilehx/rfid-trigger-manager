package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;

class StopAllAction extends Action {
	override public function start() {
		super.start();
		stopMpc();
		Sys.sleep(.5);
		onFinished();
	}

	private function stopMpc() {
		if (ActionCommandHelpers.isProcessRunning("mpc") == true) {
			triggerProcess("mpc", ["stop", "-q"]);
		}
	}
}
