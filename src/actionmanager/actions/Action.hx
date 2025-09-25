package actionmanager.actions;

import actionmanager.ProcessHelper.ProcessHandle;
import haxe.Timer;
import sys.io.Process;

class Action {
	@:isVar public var type(get, null):String;
	@:isVar public var onActionComplete(get, set):String->Void;

	private var cardId:String;
	private var command:String;
	private var streamProc:ProcessHandle;

	public function new() {
		this.type = "BASE_ACTION";
	}

	public function start(cardId:String, command:String) {
		this.cardId = cardId;
		this.command = command;

		// exampleTestProcess();
	}

	public function stop() {
		trace("Stopping " + type);
	}

	public function startWhileAlreadyRunning() {
		trace("startWhileAlreadyRunning " + type);
		// // exampleTestProcess();
	}

	private function exampleTestProcess() {
		trace("start exampleTestProcess " + type);
		var t:Timer = new Timer(7000);
		t.run = function() {
			t.stop();
			actionComplete();
		}
	}

	private function actionComplete() {
		if (onActionComplete != null) {
			onActionComplete(cardId);
		}
	}

	function get_type():String {
		return type;
	}

	function get_onActionComplete():String->Void {
		return onActionComplete;
	}

	function set_onActionComplete(onActionComplete):String->Void {
		return this.onActionComplete = onActionComplete;
	}


}
