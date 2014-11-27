package org.lala.plugins 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import org.lala.comments.IComment;
	import org.lala.comments.Comment;
	/**
	 * 评论播放视图
	 * @author hmh
	 **/
	public class CommentClip extends Sprite {
		private var _isPausing:Boolean = false;
		private var _lines:Array = new Array();
		public function CommentClip() {
		}
		/** 往舞台添加可视的评论实例 **/
		public function add(comment:IComment):void {
			var cmt:DisplayObject = comment as DisplayObject;
			cmt.addEventListener(MouseEvent.CLICK, vote);
			cmt.addEventListener(MouseEvent.ROLL_OVER, pauseLine);
			cmt.addEventListener(MouseEvent.ROLL_OUT, resumeLine);
			var index:int = Math.round(cmt.y / cmt.height);
			if (_lines[index] == null) {
				_lines[index] = new Line();
			}
			(_lines[index] as Line).add(comment);
			this.addChild(cmt);
			//trace(cmt.y , cmt.height, cmt.y / cmt.height, index, Comment(cmt).data.text)
		}
		/** 移除舞台上可视的评论实例 **/
		public function remove(comment:IComment):void {
			var cmt:DisplayObject = comment as DisplayObject;
			cmt.removeEventListener(MouseEvent.CLICK, vote);
			cmt.removeEventListener(MouseEvent.ROLL_OVER, pauseLine);
			cmt.removeEventListener(MouseEvent.ROLL_OUT, resumeLine);
			var index:int = Math.round(cmt.y / cmt.height);
			(_lines[index] as Line).remove(comment);
			this.removeChild(cmt);
		}
		/** 清除舞台上所有可视的评论实例 **/
		public function clear():void {
			var cmt:IComment;
			while (this.numChildren > 0) {
				cmt = this.getChildAt(0) as IComment;
				cmt.stop();//调用stop将会自动从舞台中移除，参看IComment.complete
			}
			_isPausing = false;
		}
		/** 暂停舞台上所有可视的评论实例的动作 **/
		public function pause():void {
			var cmt:IComment;
			for (var i:int = 0, len:int = this.numChildren; i < len; i++) {
				cmt = this.getChildAt(i) as IComment;
				cmt.pause();
			}
			_isPausing = true;
		}
		/** 恢复舞台上所有可视的评论实例的动作 **/
		public function resume():void {
			var cmt:IComment;
			for (var i:int = 0, len:int = this.numChildren; i < len; i++) {
				cmt = this.getChildAt(i) as IComment;
				cmt.resume();
			}
			_isPausing = false;
		}
		private function vote(evt:MouseEvent):void {
			var cmt:IComment = evt.currentTarget as IComment;
			cmt.vote();
		}
		private function pauseLine(evt:MouseEvent):void {
			if (_isPausing) return;
			var cmt:DisplayObject = evt.currentTarget as DisplayObject;
			var index:int = Math.round(cmt.y / cmt.height);
			_lines[index].pause();
		}
		
		private function resumeLine(evt:MouseEvent):void {
			if (_isPausing) return;
			var cmt:DisplayObject = evt.currentTarget as DisplayObject;
			var index:int = Math.round(cmt.y / cmt.height);
			_lines[index].resume();
		}
	}
}
import org.lala.comments.Comment;
import org.lala.comments.IComment;
class Line {
	private var _items:Vector.<IComment> = new Vector.<IComment>();
	private var _isPausing:Boolean = false;
	
	public function add(comment:IComment):void {
		_isPausing && comment.pause();
		_items.push(comment);
	}
	public function remove(comment:IComment):void {
		_items.splice(_items.indexOf(comment),1);
	}
	public function pause():void {
		for (var i:int = 0, len:int = _items.length; i < len; i++ ) {
			_items[i].pause();
		}
		_isPausing = true;
	}
	public function resume():void {
		for (var i:int = 0, len:int = _items.length; i < len; i++ ) {
			_items[i].resume();
		}
		_isPausing = false;
	}
}