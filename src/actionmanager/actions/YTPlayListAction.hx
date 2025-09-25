package actionmanager.actions;

class YTPlayListAction extends Action {
	public function new() {
		super();
		this.type = "PLAY_YT_PLAYLIST";
	}

	override public function start(cardId:String, command:String) {
		super.start(cardId, command);
		// play(command);
		streamProc = ProcessHelper.playYTVideo(command, onProcessComplete);
		// trace("pl------>"+command);
	}

	override public function stop() {
		super.stop();
		if (streamProc != null) {
			LOG("stoppting process");
			ProcessHelper.closeProcess(streamProc);
		}
	}

	override public function startWhileAlreadyRunning() {
		super.startWhileAlreadyRunning();
		LOG("startWhileAlreadyRunning");
	}

	private function onProcessComplete() {
		LOG("PROCESS COMPLETE!!!!!!!!!!");
	}
}
