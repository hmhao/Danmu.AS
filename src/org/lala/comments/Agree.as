package org.lala.comments 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.ColorTransform;
	import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import fl.transitions.easing.None;
	
	/**
	 * ...
	 * @author hmh
	 */
	public class Agree extends Sprite 
	{
		private var _num:int;
		private var _color:uint;
		private var _icon:Shape;
		private var _numText:TextField;
		private var _voteText:TextField;
		/** 动画对象 **/
        protected var _tw:Tween;
		
		public function Agree() 
		{
			_icon = new Shape();
			_icon.graphics.beginFill(0);
			_icon.graphics.drawRect(0, 5, 10, 20);
			_icon.graphics.endFill();
			_numText = new TextField();
			_numText.autoSize = TextFieldAutoSize.LEFT;
			_numText.selectable = false;
			_numText.text = "0";
			_numText.x = _icon.x + _icon.width + 3;
			_numText.y = 5;
			_voteText = new TextField();
			_voteText.autoSize = TextFieldAutoSize.LEFT;
			_voteText.selectable = false;
			_voteText.text = "+1";
			_voteText.visible = false;
			_voteText.x = _icon.x;
			_voteText.y = -_voteText.textHeight;
			this.addChild(_icon);
			this.addChild(_numText);
			this.addChild(_voteText);
		}
		
		public function get num():int 
		{
			return _num;
		}
		
		public function set num(value:int):void 
		{
			_num = value;
			_numText.text = "" + _num;
			_numText.visible = _num > 0;
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			var colorInfo:ColorTransform = this.transform.colorTransform;
			colorInfo.color = _color;
			this.transform.colorTransform = colorInfo;
		}
		
		public function vote():void 
		{
			this.num++;
			if (_tw) {
				this.completeHandler();
			}
			_voteText.visible = true;
			_tw = new Tween(_voteText,'y',None.easeOut,y,-15,0.5,true);
            _tw.addEventListener(TweenEvent.MOTION_FINISH, completeHandler);
		}
		
		private function completeHandler(event:TweenEvent = null):void
        {
			_tw.removeEventListener(TweenEvent.MOTION_FINISH, completeHandler);
            _tw = null;
			_voteText.visible = false;
			_voteText.y = -_voteText.textHeight;
        }
	}
}