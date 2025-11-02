package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.helpers.CacheManager;
import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers.YTActionCommandHelpers;
import haxe.Constraints.Function;

class YTPlayListAction extends Action {
	private var playList:Array<String>;
	private var currentTrack:Int = 0;
	private var forceStop:Bool = false;
	private var playlistId:String;

	override public function start() {
		super.start();

		playlistId = command;

		var card:CardData = SettingsManager.instance.getCard(cardId);

		if (card.playList != null) {
			USER_MESSAGE("Playing from cached playlist ");
			playList = card.playList;
			playTrack(0);
		} else {
			USER_MESSAGE("Refreshing playlist");

			YTActionCommandHelpers.getYTPlayListTracks(playlistId, function(foundPlaylist:Array<String>) {
				if (foundPlaylist.length > 0) {
					card.playList = playList = foundPlaylist;
					SettingsManager.instance.updateCard(card);
					playTrack(0);
				} else {
					USER_MESSAGE("Bad playlist, no tracks found");
					onFinished();
				}
			});
		}
	}

	override public function startWhileAlreadyRunning() {
		playNextTrack();
	}

	private function playTrack(index:Int) {
		if (CacheManager.instance.isYTCached(playlistId, playList[currentTrack]) == true) {
			playFromLocalFile(index);
		} else {
			playTrackFromYT(index);
		}
	}

	private function playFromLocalFile(index:Int) {
		USER_MESSAGE("Playing track from cache: " + index);
		var cachedFilePath:String = CacheManager.instance.getCachedFilePath(playlistId, playList[currentTrack]);
		triggerProcess("mpv", [cachedFilePath], onProcessDone);
	}

	private function playTrackFromYT(index:Int) {
		USER_MESSAGE("Playing track from YT: " + index);
		currentTrack = index;
		var url:String = "https://www.youtube.com/watch?v=" + playList[currentTrack];
		triggerProcess("mpv", ["--no-video", url], onProcessDone);
	}

	private function onProcessDone() {
		if (forceStop == true) {
			onFinished();
		} else {
			onTrackFinished();
		}
	}

	private function onTrackFinished() {
		playNextTrack();
	}

	override public function stop() {
		forceStop = true;
		super.stop();
	}

	private function playNextTrack() {
		USER_MESSAGE("Playing next track : " + this.type + " " + command);
		ProcessWrapper.instance.stop(function() {
			if (currentTrack < playList.length) {
				currentTrack += 1;
				playTrack(currentTrack);
			} else {
				onFinished();
			}
		}, true);
	}
}
