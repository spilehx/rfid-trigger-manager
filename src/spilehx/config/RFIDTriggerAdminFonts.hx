package spilehx.config;

import haxe.ui.components.Label;

class RFIDTriggerAdminFonts {
    private static final SITE_FONT_PRIMARY:String = "NunitoSans";
     private static final SITE_FONT_SECONDARY:String = "Antonio-VariableFont_wght";

    

    public static function SET_FONT_L(field:Label, bold:Bool = false) {
		var fontSize:Float = 2.8;
		setFont(field, fontSize, bold, SITE_FONT_SECONDARY);
	}

	public static function SET_FONT_M(field:Label, bold:Bool = false) {
		var fontSize:Float = 2;
		setFont(field, fontSize, bold, SITE_FONT_SECONDARY);
	}

	public static function SET_FONT_S(field:Label, bold:Bool = false) {
		var fontSize:Float = 1.5;
		setFont(field, fontSize, bold, SITE_FONT_PRIMARY);
	}
	public static function SET_FONT_XS(field:Label, bold:Bool = false) {
		var fontSize:Float = 1.3;
		setFont(field, fontSize, bold, SITE_FONT_PRIMARY);
	}

    

	private static function setFont(field:Label, fontSize:Float, bold:Bool = false, fontNameString:String = "") {
		// var styleString:String = " font-size: " + fontSize + "vh;";

        if(fontNameString == ""){
            fontNameString = SITE_FONT_PRIMARY;
        }

        var styleString:String = " font-family: '" + fontNameString + "'; font-size: " + fontSize + "vh;";


		if (bold == true) {
			styleString += " font-weight: bold;";
		}
		field.styleString = styleString;
	}
}