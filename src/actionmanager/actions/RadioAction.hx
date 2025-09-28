package actionmanager.actions;

import haxe.Constraints.Function;

class RadioAction extends Action {
	public function new(cardId:String, command:String) {
		super(cardId, command);
		this.type = "PLAY_RADIO";
	}

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
