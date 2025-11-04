package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers;

import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.core.ItemRenderer;

@:xml('
<item-renderer>
 	<label text="trigger" id="mainLabel" width="100%" />
</item-renderer>
')
class TriggerItemRenderer extends ItemRenderer {
	private var cardId:String;

	public function new() {
		super();
		this.registerEvent(MouseEvent.CLICK, onEntryClick);
	}

	private function onEntryClick(e) {
		RFIDTriggerAdminConfigManager.instance.sendTriggerRequest(cardId);
	}

	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);
		if (data != null) {
			cardId = cast Reflect.field(data, "colA"); // TODO: this is fragile, should not hang logic off haxeui table
		}
	}
}
