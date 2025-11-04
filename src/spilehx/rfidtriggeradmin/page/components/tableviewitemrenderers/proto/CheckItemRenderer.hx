package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto;

import haxe.ui.events.UIEvent;

@:xml('
<item-renderer>
	<checkbox id="valueCheck"/>
</item-renderer>
')
class CheckItemRenderer extends EditableItemRenderer {
	private override function addEvents() {
		valueCheck.registerEvent(UIEvent.CHANGE, function(e) {
			submitUpdate("enabled", valueCheck.selected);
		});
	}

	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);

		if (updateInProgress == false) {
			if (data != null) {
				var value:Bool = cast Reflect.field(data, this.id);
				valueCheck.selected = value;
			}
		}
	}
}
