package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto;

import spilehx.rfidtriggerserver.managers.settings.CardData;
import haxe.ui.core.ItemRenderer;

class EditableItemRenderer extends ItemRenderer {
	private var updateInProgress:Bool = false;
	private var cardId:String;
	private var initialPopulationComplete:Bool = false;

	private function submitUpdate(key:String, value:Dynamic) {
		var card:CardData = RFIDTriggerAdminConfigManager.instance.getCardByCardId(cardId);
		var currentValue:Dynamic = Reflect.getProperty(card, key);

		if (currentValue != value) {
			updateInProgress = true;
			Reflect.setField(card, key, value);
			RFIDTriggerAdminConfigManager.instance.updateCard(card, function(e) {
				updateInProgress = false;
			});
		}
	}

	private function addEvents() {
		// override to add on changed
	}

	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);

		if (initialPopulationComplete == false) {
			initialPopulationComplete = true;
			addEvents();
		}

		if (data != null) {
			cardId = cast Reflect.field(data, "colA"); // TODO: this is fragile, should not hang logic off haxeui table
		}
	}
}
