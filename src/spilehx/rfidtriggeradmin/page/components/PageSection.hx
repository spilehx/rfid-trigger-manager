package spilehx.rfidtriggeradmin.page.components;

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
	public function new(content:Component, title:String) {
		super();
		setup();
		setTitle(title);
		addContent(content);
	}

	private function setup() {
		this.horizontalAlign = "center";
		this.backgroundColor = RFIDTriggerAdminSettings.SECTION_BG_COLOUR;
		this.borderColor = RFIDTriggerAdminSettings.SECTION_BORDER_COLOUR;
		this.borderRadius = 10;
	}

	private function setTitle(title:String) {
		titleLable.text = title;
		titleLable.fontSize = 30;
		titleLable.style.fontBold = true;
		titleLable.color = RFIDTriggerAdminSettings.SECTION_TITLE_COLOUR;
	}

	private function addContent(content:Component) {
		mainframeContent.addComponent(content);
	}
}
