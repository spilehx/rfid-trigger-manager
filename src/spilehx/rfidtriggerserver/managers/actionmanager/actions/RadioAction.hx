package spilehx.rfidtriggerserver.managers.actionmanager.actions;



class RadioAction extends Action {

	override public function start() {
		super.start();
		var url:String = command;
		triggerProcess("mpv", [url]);
	}

	// override public function stop(?onStopped:Function = null) {
	// 	super.stop(onStopped);
	// 	ProcessWrapper.instance.stop();
	// }
}
