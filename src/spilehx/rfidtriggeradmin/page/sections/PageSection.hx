package spilehx.rfidtriggeradmin.page.sections;

import spilehx.config.RFIDTriggerAdminFonts;
import spilehx.config.RFIDTriggerAdminSettings;
import spilehx.rfidtriggeradmin.tools.AnimateEffect;
import haxe.ui.events.UIEvent;
import spilehx.rfidtriggeradmin.tools.UiFilterEffects;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Box;

@:xml('
   <box width="100%" height="10%">
		<vbox width="98%" height="100%" horizontalAlign="center" verticalAlign="center" verticalSpacing="0">
			<label id="titleLable" verticalAlign="center" />
			<box id="mainframeContent" width="100%" height="100%" horizontalAlign="center" verticalAlign="center"/>
		</vbox>
	</box>
')
class PageSection extends Box {
	private var doFadeIn:Bool;
	private var hasDepth:Bool;

	public function new(content:Component, title:String, doFadeIn:Bool = false, hasDepth:Bool = true) {
		super();
		this.doFadeIn = doFadeIn;
		this.hasDepth = hasDepth;
		setup();
		setTitle(title);
		addContent(content);

		if (doFadeIn == true) {
			this.opacity = 0;
		}
		this.registerEvent(UIEvent.SHOWN, onShown);
	}

	private function setup() {
		this.horizontalAlign = "center";
		this.backgroundColor = RFIDTriggerAdminSettings.SECTION_BG_COLOUR;
		this.borderColor = RFIDTriggerAdminSettings.SECTION_BORDER_COLOUR;
		this.borderRadius = 10;
	}

	private function onShown(e) {
		if(hasDepth == true){
			UiFilterEffects.addDepth(this, true);
		}
		if (doFadeIn == true) {
			this.opacity = 1;
			AnimateEffect.fadeInForward(this, RFIDTriggerAdminSettings.SECTION_FADEIN_DUR);
		}
	}

	private function setTitle(title:String) {
		if(title == ""){
			titleLable.parentComponent.removeComponent(titleLable);
		}else{
			titleLable.text = title;
			RFIDTriggerAdminFonts.SET_FONT_L(titleLable, false);
			titleLable.color = RFIDTriggerAdminSettings.SECTION_TITLE_COLOUR;
		}
	}

	private function addContent(content:Component) {
		mainframeContent.addComponent(content);
	}
}
