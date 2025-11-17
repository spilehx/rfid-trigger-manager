package spilehx.rfidtriggeradmin.page.components.modelwindow;

import haxe.ui.components.DropDown;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import spilehx.rfidtriggeradmin.tools.AnimateEffect;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
        <box id="idiotLid" width="100%" height="100%"/>
        <box id="contentContainer" width="60%" height="60%" horizontalAlign="center" verticalAlign="center" />
	</box>
')
class ModalWindow extends Box {
	private var content:Component;

	public function new(content:Component) {
		super();
		this.content = content;
		setup();
		this.registerEvent(UIEvent.SHOWN, onShown);
	}

	private function setup() {
		this.opacity = 0;

		contentContainer.backgroundColor = RFIDTriggerAdminSettings.MODAL_CONTENT_BG_COLOUR;
		contentContainer.borderColor = RFIDTriggerAdminSettings.MODAL_CONTENT_BORDER_COLOUR;
		contentContainer.borderSize = 2;
		contentContainer.borderRadius = 7;
		contentContainer.padding = 10;
		content.horizontalAlign = content.verticalAlign = "center";
		contentContainer.addComponent(content);

		idiotLid.backgroundColor = RFIDTriggerAdminSettings.MODAL_LID_BG_COLOUR;
		idiotLid.opacity = RFIDTriggerAdminSettings.MODAL_LID_BG_OPACITY;
	}

	private function onShown(e) {
		addEvents();
		AnimateEffect.executeAfterDelay(200, transitionIn);
	}

	private function transitionIn() {
		AnimateEffect.fadeIn(this, function() {
			this.opacity = 1;
		});
	}

	private function addEvents() {
		idiotLid.registerEvent(MouseEvent.CLICK, onIdiotLidClicked);
	}

	private function removeEvents() {
		idiotLid.unregisterEvent(MouseEvent.CLICK, onIdiotLidClicked);
	}

	private function onIdiotLidClicked(e) {
		closeModal();
	}

	private function closeModal() {
		RFIDTriggerAdminView.instance.closeModal();
	}
}

@:xml('
   	<box width="100%" height="100%" >
       <hbox id="contentContainer" width="100%" height="96%" verticalAlign="bottom">
            <vbox id="settingsList" width="30%" height="95%" verticalAlign="center" verticalSpacing="10" />
            <rule direction="vertical" height="90%" verticalAlign="center"/>
            <box id="settingsOptions" width="70%" height="100%" />
       </hbox>
       <label id="closeBtn" text="X" horizontalAlign="right" verticalAlign="top"/> 
	</box>
')
class ModalContentSettings extends Box {
	private var sectionContent:Array<SettingsSection>;

	public function new() {
		super();

		RFIDTriggerAdminSettings.SET_FONT_S(closeBtn, true);
		closeBtn.registerEvent(MouseEvent.CLICK, function(e) {
			RFIDTriggerAdminView.instance.closeModal();
		});

		this.registerEvent(UIEvent.SHOWN, onShown);
	}

	private function onShown(e) {
		addSections();
	}

	private function addSections() {
		sectionContent = new Array<SettingsSection>();

		sectionContent.push(new SettingsSection("DEVICE", [
			new SettingsSectionItem("Device ID", "deviceID", SettingsSectionItem.TYPE_DROPDOWN, "avalibleDevices")
		]));

		// sectionContent.push(new SettingsSection("You-tube",
		//     [new SettingsSectionItem("poo")]
		// ));

		// sectionContent.push(new SettingsSection("Spotify",
		//     [new SettingsSectionItem("poo")]
		// ));

		for (s in sectionContent) {
			s.onSelected = onSectionSelected;
			settingsList.addComponent(s);
		}

		// activate first entry
		onSectionSelected(sectionContent[0]);
	}

	private function onSectionSelected(section:SettingsSection) {
		for (s in sectionContent) {
			s.active(false);
		}
		section.active(true);

		setSettingsOptionsContent(section.content);
	}

	private function setSettingsOptionsContent(content:Component) {
		AnimateEffect.fadeOut(settingsOptions, function() {
			settingsOptions.removeAllComponents(false);
			settingsOptions.addComponent(content);
			AnimateEffect.executeAfterDelay(300, function() {
				AnimateEffect.fadeIn(settingsOptions);
			});
		});
	}
}

class SettingsSection extends Box {
	private var title:String;
	private var label:Label;
	private var settingsSectionItems:Array<SettingsSectionItem>;

	@:isVar public var content(default, null):VBox;
	@:isVar public var onSelected(get, set):SettingsSection->Void;

	public function new(title:String, settingsSectionItems:Array<SettingsSectionItem>) {
		this.settingsSectionItems = settingsSectionItems;
		this.title = title;
		super();
		setup();
	}

	private function setup() {
		this.percentWidth = 100;
		label = new Label();
		label.text = title.toUpperCase();
		this.addComponent(label);
		this.registerEvent(MouseEvent.CLICK, onSectionClicked);
		active(false);

		setupContent();
	}

	private function setupContent() {
		content = new VBox();
		content.percentHeight = 90;
		content.percentWidth = 95;
		content.verticalAlign = content.horizontalAlign = "center";
		for (settingsSectionItem in settingsSectionItems) {
			content.addComponent(settingsSectionItem);
			// content.addComponent(new HorizontalRule());
		}
	}

	private function onSectionClicked(e) {
		if (onSelected != null) {
			onSelected(this);
		}
	}

	public function active(state:Bool) {
		if (state == true) {
			label.color = RFIDTriggerAdminSettings.SETTING_MODAL_ITEM_ACTIVE_COLOUR;
			label.marginLeft = 15;
			RFIDTriggerAdminSettings.SET_FONT_M(label, true);
		} else {
			label.color = RFIDTriggerAdminSettings.SETTING_MODAL_ITEM_INACTIVE_COLOUR;
			label.marginLeft = 25;
			RFIDTriggerAdminSettings.SET_FONT_S(label, false);
		}
	}

	function get_onSelected():SettingsSection->Void {
		return onSelected;
	}

	function set_onSelected(onSelected):SettingsSection->Void {
		return this.onSelected = onSelected;
	}
}

class SettingsSectionItem extends Box {
	public static final TYPE_DROPDOWN:String = "TYPE_DROPDOWN";

	private var title:String;
	private var settingsKey:String;
	private var type:String;
	private var label:Label;
	private var optionsKey:String;

	public function new(title:String, settingsKey:String, type:String, optionsKey:String = "") {
		this.percentWidth = 100;
		this.title = title;
		this.settingsKey = settingsKey;
		this.type = type;
		this.optionsKey = optionsKey;

		super();
		setup();
	}

	private function setup() {
		label = new Label();
		label.text = title;
		RFIDTriggerAdminSettings.SET_FONT_S(label, false);
		label.color = RFIDTriggerAdminSettings.SETTING_MODAL_ITEM_ACTIVE_COLOUR;
		this.addComponent(label);

		label.percentWidth = 50;

		if (type == TYPE_DROPDOWN) {
			this.addComponent(getDropDown());
		}
	}

	private function getDropDown():DropDown {
		var dd:DropDown = new DropDown();
		dd.text = Reflect.getProperty(RFIDTriggerAdminConfigManager.instance.settings, settingsKey);

		var options:Array<String> = Reflect.getProperty(RFIDTriggerAdminConfigManager.instance.settings, optionsKey);

		var ddOptions:Array<Dynamic> = new Array<Dynamic>();
		for (device in options) {
			ddOptions.push({
				text: device
			});
		}

		dd.dataSource.data = ddOptions;

		dd.horizontalAlign = "right";
		dd.percentWidth = 50;


		dd.registerEvent(UIEvent.CHANGE, function(e) {
			RFIDTriggerAdminConfigManager.instance.updateDevice(dd.text, function(e) {
			});
		});

		return dd;
	}
}
