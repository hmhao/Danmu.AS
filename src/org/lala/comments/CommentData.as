package org.lala.comments {
	import tv.bilibili.script.*;
	
	public class CommentData extends Object {
		public var mode:uint = 1;
		public var size:int = 25;
		public var date:String = "";
		public var color:uint = 16777215;
		public var pool:int = 0;
		public var blocked:Boolean = false;
		public var blockType:uint = 0;
		public var id:uint = 0;
		public var msg:String = "";
		public var border:Boolean = false;
		public var preview:Boolean = false;
		public var type:String = "";
		public var live:Boolean = false;
		public var locked:Boolean = false;
		public var deleted:Boolean = false;
		public var reported:Boolean = false;
		public var credit:Boolean = false;
		
		private var _text:String = "";
		private var _stime:Number = NaN;
		private var _danmuId:uint = 0;
		private var _userId:String = "";
		private var _on:Boolean = false;
		
		public function CommentData(data:Object = null) {
			if (data !== null) {
				for each(var k:String in data) {
					try {
						this[k] = data[k];
					} catch (e:Error) {
						this[k] = data[k];
					}
				}
			}
		}
		
		public function get text():String {
			return this._text;
		}
		
		public function set text(value:String):void {
			this._text = value;
		}
		
		public function get stime():Number {
			return this._stime;
		}
		
		public function set stime(value:Number):void {
			this._stime = value;
		}
		
		public function get danmuId():uint {
			return this._danmuId;
		}
		
		public function set danmuId(value:uint):void {
			this._danmuId = value;
		}
		
		public function get userId():String {
			return this._userId;
		}
		
		public function set userId(value:String):void {
			this._userId = value;
		}
		
		public function get on():Boolean {
			return this._on || this.deleted;
		}
		
		public function set on(value:Boolean):void {
			this._on = value;
		}
	}
}
