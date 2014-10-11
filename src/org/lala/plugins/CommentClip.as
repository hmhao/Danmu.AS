package org.lala.plugins 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.lala.comments.IComment;
	/**
	 * 评论播放视图
	 * @author hmh
	 **/
	public class CommentClip extends Sprite {
		private var _width:Number;
		private var _height:Number;
		private var _clip:Vector.<IComment>;
		private var _bitmap:Bitmap;
		private var _bitmapdata:BitmapData;
		public function CommentClip() {
			this._clip = new Vector.<IComment>();
		}
		
		private function onRenderHander(evt:Event):void {
			
		}
		
		/** 播放器调整大小时被调用 **/
		public function resize(width:Number, height:Number):void {
			this._width = width;
			this._height = height;
			if (this._bitmapdata) {
				this._bitmapdata.dispose();
			}
			this._bitmapdata = new BitmapData(width, height, true, 0);
		}
		/** 往舞台添加可视的评论实例 **/
		public function add(comment:IComment):void {
			this._clip.push(comment);
		}
		/** 移除舞台上可视的评论实例 **/
		public function remove(comment:IComment):void {
			this._clip.splice(this._clip.indexOf(comment),1);
			
		}
		/** 清除舞台上所有可视的评论实例 **/
		public function clear():void {
			var cmt:IComment;
			while (this._clip.length > 0) {
				cmt = this._clip[0] as IComment;
				cmt.stop();//调用stop将会自动从舞台中移除，参看IComment.complete
			}
		}
		/** 暂停舞台上所有可视的评论实例的动作 **/
		public function pause():void {
			var cmt:IComment;
			for (var i:int = 0, len:int = this._clip.length; i < len; i++) {
				cmt = this._clip[i] as IComment;
				cmt.pause();
			}
			removeEventListener(Event.ENTER_FRAME, onRenderHander);
			trace("comment pause");
		}
		/** 恢复舞台上所有可视的评论实例的动作 **/
		public function resume():void {
			var cmt:IComment;
			for (var i:int = 0, len:int = this._clip.length; i < len; i++) {
				cmt = this._clip[i] as IComment;
				cmt.resume();
			}
			addEventListener(Event.ENTER_FRAME, onRenderHander);
			trace("comment start");
		}
	}
}