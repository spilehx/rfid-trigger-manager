package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class TestAction extends Action {
	// public function new(cardId:String, command:String) {
	// 	super(cardId, command);
	// 	// this.type = "TestAction";
	// }
	override public function start() {
		super.start();
		// var url:String = "https://www.youtube.com/watch?v=" + command;
		// // yt-dlp -x --audio-format mp3

		// triggerProcess("yt-dlp", ["-x", "--audio-format", "mp3", url], onCompleteFollowOn);

		// triggerProcess("mpv", ["--no-video", url], onCompleteFollowOn);
	}

	// override public function stop(?onStopped:Function = null) {
	// 	super.stop(onStopped);
	// 	ProcessWrapper.instance.stop();
	// }
}
