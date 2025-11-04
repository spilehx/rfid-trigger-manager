package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers;

import haxe.ui.core.ItemRenderer;

@:xml('
<item-renderer>
    <label id="mainLabel" width="100%" style="text-align:left;" />
</item-renderer>
')
class StaticItemRenderer extends ItemRenderer {
	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);
		if (data != null) {
			var value = Reflect.field(data, this.id);
			mainLabel.text = value;
		}
	}
}
