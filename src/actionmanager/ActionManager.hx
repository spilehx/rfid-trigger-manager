package actionmanager;

import settings.SettingsData;
import settings.CardData;
import haxe.Timer;
import haxe.Constraints.Function;
import sys.io.Process;
import settings.SettingsManager;

class ActionManager {
	private var currentCardId:String;
	private var streamProc:Process;

	public static final instance:ActionManager = new ActionManager();

	private function new() {}

	public function init() {}

	public function doAction(cardId:String) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		if (card.enabled != true) {
			USER_MESSAGE("Card not enabled: " + card.id);
			return;
		}

		if (card != null) {
			// kill current
			stopCurrentActions();
			USER_MESSAGE("triggering card " + card.id);
			Sys.sleep(.5);

			if (currentCardId != card.id) {
				currentCardId = card.id;
				// LOG("Card Id " + card.id);
				// LOG("type " + card.type);
				// LOG("Action " + card.action);
				card.current = true;
				card.active = true;

				SettingsManager.instance.updateCard(card);
				// SettingsManager.instance.saveSettingsData();

				if (card.action.length == 0) {
					USER_MESSAGE("No action for card: " + card.id);
					return;
				}

				if (card.type == SettingsData.ACTION_STREAM) {
					playAudioStream(card.action);
				} else if (card.type == SettingsData.ACTION_YTPL) {
					playYTPlaylist(card.action);
				}
			} else {
				currentCardId = "";
			}
		}
	}

	private function stopCurrentActions() {
		for (card in SettingsManager.instance.settings.cards) {
			card.active = false;
		}

		LOG("Stopping stream");
		if (streamProc != null) {
			streamProc = null;
			killByName("mpv");
		}
	}

	private function killByPid(pid:Int) {
		var killProc:Process = new sys.io.Process("pkill " + pid);
		LOG("ERRR " + killProc.stderr.readAll().toString());
		LOG("out " + killProc.stdout.readAll().toString());
	}

	private function killByName(name:String) {
		var killProc:Process = new sys.io.Process("pkill " + name);
	}

	private function playAudioStream(url:String) {
		var action:String = "mpv " + url;
		streamProc = new sys.io.Process(action, null, true);
	}

	private function playYTPlaylist(plId:String) {
		var pl:String = "https://www.youtube.com/playlist?list=" + plId;

		var action:String = "mpv --no-video " + pl;
		streamProc = new sys.io.Process(action, null, true);
	}

	private function delay(t:Int, followOn:Function) {
		var timer:Timer = new Timer(t);
		timer.run = function() {
			timer.stop();
			timer = null;
			followOn();
		}
	}
}
