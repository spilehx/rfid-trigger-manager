package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class YTPVideoAction extends Action {
	override public function start() {
		super.start();
		var url:String = "https://www.youtube.com/watch?v=" + command;
		trace("url " + url);
		triggerProcess("mpv", ["--no-video", url]);
	}

	// override public function stop(?onStopped:Function = null) {
	// 	super.stop(onStopped);
	// 	ProcessWrapper.instance.stop();
	// }
}
