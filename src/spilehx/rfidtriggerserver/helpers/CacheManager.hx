package spilehx.rfidtriggerserver.helpers;

import spilehx.rfidtriggerserver.managers.SettingsManager;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import sys.FileSystem;
import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers.YTActionCommandHelpers;
import sys.io.Process;

class CacheManager extends spilehx.core.ManagerCore {
	private static final FILE_CACHE_PATH:String = "./filecache";

	public static final instance:CacheManager = new CacheManager();

	private var YT_FILE_CACHE_PATH:String = FILE_CACHE_PATH + "/yt";
	private var ytIdsToCache:Array<YTCacheQueueItem> = new Array<YTCacheQueueItem>();

	private var ytCacheInProgress:Bool = false;

	public function init() {
		ensureCacheFolders();
	}

	private function ensureCacheFolders() {
		FileSystemHelpers.ensurePath(FILE_CACHE_PATH);
		FileSystemHelpers.ensurePath(YT_FILE_CACHE_PATH);
	}

	public function cacheYouTubePlaylistToAudio(cardId:String, hardRefresh:Bool = false) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		var playlistId:String = card.command;
		if (hardRefresh == true) {
			card.playList = [];
			SettingsManager.instance.updateCard(card);
			deleteCache(playlistId);
		}

		YTActionCommandHelpers.getYTPlayListTracks(playlistId, function(playlist:Array<String>) {
			card.playList = playlist;
			SettingsManager.instance.updateCard(card);

			if (playlist.length > 0) {
				for (videoId in playlist) {
					ytIdsToCache.push(new YTCacheQueueItem(videoId, playlistId));
				}
				startYTIdCacheing();
			}
		});
	}

	private function deleteCache(playlistId:String) {
		var plDir:String = YT_FILE_CACHE_PATH + "/" + playlistId;
		if (FileSystem.exists(plDir) == true) {
			deleteDirectoryRecursive(plDir);
		}
	}

	private function deleteDirectoryRecursive(path:String):Void {
		if (!FileSystem.exists(path))
			return;

		if (!FileSystem.isDirectory(path)) {
			FileSystem.deleteFile(path);
			return;
		}

		for (file in FileSystem.readDirectory(path)) {
			var fullPath = path + "/" + file;
			if (FileSystem.isDirectory(fullPath)) {
				deleteDirectoryRecursive(fullPath);
			} else {
				FileSystem.deleteFile(fullPath);
			}
		}

		FileSystem.deleteDirectory(path);
	}

	private function startYTIdCacheing() {
		if (ytCacheInProgress == false) {
			ytCacheInProgress = true;
			processYTIdCacheList();
		} else {
			LOG_WARN("ytCacheInProgress already in progress");
		}
	}

	private function processYTIdCacheList() {
		if (ytIdsToCache.length > 0) {
			var itemToCache:YTCacheQueueItem = ytIdsToCache.shift();

			if (isYTCached(itemToCache.playlistId, itemToCache.videoId) == true) {
				USER_MESSAGE("Item cached: " + itemToCache.playlistId + " - " + itemToCache.videoId);
				// loop round again to check next item
				processYTIdCacheList();
			} else {
				USER_MESSAGE_WARN("Not cached: " + itemToCache.playlistId + " - " + itemToCache.videoId);
				cacheYTVideo(itemToCache, function() {
					USER_MESSAGE("Track cache completed : " + itemToCache.playlistId + "/" + itemToCache.videoId);
					// loop round again to check next item
					processYTIdCacheList();
				});
			}
		} else {
			onYTPlaylistCacheComplete();
		}
	}

	private function cacheYTVideo(itemToCache:YTCacheQueueItem, onComplete:Void->Void) {
		USER_MESSAGE("Downloading: " + itemToCache.playlistId + " - " + itemToCache.videoId);

		var videoId:String = itemToCache.videoId;
		var outputDir:String = YT_FILE_CACHE_PATH + "/" + itemToCache.playlistId;
		FileSystemHelpers.ensurePath(outputDir);

		var url = 'https://www.youtube.com/watch?v=$videoId';
		var outputPath = '$outputDir/$videoId.%(ext)s';

		var args = ["-x", "--audio-format", "mp3", "--audio-quality", "0", "-o", outputPath, url];
		var p = new Process("yt-dlp", args);

		sys.thread.Thread.create(() -> {
			var code = p.exitCode();
			p.close();
			if (code != 0) {
				USER_MESSAGE_WARN("yt-dlp exited with code - video unavailable? - id:" + videoId);
			}
			onComplete();
		});
	}

	private function onYTPlaylistCacheComplete() {
		USER_MESSAGE("Cach complete");
		ytCacheInProgress = false;
	}

	public function isYTCached(playlistId:String, videoId:String):Bool {
		var filePath:String = YT_FILE_CACHE_PATH + "/" + playlistId + "/" + videoId + ".mp3";
		return FileSystem.exists(filePath);
	}

	public function getCachedFilePath(playlistId:String, videoId:String):String {
		var filePath:String = YT_FILE_CACHE_PATH + "/" + playlistId + "/" + videoId + ".mp3";
		return filePath;
	}
}

class YTCacheQueueItem {
	@:isVar public var videoId(default, null):String;
	@:isVar public var playlistId(default, null):String;

	public function new(videoId:String, playlistId:String) {
		this.videoId = videoId;
		this.playlistId = playlistId;
	}
}
