package org.lala.plugins {
	import org.lala.plugins.CommentInputUI;
	import org.lala.comments.CommentDataType;
	import org.lala.utils.CommentConfig;
	import org.lala.event.EventBus;
	import org.lala.event.MukioEvent;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	/**
	 * 吐槽评论输入框
	 * @author hmh
	 */
	public class CommentInput extends Sprite {
		public var sayTxt:TextField;
		public var restrictTxt:TextField;
		public var sendBtn:SimpleButton;
		
		private var _defaultText:String = "我也要吐个槽~ 最多可输入40字";
		private var _maxChars:int = 40;
		private var _areaRect:Object = { width:0, height:0 };
		private var _mDownPoint:Object = { x:0, y:0 };
		private var _pos:Object = { x:0.5, y:1 };//输入框位置的百分比,(0.5,1)代表底部中间
		private var _hadMove:Boolean;//是否移动过
		private var _inputting:Boolean;
		private var _config:CommentConfig = CommentConfig.getInstance();
		
		public function CommentInput() {
			initComponents();
			initEvents();
		}
		
		private function initComponents():void {
			var inputUI:CommentInputUI = new CommentInputUI();
			sayTxt = inputUI.getChildByName("sayTxt") as TextField;
			restrictTxt = inputUI.getChildByName("restrictTxt") as TextField;
			sendBtn = inputUI.getChildByName("sendBtn") as SimpleButton;
			sayTxt.text = _defaultText;
			sayTxt.maxChars = _maxChars;
			inputUI.mouseEnabled = false;
			restrictTxt.mouseEnabled = false;
			restrictTxt.visible = false;
			this.addChild(inputUI);
			this.buttonMode = true;
		}
		
		private function initEvents():void {
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			sendBtn.addEventListener(MouseEvent.CLICK, onSendClick);
			sayTxt.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
		}
		
		private function onMouseDown(evt:MouseEvent):void {
			_hadMove = false;
			_mDownPoint.x = this.mouseX;
			_mDownPoint.y = this.mouseY;
			if (!_inputting || evt.target != sayTxt) {
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				onStageClick(null);
				stage.focus = null;
			}
		}
		
		private function onMouseMove(evt:MouseEvent):void {
			var toX:Number = evt.stageX - _mDownPoint.x;
			var toY:Number = evt.stageY - _mDownPoint.y;
			this.x = Math.max(0, Math.min(toX, _areaRect.width - this.width));
			this.y = Math.max(0, Math.min(toY, _areaRect.height - this.height));
		}
		
		private function onMouseUp(evt:MouseEvent):void {
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			var pos:Object = { //取3位小数
				x:Number((this.x / (_areaRect.width - this.width)).toFixed(3)),
				y:Number((this.y / (_areaRect.height - this.height)).toFixed(3))
			};
			if (pos.x != _pos.x || pos.y != _pos.y) {//判断是否移动过
				_pos.x = pos.x;
				_pos.y = pos.y;
				_hadMove = true;
			}
		}
		
		private function onMouseClick(evt:MouseEvent):void {
			if (_hadMove) return;//移动过以后不处理
			if (evt.target == sayTxt) {
				if (sayTxt.text == _defaultText) {
					sayTxt.text = "";
				}
				stage.focus = sayTxt;
				_inputting = true;
				evt.stopImmediatePropagation();//防止onStageClick马上执行
				this.stage.addEventListener(MouseEvent.CLICK, onStageClick);
			}
			//trace("click:" + evt.target);
		}
		
		private function onStageClick(evt:MouseEvent):void {
			this.stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			if (sayTxt.text == "") {
				sayTxt.text = _defaultText;
			}
			_inputting = false;
		}
		
		private function onSendClick(evt:MouseEvent):void {
			if (_hadMove) return;
			trace("send");
			if (sayTxt.text != "") {
				var data:Object = { };
				data.type = CommentDataType.NORMAL;
				data.text = "【我】：" + sayTxt.text;
				data.color = _config.color;
				data.size = 25;
				data.mode = 'toLeft';
				EventBus.getInstance().sendMukioEvent(MukioEvent.DISPLAY, data);
			}
		}
		
		private function onTextInput(evt:TextEvent):void {
			//trace("input");
		}
		
		public function setRectangle(width:Number, height:Number):void {
			_areaRect.width = width;
			_areaRect.height = height;
			this.x = (width - this.width) * _pos.x;
			this.y = (height - this.height) * _pos.y;
		}
	}
}