package spilehx.rfidtriggeradmin.page.components.nowplaying;

import haxe.ui.events.UIEvent;
import haxe.ui.constants.ScaleMode;
import haxe.crypto.Base64;
import js.html.XMLHttpRequestResponseType;
import haxe.ui.containers.Box;
import js.html.XMLHttpRequest;
import js.lib.ArrayBuffer;
import haxe.io.Bytes;

@:xml('
   	<box width="100%" height="100%" >
		<image id="nowPlayingImg"  height="100%" verticalAlign="center"/>
	</box>
')
class NowPlayingImageComponent extends Box {
	private var imgBytes:Bytes;

	public function new() {
		super();
		setup();
	}

	private function setup() {}

	public function update() {
		updateImage();
	}

	private function updateImage() {
		getImageBytes(setImage);
	}

	private function setImage(newImgBytes:Bytes) {
		if (newImgBytes != null) {
			if (imgBytes == null || newImgBytes.length != imgBytes.length) {
				imgBytes = newImgBytes;
				var url = bytesToDataUrl(imgBytes, "image/jpeg");

				nowPlayingImg.resource = url;
				nowPlayingImg.scaleMode = ScaleMode.FIT_WIDTH;
				nowPlayingImg.registerEvent(UIEvent.CHANGE, function(e) {
					nowPlayingImg.width = nowPlayingImg.height; // make square
				});
			}
		}
	}

	private function getImageBytes(cb:Bytes->Void):Void {
		var req = new XMLHttpRequest();
		req.open("GET", "/getimage", true);
		req.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;

		req.onload = function(_) {
			var buffer:ArrayBuffer = cast req.response;
			var bytes = Bytes.ofData(cast buffer);
			cb(bytes);
		}

		req.onerror = function(_) {
			cb(null);
		}

		req.send();
	}

	public static function bytesToDataUrl(bytes:Bytes, mime:String = "image/png"):String {
		var b64 = Base64.encode(bytes);
		return 'data:$mime;base64,$b64';
	}
}
