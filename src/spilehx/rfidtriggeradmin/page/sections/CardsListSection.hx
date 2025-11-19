package spilehx.rfidtriggeradmin.page.sections;

import spilehx.config.RFIDTriggerAdminText;
import spilehx.config.RFIDTriggerAdminSettings;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.containers.ScrollView;
import spilehx.rfidtriggeradmin.page.components.cardslistcomponents.CardListRow;
import haxe.ui.events.UIEvent;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
	 	<vbox id="tableContainer" width="100%" height="100%" >
			<hbox id="headerRow" horizontalAlign="center" width="95%" horizontalSpacing="5">
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="left" height="100%" width="100%" text="ID" style="font-size: 14px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text="Name" style="font-size: 14px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text="Active" style="font-size: 14px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text="Command" style="font-size: 14px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="center" horizontalAlign="center" height="100%" width="100%" text="Action" style="font-size: 14px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
			</hbox>
			<scrollview id="cardScrollView" width="95%" contentWidth="100%" horizontalAlign="center"/>
		
		</vbox>
		<vbox id="loadingContent" width="100%" horizontalAlign="center" verticalAlign="center">
			<spinner horizontalAlign="center" />
			<label textAlign="center" horizontalAlign="center" width="100%" id="waitingLabel"/>
		</vbox>
		<vbox id="noCardsContent" width="100%" horizontalAlign="center" verticalAlign="center">
			<label textAlign="center" horizontalAlign="center" width="100%" id="noCardsLable"/>
		</vbox>		
	</box>
')
class CardsListSection extends Box {
	private static final COL_WIDTHS:Array<Int> = [5, 13, 15, 8, 30, 20, 3, 3, 3];

	private var cardListRows:Array<CardListRow>;

	public function new() {
		super();
		cardListRows = new Array<CardListRow>();
		this.registerEvent(UIEvent.SHOWN, onShown);

		// // //TEST

		// var tot:Int = 0;
		// for(v in COL_WIDTHS){
		// 	tot += v;
		// }

		// LOG("TOTAL COLS---> "+tot);
	}

	private function onShown(e) {
		setup();
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onUpdate);
	}

	private function setup() {
		cardScrollView.borderSize = 0;
		headerRow.height = getRowHeight() * .5;
		this.backgroundColor = RFIDTriggerAdminSettings.SECTION_BG_COLOUR;

		headerRow.paddingTop = 5;
		tableContainer.borderRadius = 3;
		tableContainer.borderSize = 1;
		cardScrollView.backgroundColor = RFIDTriggerAdminSettings.SECTION_FIELD_BG_COLOUR;

		tableContainer.opacity = 0;
		noCardsContent.hidden = true;

		waitingLabel.text = RFIDTriggerAdminText.CARDLIST_SECTION_WAITING_FOR_LOAD;
		noCardsLable.text = RFIDTriggerAdminText.CARDLIST_SECTION_NO_CARDS;
	}

	private function onResize(e) {
		// LOG("ON onResize     ---");
	}

	private function onUpdate(settings:SettingsData) {
		hideLoader();
		if (settings.cards.length > 0) {
			tableContainer.opacity = 1;
			noCardsContent.hidden = true;
			populateRows(settings);
		} else {
			noCardsContent.hidden = false;
			tableContainer.opacity = 0;
		}
	}

	private function hideLoader() {
		if (loadingContent.parentComponent != null) { // remove loader if there
			loadingContent.parentComponent.removeComponent(loadingContent);
		}
	}

	private function populateRows(settings:SettingsData) {
		var cards:Array<CardData> = settings.cards;

		for (card in cards) {
			var cardListRow:CardListRow = getRowById(card.id);
			if (cardListRow == null) {
				cardListRow = addCardListRow(card);
			}
			cardListRow.card = card;
			cardListRow.update();
		}

		cardScrollView.height = getRowHeight() * RFIDTriggerAdminSettings.CARDLIST_SECTION_VISIBLE_ROWS;
		updateColWidths();
	}

	private function updateColWidths() {
		for (i in 0...headerRow.childComponents.length) {
			if (i < COL_WIDTHS.length - 1) {
				var ch:Component = headerRow.childComponents[i];
				ch.percentWidth = COL_WIDTHS[i];
			}
		}

		for (cardListRow in cardListRows) {
			cardListRow.updateColWidths(COL_WIDTHS);
		}
	}

	private function addCardListRow(card:CardData):CardListRow {
		var cardListRow:CardListRow = new CardListRow(card);
		cardListRows.push(cardListRow);

		cardScrollView.addComponent(cardListRow);
		cardListRow.height = getRowHeight();
		return cardListRow;
	}

	private function getRowById(cardId:String):CardListRow {
		for (cardListRow in cardListRows) {
			if (cardListRow.cardId == cardId) {
				return cardListRow;
			}
		}

		return null;
	}

	private function getRowHeight():Float {
		return (tableContainer.height / (RFIDTriggerAdminSettings.CARDLIST_SECTION_VISIBLE_ROWS + 1)); // +1 to accomadate header
	}
}
