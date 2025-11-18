package spilehx.config;

import haxe.ui.components.Label;

class RFIDTriggerAdminFonts {
    public static function SET_FONT_L(field:Label, bold:Bool = false) {
		var fontSize:Float = 2.8;
		setFont(field, fontSize, bold);
	}

	public static function SET_FONT_M(field:Label, bold:Bool = false) {
		var fontSize:Float = 2;
		setFont(field, fontSize, bold);
	}

	public static function SET_FONT_S(field:Label, bold:Bool = false) {
		var fontSize:Float = 1.5;
		setFont(field, fontSize, bold);
	}
	public static function SET_FONT_XS(field:Label, bold:Bool = false) {
		var fontSize:Float = 1.3;
		setFont(field, fontSize, bold);
	}

	private static function setFont(field:Label, fontSize:Float, bold:Bool = false) {
		var styleString:String = " font-size: " + fontSize + "vh;";
		if (bold == true) {
			styleString += " font-weight: bold;";
		}
		field.styleString = styleString;
	}
}