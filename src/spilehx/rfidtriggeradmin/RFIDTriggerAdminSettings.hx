package spilehx.rfidtriggeradmin;

import haxe.ui.components.Label;

class RFIDTriggerAdminSettings {
	public static final SECTION_FADEIN_DUR:Float = .4;
	public static final UPDATE_INTERVAL:Int = 1000;
	public static final PAGE_BG_COLOUR:String = "0x7E807F";
	public static final DEPTH_SHADOW_COLOUR:Int = 0x252525;
	public static final SECTION_BG_COLOUR:Int = 0x333333;
	public static final SECTION_FIELD_BG_COLOUR:Int = 0x444444;
	public static final SECTION_BORDER_COLOUR:Int = 0xDFDCDC;
	public static final SECTION_TITLE_COLOUR:Int = 0xFFFFFF;
	public static final CARDLIST_SECTION_ROW_ACTIVE_BG_COLOUR:Int = 0x504F4F;
	public static final LOGS_TEXT_COLOUR:Int = 0x3A6D38;
	public static final CARDLIST_SECTION_VISIBLE_ROWS:Int = 10;

	public static function SET_FONT_L(field:Label, bold:Bool = false) {
		var fontSize:Float = 2.8;
		setFont(field, fontSize, bold);
	}

	public static function SET_FONT_M(field:Label, bold:Bool = false) {
		var fontSize:Float = 2.5;
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
