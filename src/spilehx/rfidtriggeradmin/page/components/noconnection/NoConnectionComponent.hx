package spilehx.rfidtriggeradmin.page.components.noconnection;

import spilehx.config.RFIDTriggerAdminText;
import spilehx.config.RFIDTriggerAdminFonts;
import spilehx.rfidtriggeradmin.tools.AnimateEffect;
import spilehx.config.RFIDTriggerAdminSettings;
import spilehx.config.RFIDTriggerAdminImg;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;

@:xml('
   	<box height="100%" width="100%" verticalAlign="center" horizontalAlign="center">
        <box id="bg" height="100%" width="100%" verticalAlign="center" horizontalAlign="center"/>
        <vbox id="content" height="50%" width="50%" verticalAlign="center" horizontalAlign="center">
            <image id="noConnectionImg" width="40%" verticalAlign="center" horizontalAlign="center" scaleMode="fitwidth"/>
            <label id="noConnectLabelTitle" textAlign="center" width="100%" verticalAlign="center" horizontalAlign="center"/>
            <label id="noConnectLabelBody" textAlign="center" width="70%" verticalAlign="center" horizontalAlign="center"/>
        </vbox>
	</box>
')
class NoConnectionComponent extends Box {
	public function new() {
		super();
		init();
	}

	private function init() {
		this.registerEvent(UIEvent.SHOWN, onPageShown);
		this.registerEvent(UIEvent.HIDDEN, onPageHidden);
	}

	private function onPageShown(e) {
		this.unregisterEvent(UIEvent.SHOWN, onPageShown);
		setupPage();
	}

	private function onPageHidden(e) {
		AnimateEffect.cancelAnimation(content);
	}

	private function setupPage() {
		bg.backgroundColor = RFIDTriggerAdminSettings.PAGE_BG_COLOUR;
		bg.opacity = .9;
		noConnectionImg.resource = RFIDTriggerAdminImg.NO_CONNECT_IMG;

		noConnectLabelTitle.text = RFIDTriggerAdminText.NO_CONNECTION_TITLE_TEXT;
		RFIDTriggerAdminFonts.SET_FONT_L(noConnectLabelTitle);
		noConnectLabelTitle.color = RFIDTriggerAdminSettings.SECTION_TITLE_COLOUR;

        noConnectLabelBody.text = RFIDTriggerAdminText.NO_CONNECTION_BODY_TEXT;
		RFIDTriggerAdminFonts.SET_FONT_S(noConnectLabelBody);
		noConnectLabelBody.color = RFIDTriggerAdminSettings.SECTION_TITLE_COLOUR;
		
        AnimateEffect.attensionHeartBeat(content);
	}
}
