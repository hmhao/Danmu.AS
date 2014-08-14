package org.lala.plugins
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

    public class ModeFilterCheckBox extends Sprite
    {
		private var _label:String;
		private var _selected:Boolean;
		private var _textField:TextField;
		
        public function ModeFilterCheckBox(label:String = "")
        {
			_textField = new TextField();
			_textField.mouseEnabled = false;
			_textField.autoSize = TextFieldAutoSize.CENTER;
			addChild(_textField);
			this.label = label;
        }
		
		public function get label():String 
		{
			return _label;
		}
		
		public function set label(value:String):void 
		{
			_label = value;
			_textField.text = _label;
		}
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			_textField.backgroundColor = value ? 0xEEEEEE : 0x999999;
		}

    }
}
