package spilehx.config;

import haxe.ui.core.Component;

class RFIDTriggerAdminFonts {
	private static final SITE_FONT_PRIMARY:String = "AvenirRegular";
	private static final SITE_FONT_SECONDARY:String = "Antonio-VariableFont_wght";

	public static function SET_FONT_XL(field:Component, bold:Bool = false, primary:Bool = true) {
		var fontSize:Float = 3.2;
		setFont(field, fontSize, bold, primary);
	}

	public static function SET_FONT_L(field:Component, bold:Bool = false, primary:Bool = true) {
		var fontSize:Float = 2.8;
		setFont(field, fontSize, bold, primary);
	}

	public static function SET_FONT_M(field:Component, bold:Bool = false, primary:Bool = true) {
		var fontSize:Float = 2;
		setFont(field, fontSize, bold, primary);
	}

	public static function SET_FONT_S(field:Component, bold:Bool = false, primary:Bool = true) {
		var fontSize:Float = 1.5;
		setFont(field, fontSize, bold, primary);
	}

	public static function SET_FONT_XS(field:Component, bold:Bool = false, primary:Bool = true) {
		var fontSize:Float = 1.3;
		setFont(field, fontSize, bold, primary);
	}

	private static function setFont(field:Component, fontSize:Float, bold:Bool = false, primary:Bool = true) {
		var fontNameString:String = SITE_FONT_PRIMARY;
		if (primary != true) {
			fontNameString = SITE_FONT_SECONDARY;
		}

		var styleString:String = " font-family: '" + fontNameString + "'; font-size: " + fontSize + "vh;";

		if (bold == true) {
			styleString += " font-weight: bold;";
		}
		field.styleString = styleString;
	}
}
