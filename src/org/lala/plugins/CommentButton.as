package org.lala.plugins {
	import org.lala.plugins.CommentButtonUI;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author hmh
	 */
	public class CommentButton extends Sprite {
		private var button:CommentButtonUI;
		private var _isOn:Boolean = false;
		
		public function CommentButton() {
			initComponents();
		}
		
		private function initComponents():void {
			button = new CommentButtonUI();
			this.addChild(button);
			this.mouseEnabled = false;
			this.buttonMode = true;
		}
		
		public function get isOn():Boolean {
			return _isOn;
		}
		
		public function set isOn(value:Boolean):void {
			_isOn = value;
			button.gotoAndStop(_isOn ? 2 : 1);
		}
	}
}