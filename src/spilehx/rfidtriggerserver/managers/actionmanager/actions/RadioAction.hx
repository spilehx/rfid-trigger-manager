package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class RadioAction extends Action {
	public function new(cardId:String, command:String) {
		super(cardId, command);
		this.type = "PLAY_RADIO";
	}

	// override private function setRequiredEnv() {
	// 	Sys.putEnv("PATH", "/usr/local/bin:" + Sys.getEnv("PATH"));
	// 	Sys.putEnv("XDG_RUNTIME_DIR", "/run/user/1000");
	// 	Sys.putEnv("PULSE_SERVER", "unix:/run/user/1000/pulse/native");
	// }

	override public function start(?onCompleteFollowOn:Function = null) {
		super.start();
		var url:String = command;
		triggerProcess("mpv", [url], onCompleteFollowOn);
	}

	override public function stop(?onStopped:Function = null) {
		super.stop(onStopped);
		ProcessWrapper.instance.stop();
	}
}
