package actionmanager.actions;

import settings.SettingsManager;
import settings.CardData;
import haxe.Constraints.Function;
import haxe.Timer;
import sys.io.Process;

class Action {
	@:isVar public var type(get, null):String;
	@:isVar public var onActionComplete(get, set):String->Void;

	public var cardId:String;
	public var command:String;

	public function new(cardId:String, command:String) {
		this.type = "BASE_ACTION";
		this.cardId = cardId;
		this.command = command;
	}

	private function triggerProcess(command:String, args:Array<String>, ?onCompleteFollowOn:Function = null) {
		ProcessWrapper.instance.start(command, args, function() {
			if (onCompleteFollowOn != null) {
				onFinished();
				onCompleteFollowOn();
			}
		});
	}

	public function start(?onCompleteFollowOn:Function = null) {
		setCardActiveState(cardId, true);
	}

	public function stop(?onStopped:Function = null) {
		setCardActiveState(cardId, false);
	}

	public function startWhileAlreadyRunning() {
		LOG("startWhileAlreadyRunning " + type);
		stop();
	}

	private function exampleTestProcess() {
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

	private function onFinished() {
		setCardActiveState(cardId, false);
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

	private function setCardCurrentState(cardId:String, current:Bool) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		card.current = current;
		SettingsManager.instance.updateCard(card);
	}

	private function setCardActiveState(cardId:String, active:Bool) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		card.active = active;
		SettingsManager.instance.updateCard(card);
	}
}
