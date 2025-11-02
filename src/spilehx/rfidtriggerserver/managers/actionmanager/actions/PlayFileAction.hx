package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class PlayFileAction extends Action {
	// public function new(cardId:String, command:String) {
	// 	super(cardId, command);
	// 	// this.type = "TestAction";
	// }

	override public function start() {
		super.start();
		triggerProcess("mplayer", ["-novideo", command]);
	}

	// override public function stop(?onStopped:Function = null) {
	// 	super.stop(onStopped);
	// 	ProcessWrapper.instance.stop();
	// }
}
