package spilehx.rfidtriggeradmin.page.components;

import spilehx.rfidtriggeradmin.tools.AnimateEffect;
import haxe.ui.events.UIEvent;
import spilehx.rfidtriggeradmin.tools.UiFilterEffects;
import haxe.ui.containers.Frame;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Box;

@:xml('
   <vbox width="95%" height="10%" style="padding:10px;">
        <label id="titleLable" verticalAlign="center" />
        <frame id="mainframe" width="100%" height="100%" horizontalAlign="center" verticalAlign="center">
            <box id="mainframeContent" width="100%" height="100%" horizontalAlign="center" verticalAlign="center">
            </box>
        </frame>
    </vbox>
')
class PageSection extends VBox {
	private var doFadeIn:Bool;

	public function new(content:Component, title:String, doFadeIn:Bool = false) {
		super();
		this.doFadeIn = doFadeIn;
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
		UiFilterEffects.addDepth(this, true);
		if (doFadeIn == true) {
			this.opacity = 1;
			AnimateEffect.fadeInForward(this, RFIDTriggerAdminSettings.SECTION_FADEIN_DUR);
		}
	}

	private function setTitle(title:String) {
		titleLable.text = title.toUpperCase();
		RFIDTriggerAdminSettings.SET_FONT_L(titleLable, true);
		titleLable.color = RFIDTriggerAdminSettings.SECTION_TITLE_COLOUR;
	}

	private function addContent(content:Component) {
		mainframeContent.addComponent(content);
	}
}
