package spilehx.rfidtriggeradmin.page.components.cardslistcomponents;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import js.html.FileReader;
import js.html.FileList;
import js.Browser;
import js.html.InputElement;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.core.Component;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" >
        <rule />
        <hbox id="content" width="100%" height="100%">
		    <box id="card_enabled" width="100%" height="95%" verticalAlign="center">
                <checkbox id="card_enabled_field" horizontalAlign="center" verticalAlign="center" height="90%"/>
            </box>
            <box id="card_id" width="100%" height="95%" verticalAlign="center">
                <label id="card_id_field" textAlign="left" horizontalAlign="center" verticalAlign="center" width="100%" text="card_id"/>
            </box>
            <box id="card_name" width="100%" height="95%" verticalAlign="center">
                <textfield id="card_name_field" horizontalAlign="center" verticalAlign="center" height="90%" width="100%" text="card_name"/>
            </box>
			<box id="card_active" width="100%" height="95%" verticalAlign="center">
                <label id="card_active_field" textAlign="center" horizontalAlign="center" verticalAlign="center" width="100%" text="card_id"/>
            </box>
            <box id="card_command" width="100%" height="95%" verticalAlign="center">
                 <textfield id="card_command_field" horizontalAlign="center" verticalAlign="center" height="90%" width="100%" text="card_command"/>
            </box>
            <box id="card_action" width="100%" height="95%" verticalAlign="center">
                 <dropdown id="card_action_field" horizontalAlign="center" verticalAlign="center" height="90%" width="100%" text="action"/>
            </box>
            <box id="card_start" width="100%" height="95%" verticalAlign="center">
               <image id="card_start_img" height="100%" width ="100%" horizontalAlign="center" verticalAlign="center" scaleMode="fitheight" />
            </box>
            <box id="card_image" width="100%" height="95%" verticalAlign="center">
               <image id="card_image_img" height="100%" width ="100%" horizontalAlign="center" verticalAlign="center" scaleMode="fitheight" />
            </box>
			<box id="card_cache" width="100%" height="95%" verticalAlign="center">
               <image id="card_cache_img" height="100%" width ="100%" horizontalAlign="center" verticalAlign="center" scaleMode="fitheight" />
            </box>
        </hbox>
	</box>
')
class CardListRow extends Box {
	@:isVar public var cardId(get, null):String;

	public var card:CardData;
	private var userUpdating:Bool = false;

	public function new(card:CardData) {
		super();
		this.card = card;
		setup();
	}

	private function setup() {
		setImages();
		setupChangeEvents();
	}

	private function setImages() {
		card_start_img.resource = RFIDTriggerAdminImg.PLAY_IMG;
		card_image_img.resource = RFIDTriggerAdminImg.PIC_IMG;
		card_cache_img.resource = RFIDTriggerAdminImg.CACHE_IMG;
	}

	public function updateColWidths(colWidths:Array<Int>) {
		for (i in 0...content.childComponents.length) {
			if (i < colWidths.length) {
				var ch:Component = content.childComponents[i];
				ch.percentWidth = colWidths[i];
			}
		}
	}

	public function update() {
		if (userUpdating == false) {
			card_id_field.text = card.id;
			card_name_field.text = card.name;
			card_enabled_field.selected = card.enabled;

			card_active_field.text = Std.string(card.active);
			card_command_field.text = Std.string(card.command);
			card_action_field.text = Std.string(card.action);

			card_cache.hidden = (card.action != "YTPlayListAction");//TODO: should be a static const

			// set action options
			var options:Array<Dynamic> = new Array<Dynamic>();
			for (action in RFIDTriggerAdminConfigManager.instance.settings.avalibleCardActions) {
				options.push({
					text: action
				});
			}

			card_action_field.dataSource.data = options;
		}
	}

	private function setupChangeEvents() {
		card_name_field.registerEvent(UIEvent.CHANGE, function(e) {
			onValueChanged("name", card_name_field.text);
		});
		card_enabled_field.registerEvent(UIEvent.CHANGE, function(e) {
			onValueChanged("enabled", card_enabled_field.selected);
		});
		card_command_field.registerEvent(UIEvent.CHANGE, function(e) {
			onValueChanged("command", card_command_field.text);
		});
		card_action_field.registerEvent(UIEvent.CHANGE, function(e) {
			onValueChanged("action", card_action_field.text);
		});

		card_start.registerEvent(MouseEvent.CLICK, function(e) {
			RFIDTriggerAdminConfigManager.instance.sendTriggerRequest(card.id);
		});

		card_image.registerEvent(MouseEvent.CLICK, function(e) {
			openImageFileSelector();
		});

		card_cache.registerEvent(MouseEvent.CLICK, function(e) {
			LOG("Caching playlist: "+card.id);
			RFIDTriggerAdminConfigManager.instance.sendCacheRequest(card.id);
		});
	}

	private function onValueChanged(fieldName:String, value:Dynamic) {
		var currentVal:Dynamic = Reflect.getProperty(card, fieldName);
		if (currentVal != value) {
		
			Reflect.setProperty(card, fieldName, value);
			RFIDTriggerAdminConfigManager.instance.updateCard(card, onCardDataUpdateComplete);
			userUpdating = true;
		}
	}

	private function onCardDataUpdateComplete(data) {
		LOG("Update Successful");
		userUpdating = false;
	}

	function get_cardId():String {
		return card.id;
	}

	private function openImageFileSelector() {
		var input:InputElement = Browser.document.createInputElement();
		input.type = "file";
		input.accept = "image/*";
		input.style.display = "none";

		input.onchange = function(_) {
			var files:FileList = input.files;
			if (files != null && files.length > 0) {
				var file = files.item(0);

				var reader = new FileReader();
				reader.onload = function(_) {
					var buffer = cast reader.result;
					var bytes = Bytes.ofData(buffer);

					// Encode to Base64
					var base64String = Base64.encode(bytes);

					RFIDTriggerAdminConfigManager.instance.sendImgUploadRequest(card.id, base64String);
				}

				reader.readAsArrayBuffer(file);
			}
		}

		input.click();
	}
}
