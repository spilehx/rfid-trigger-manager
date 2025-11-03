package spilehx.rfidtriggeradmin.page;

import spilehx.rfidtriggeradmin.page.components.OverViewSection;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;
import spilehx.rfidtriggeradmin.page.components.PageSection;

class MainPage extends Box {
	private var contentContainer:VBox;

	public function new() {
		super();
		init();
	}

	private function init() {
		this.percentHeight = this.percentWidth = 100;
		this.registerEvent(UIEvent.SHOWN, onPageShown);
	}

	private function onPageShown(e) {
		contentContainer = new VBox();
		contentContainer.verticalAlign = contentContainer.horizontalAlign = "center";
		contentContainer.percentWidth = 99;
		contentContainer.percentHeight = 90;

		this.addComponent(contentContainer);

		addOverViewSection();
        addCardsSection();
	}

	private function addOverViewSection() {
		var section = new PageSection(new OverViewSection(), "Status");
		contentContainer.addComponent(section);
		section.percentHeight = 20;
	}

    private function addCardsSection() {
		var section = new PageSection(new OverViewSection(), "Cards");
		contentContainer.addComponent(section);
		section.percentHeight = 60;
	}
}
