package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class YTPlayListAction extends Action {
	private var playList:Array<String>;
	private var currentTrack:Int = 0;

	// public function new(cardId:String, command:String) {
	// 	super(cardId, command);
	// 	// this.type = "PLAY_YT_PLAYLIST";
	// }

	override public function start() {
		super.start();
		triggerProcessForResponse("yt-dlp", ["--flat-playlist", "--get-id", command], function(resp:Dynamic) {
			playList = Std.string(resp).split("\n");
			//  trace("pl "+playList[0]);
			playTrack(0);
		});

		// var url:String = "https://www.youtube.com/playlist?list=" + command;
		// triggerProcess("mpv", ["--no-video", url], onCompleteFollowOn);
	}

	override public function startWhileAlreadyRunning() {
		LOG("startWhileAlreadyRunning " + type);
		playNextTrack();
	}

	private function playTrack(index:Int) {
		USER_MESSAGE("Playing track: " + index);
		currentTrack = index;
		var url:String = "https://www.youtube.com/watch?v=" + playList[currentTrack];
		// triggerProcess("mpv", ["--no-video", url], onTrackFinished);
	}

	private function onTrackFinished() {
		// LOG("onTrackFinished");
		playNextTrack();
	}

	private function playNextTrack() {
		ProcessWrapper.instance.stop(function() {
			if (currentTrack < playList.length) {
				currentTrack += 1;
				
				playTrack(currentTrack);
			} else {
				ProcessWrapper.instance.stop(null, false);
			}
		}, true);
	}

	// override public function stop(?onStopped:Function = null) {
	// 	super.stop(onStopped);
	// 	ProcessWrapper.instance.stop();
	// }
}
