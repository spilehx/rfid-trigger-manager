package spilehx.rfidtriggeradmin.tools;

import haxe.ui.core.Component;
import haxe.ui.components.Image;
import js.html.Element;

class UiFilterEffects {
	public static function applyDropShadowToImage(target:Image) {
		applyDropShadowToElement(target.element.getElementsByTagName("img")[0]);
	}

	public static function applyDropShadow(target:Component, ?strong:Bool = false) {
		applyDropShadowToElement(target.element,strong);
	}


	private static function applyDropShadowToElement(el:Element, ?strong:Bool = false) {
		
		var dp1:String = "drop-shadow(4px 4px 2px rgba(0, 0, 0, 0.5))";

		var dp2:String = "drop-shadow(rgba(0, 0, 0, 0.5) 2px 2px 4px)"; // general
		var dp3:String = "drop-shadow(rgba(0, 0, 0, 0.5) 4px 4px 6px)"; // soft

		var filter:String;

		if (strong == true) {
			filter = dp2;
		} else {
			filter = dp3;
		}

		el.style.filter = filter;
	}

	public static function addDepth(target:Component, ?strong:Bool = false, ?fadeIn:Float = 2, ?shadowColour:Int = 0):Void {
		var el:Element = target.element;
		var colour:Int = RFIDTriggerAdminSettings.DEPTH_SHADOW_COLOUR;

		if (shadowColour != 0) {
			colour = shadowColour;
		}

		// Convert Int colour (0xRRGGBB) to CSS rgb() string
		var r = (colour >> 16) & 0xFF;
		var g = (colour >> 8) & 0xFF;
		var b = colour & 0xFF;

		var layers = strong ? [
			'2px 2px 2px rgba(' + r + ',' + g + ',' + b + ',0.35)',
			'4px 4px 4px rgba(' + r + ',' + g + ',' + b + ',0.25)',
			'8px 8px 8px rgba(' + r + ',' + g + ',' + b + ',0.20)',
			'10px 10px 10px rgba(' + r + ',' + g + ',' + b + ',0.15)'
		] : [
			'2px 2px 2px rgba(' + r + ',' + g + ',' + b + ',0.25)',
			'4px 4px 4px rgba(' + r + ',' + g + ',' + b + ',0.15)'
			];

		var boxShadowValue = layers.join(", ");

		if (fadeIn > 0) {
			el.style.transition = "box-shadow 0.3s ease-in-out";
			// Start invisible then trigger repaint
			el.style.boxShadow = "none";
			js.Browser.window.setTimeout(function() {
				el.style.boxShadow = boxShadowValue;
			}, fadeIn);
		} else {
			// Apply only box-shadow for depth
			el.style.boxShadow = boxShadowValue;
			el.style.transition = "";
		}
	}

	public static function removeDepth(target:Component) {
		var el:Element = target.element;
		el.style.boxShadow = "none";
	}
}
