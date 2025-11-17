package spilehx.rfidtriggerserver.helpers;

import spilehx.imagedata.DefaultImg;
import haxe.io.Bytes;
import sys.FileSystem;
import spilehx.rfidtriggerserver.managers.SettingsManager;
import haxe.crypto.Base64;
import sys.io.File;

class ImageFileHelpers {
	public static function saveImage(base64Data:String, cardId:String) {
		var path:String = SettingsManager.instance.IMAGE_FOLDER_PATH + "/" + cardId + ".jpg";
		var bytes = Base64.decode(base64Data);
		File.saveBytes(path, bytes);
	}

	public static function getCardImage(cardId:String = "null"):Bytes {
		var path:String = SettingsManager.instance.IMAGE_FOLDER_PATH + "/" + cardId + ".jpg";
		var bytes:Bytes;
		if (FileSystem.exists(path) == false) {
			bytes = DefaultImg.getDefaultImage();
		} else {
			bytes = File.getBytes(path);
		}
		return bytes;
	}
}
