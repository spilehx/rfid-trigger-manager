package spilehx.rfidtriggeradmin.page;

import spilehx.imagedata.SettingsIconImg;
import spilehx.imagedata.LogoImg;
import haxe.ui.components.Image;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Link;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.components.HorizontalRule;
import spilehx.rfidtriggeradmin.page.sections.LogsSection;
import spilehx.rfidtriggeradmin.page.sections.CardsListSection;
import spilehx.rfidtriggeradmin.page.sections.OverViewSection;
import haxe.ui.containers.VBox;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;
import spilehx.rfidtriggeradmin.page.sections.PageSection;
import haxe.ui.constants.ScaleMode;

class MainPage extends Box {
	private var contentContainer:VBox;
	private var sectionContainer:VBox;

	private static final CONTENT_PADDING:Float = 15;

	private static final HEADER_HEIGHT:Float = 10;
	private static final FOOTER_HEIGHT:Float = 3;

	private static final SECTION_CONTENT_HEIGHT:Float = 100 - HEADER_HEIGHT - FOOTER_HEIGHT;

	public function new() {
		super();
		init();
	}

	private function init() {
		this.percentHeight = this.percentWidth = 100;
		this.registerEvent(UIEvent.SHOWN, onPageShown);
	}

	private function onPageShown(e) {
		this.unregisterEvent(UIEvent.SHOWN, onPageShown);
		setupPage();
	}

	private function setupPage() {
		trace("HELLLOOOO");

		contentContainer = new VBox();
		contentContainer.verticalAlign = "center";
		contentContainer.horizontalAlign = "center";
		contentContainer.percentWidth = contentContainer.percentHeight = 100;
		contentContainer.padding = CONTENT_PADDING;
		contentContainer.verticalSpacing = 5;

		this.addComponent(contentContainer);

		addPageHeaderItems();
		addPageSectionContentItems();
		addPageFooterItems();
	}

	private function addPageHeaderItems() {
		// TODO: make this a neat standalone class with its own nice haxeui xml
		var header:Box = new Box();

		// header.backgroundColor = 0xcc66cc;

		header.verticalAlign = "center";
		header.horizontalAlign = "center";
		header.percentWidth = 100;
		header.percentHeight = HEADER_HEIGHT;
		contentContainer.addComponent(header);

		var logoImg:Image = LogoImg.getImageComponent();
		logoImg.percentHeight = 100;
		logoImg.scaleMode = ScaleMode.FIT_HEIGHT;
		logoImg.verticalAlign = "center";
		logoImg.horizontalAlign = "left";
		header.addComponent(logoImg);

		var settingButton:Box = new Box();
		// settingButton.backgroundColor = 0x6670cc;
		settingButton.verticalAlign = "bottom";
		settingButton.horizontalAlign = "right";
		settingButton.percentWidth = 5;
		settingButton.percentHeight = 35;

		var settingIconImg:Image = SettingsIconImg.getImageComponent();
		settingIconImg.percentHeight = 90;
		settingIconImg.scaleMode = ScaleMode.FIT_HEIGHT;
		settingIconImg.verticalAlign = "center";
		settingIconImg.horizontalAlign = "center";
		settingButton.addComponent(settingIconImg);

		header.addComponent(settingButton);

		settingButton.registerEvent(MouseEvent.CLICK, function(e) {
			trace("click");
		});
	}

	private function addPageFooterItems() {
		// TODO: make this a neat standalone class with its own nice haxeui xml
		var footer:Box = new Box();
		footer.horizontalAlign = "center";
		footer.percentWidth = 98;
		footer.percentHeight = FOOTER_HEIGHT;
		contentContainer.addComponent(footer);

		var rule:HorizontalRule = new HorizontalRule();
		rule.backgroundColor = RFIDTriggerAdminSettings.FOOTER_CONTENT_COLOUR;
		rule.marginTop = 3;
		rule.horizontalAlign = "center";
		footer.addComponent(rule);

		var footerContent:Box = new Box();
		footerContent.percentWidth = 100;
		footerContent.percentHeight = 95;
		footerContent.verticalSpacing = 0;
		footerContent.horizontalAlign = "center";
		footerContent.verticalAlign = "center";

		var versionLabel:Label = new Label();
		RFIDTriggerAdminSettings.SET_FONT_XS(versionLabel);
		versionLabel.color = RFIDTriggerAdminSettings.FOOTER_CONTENT_COLOUR;

		// TODO: Dynamic footer version to be injected in build
		versionLabel.text = RFIDTriggerAdminText.VERSION_PREFIX + "0.0.1";

		versionLabel.horizontalAlign = "left";
		versionLabel.verticalAlign = "center";

		footerContent.addComponent(versionLabel);

		var siteLink:Link = new Link();
		RFIDTriggerAdminSettings.SET_FONT_XS(siteLink);
		siteLink.color = RFIDTriggerAdminSettings.FOOTER_CONTENT_COLOUR;
		siteLink.text = RFIDTriggerAdminText.MAIN_PAGE_FOOTER_SITE_LINK_TEXT;
		siteLink.horizontalAlign = "right";
		siteLink.verticalAlign = "center";

		siteLink.registerEvent(MouseEvent.CLICK, function(e) {
			js.Browser.window.open(RFIDTriggerAdminSettings.GITUB_REPO_URL, "_blank");
		});

		footerContent.addComponent(siteLink);

		footer.addComponent(footerContent);
	}

	private function addPageSectionContentItems() {
		sectionContainer = new VBox();
		sectionContainer.verticalAlign = "center";
		sectionContainer.horizontalAlign = "center";
		sectionContainer.percentWidth = 100;
		sectionContainer.percentHeight = SECTION_CONTENT_HEIGHT;
		sectionContainer.verticalSpacing = 5;
		contentContainer.addComponent(sectionContainer);

		addOverViewSection();
		addCardsSection();
		addLogsSection();
	}

	private function addOverViewSection() {
		var section = new PageSection(new OverViewSection(), RFIDTriggerAdminText.OVERVIEW_SECTION_TITLE, true);
		sectionContainer.addComponent(section);
		section.percentHeight = 15;
	}

	private function addCardsSection() {
		var section = new PageSection(new CardsListSection(), RFIDTriggerAdminText.CARDLIST_SECTION_TITLE, true);
		sectionContainer.addComponent(section);
		section.percentHeight = 55;
	}

	private function addLogsSection() {
		var section = new PageSection(new LogsSection(), RFIDTriggerAdminText.LOGS_SECTION_TITLE, true);
		sectionContainer.addComponent(section);
		section.percentHeight = 30;
	}
}
