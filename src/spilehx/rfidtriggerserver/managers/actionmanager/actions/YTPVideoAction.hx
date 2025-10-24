package spilehx.rfidtriggerserver.managers.actionmanager.actions;


import haxe.Constraints.Function;

class YTPVideoAction extends Action {
	public function new(cardId:String, command:String) {
		super(cardId, command);
		this.type = "PLAY_YT_VIDEO";
	}

	override public function start(?onCompleteFollowOn:Function = null) {
		super.start();
		var url:String = "https://www.youtube.com/watch?v=" + command;
		trace("url "+url);
		triggerProcess("mpv", ["--no-video", url], onCompleteFollowOn);
	}

	override public function stop(?onStopped:Function = null) {
		super.stop(onStopped);
		ProcessWrapper.instance.stop();
	}
}
