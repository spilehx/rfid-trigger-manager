package spilehx.rfidtriggerserver.managers;





import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.RadioAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.YTPVideoAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.YTPlayListAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.TestAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.Action;

import haxe.Timer;
import haxe.Constraints.Function;
import sys.io.Process;
import spilehx.rfidtriggerserver.managers.SettingsManager;

class ActionManager extends spilehx.core.ManagerCore{
	private var actionClasses:Array<Class<Action>>;
	private var currentAction:Action;
	private var currentCardId:String;

	// private var streamProc:Process;
	@:isVar public var avaliableActionTypes(get, null):Array<String>;

	public static final instance:ActionManager = new ActionManager();

	// private function new() {
		
	// }

	public function init() {
		actionClasses = [YTPlayListAction, YTPVideoAction, RadioAction];
		registerActions();
	}

	private function registerActions() {
		avaliableActionTypes = new Array<String>();
		for (actionClass in actionClasses) {
			var action = Type.createInstance(actionClass, []);
			avaliableActionTypes.push(action.type);
		}
	}

	private var triggeredAction:Dynamic;

	public function doAction(cardId:String) {
		USER_MESSAGE("Starting action for card: " + cardId);

		var card:CardData = SettingsManager.instance.getCard(cardId);
		if (card.enabled != true) {
			USER_MESSAGE("Card not enabled: " + card.id);
			return;
		}

		triggeredAction = getActionInstanceFromType(card.action, cardId, card.command);

		if (currentAction == null) {
			startAction();
		} else {
			if (currentAction.cardId != triggeredAction.cardId) {
				LOG_INFO("Starting action for card: " + cardId);
				currentAction.stop(function() {
					trace("Stopped");
				});
			} else {
				// triggeredAction = null;
				LOG_INFO("RETRIGGER action for card: " + cardId);
				currentAction.startWhileAlreadyRunning();
			}
		}
	}

	private function startAction() {
		currentAction = triggeredAction;
		triggeredAction = null;
		currentAction.start(onActionComplete);
	}

	private function onActionComplete() {
		USER_MESSAGE("Action complete: ");
		currentAction = null;

		// start next if there
		if (triggeredAction != null) {
			startAction();
		} else {
			USER_MESSAGE("System idle, awaiting next card");
		}
	}

	private function getActionInstanceFromType(actionType:String, cardId:String, command:String):Dynamic {
		for (actionClass in actionClasses) {
			var action = Type.createInstance(actionClass, [cardId, command]);
			if (actionType == action.type) {
				return action;
			}
		}

		return null;
	}

	function get_avaliableActionTypes():Array<String> {
		return avaliableActionTypes;
	}
}
