package spilehx.rfidtriggeradmin.page;

import spilehx.rfidtriggeradmin.page.components.LogsSection;
import spilehx.rfidtriggeradmin.page.components.CardsListSection;
import spilehx.rfidtriggeradmin.page.components.OverViewSection;
import haxe.ui.containers.VBox;
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
		contentContainer.verticalAlign = "center";
		contentContainer.horizontalAlign = "center";
		contentContainer.percentWidth = 99;
		contentContainer.percentHeight = 95;
		contentContainer.verticalSpacing = 10;

		this.addComponent(contentContainer);

		addOverViewSection();
		addCardsSection();
		addLogsSection();
	}

	private function addOverViewSection() {
		var section = new PageSection(new OverViewSection(), RFIDTriggerAdminText.OVERVIEW_SECTION_TITLE);
		contentContainer.addComponent(section);
		section.percentHeight = 15;
	}

	private function addCardsSection() {
		var section = new PageSection(new CardsListSection(), RFIDTriggerAdminText.CARDLIST_SECTION_TITLE);
		contentContainer.addComponent(section);
		section.percentHeight = 55;
	}

		private function addLogsSection() {
		var section = new PageSection(new LogsSection(), RFIDTriggerAdminText.LOGS_SECTION_TITLE);
		contentContainer.addComponent(section);
		section.percentHeight = 30;
	}
}
