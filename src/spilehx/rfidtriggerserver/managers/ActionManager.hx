package spilehx.rfidtriggerserver.managers;

import spilehx.rfidtriggerserver.managers.actionmanager.actions.StopAllAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.SpotifyPlaylistAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.PlayFileAction;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.RadioAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.YTPVideoAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.YTPlayListAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.ToneAction;
import spilehx.rfidtriggerserver.managers.actionmanager.actions.Action;
import haxe.Timer;
import haxe.Constraints.Function;
import sys.io.Process;
import spilehx.rfidtriggerserver.managers.SettingsManager;

class ActionManager extends spilehx.core.ManagerCore {
	private var actionClasses:Array<Class<Action>>;
	private var currentAction:Action;
	private var currentCardId:String;

	// private var streamProc:Process;
	@:isVar public var avaliableActionTypes(get, null):Array<String>;

	public static final instance:ActionManager = new ActionManager();

	public function init() {
		actionClasses = [YTPlayListAction, YTPVideoAction, RadioAction, PlayFileAction, ToneAction, SpotifyPlaylistAction, StopAllAction];
		registerActions();
	}

	private function registerActions() {
		avaliableActionTypes = new Array<String>();
		for (actionClass in actionClasses) {
			var action = Type.createInstance(actionClass, []);
			avaliableActionTypes.push(action.type);
		}
	}
	public function doAction(cardId:String) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		if (card.enabled != true) {
			USER_MESSAGE("Card not enabled: " + card.id);
			return;
		}

		var triggeredAction = getActionInstanceFromType(card.action, cardId, card.command);

		if (currentAction == null) {
			startAction(triggeredAction);
		} else {
			if (currentAction.cardId != triggeredAction.cardId) {
				// new card action requested
				if (currentAction != null) {
					// currently playing another action
					stopCurrentAction();
					startAction(triggeredAction);
				} else {
					startAction(triggeredAction);
				}
			} else {
				startWhileAlreadyRunning();
			}
		}
	}

	private function startAction(triggeredAction:Action) {
		currentAction = triggeredAction;
		currentAction.onActionComplete = onActionComplete;
		currentAction.start();
		
	}

	private function stopCurrentAction() {
		if (currentAction != null) {
			currentAction.stop();
		}
	}

	private function startWhileAlreadyRunning() {
		if (currentAction != null) {
			currentAction.startWhileAlreadyRunning();
		}
	}

	private function onActionComplete(cardId:String) {
		USER_MESSAGE("Action complete: " + cardId);
		currentAction = null;
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
