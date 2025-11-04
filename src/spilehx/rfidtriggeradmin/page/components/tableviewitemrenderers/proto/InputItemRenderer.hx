package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto;

import haxe.ui.events.UIEvent;

@:xml('
<item-renderer>
    <textfield id="valueComponent" width="100%" style="text-align:left;" />
</item-renderer>
')
class InputItemRenderer extends EditableItemRenderer {
	private override function addEvents() {
		valueComponent.registerEvent(UIEvent.CHANGE, function(e) {
			submitUpdate("name", valueComponent.text);
		});
	}

	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);
		if (updateInProgress == false) {
			if (data != null) {
				var value = Reflect.field(data, this.id);
				valueComponent.text = value;
			}
		}
	}
}
