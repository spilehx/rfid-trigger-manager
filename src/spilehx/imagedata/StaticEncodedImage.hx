package spilehx.imagedata;

import haxe.io.Bytes;
import haxe.crypto.Base64;

class StaticEncodedImage {

	public static function getBytes(data:String = ""):Bytes {
		var base64Img:String = data;
		var bytes = Base64.decode(base64Img);
		return bytes;
	}
#if (js)
	public static function getImageComponent(data:String = ""):haxe.ui.components.Image {
		var img = new haxe.ui.components.Image();
		img.resource = data;
        return img;
	}
#end
}