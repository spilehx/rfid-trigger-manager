package actionmanager.actions;

import haxe.Constraints.Function;

class TestAction extends Action {
	public function new(cardId:String, command:String) {
		super(cardId, command);
		this.type = "TestAction";
	}

	override public function start(?onCompleteFollowOn:Function = null) {
		super.start();
		var url:String = "https://www.youtube.com/watch?v=" + command;
		triggerProcess("mpv", ["--no-video", url], onCompleteFollowOn);
	}

	override public function stop(?onStopped:Function = null) {
		super.stop(onStopped);
		ProcessWrapper.instance.stop();
	}
}
