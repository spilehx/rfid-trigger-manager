package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class YTPVideoAction extends Action {
	override public function start() {
		super.start();
		var url:String = "https://www.youtube.com/watch?v=" + command;
		triggerProcess("mpv", ["--no-video", url]);
	}
}
