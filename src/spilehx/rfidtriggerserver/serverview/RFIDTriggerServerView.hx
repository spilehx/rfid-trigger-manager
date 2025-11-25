// package spilehx.rfidtriggerserver.serverview;

// import haxe.ui.events.MouseEvent;
// import haxe.ui.containers.VBox;
// import haxe.ui.HaxeUIApp;

// class RFIDTriggerServerView extends spilehx.core.ManagerCore {
// 	public static final instance:RFIDTriggerServerView = new RFIDTriggerServerView();

// 	public function init() {
// 		var app = new HaxeUIApp();
// 		app.ready(function() {
// 			app.addComponent(new RFIDTriggerServerViewMain());

// 			app.start();
// 		});
// 	}
// }

// @:xml('
//     <vbox style="padding: 5px;">
//         <style>
//             .button {
//                 font-size: 20px;
//             }
//         </style>
//         <hbox>
//             <button text="Click Me!" id="button1" style="color: red;" />
//             <button text="Click Me!" id="button2" style="color: green;" />
//         </hbox>    
//     </vbox>
// ')
// class RFIDTriggerServerViewMain extends VBox {
// 	public function new() {
// 		super();
// 		button1.onClick = function(e) {
// 			button1.text = "Thanks!";
// 		}
// 	}

// 	@:bind(button2, MouseEvent.CLICK)
// 	private function onMyButton(e:MouseEvent) {
// 		button2.text = "Thanks!";
// 	}
// }
