package org.lala.plugins 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import org.lala.comments.IComment;
	/**
	 * 评论播放视图
	 * @author hmh
	 **/
	public class CommentClip extends Sprite {
		public function CommentClip() {
		}
		/** 往舞台添加可视的评论实例 **/
		public function add(comment:IComment):void {
			this.addChild(comment as DisplayObject);
		}
		/** 移除舞台上可视的评论实例 **/
		public function remove(comment:IComment):void {
			this.removeChild(comment as DisplayObject);
		}
		/** 清除舞台上所有可视的评论实例 **/
		public function clear():void {
			var cmt:IComment;
			while (this.numChildren > 0) {
				cmt = this.getChildAt(0) as IComment;
				cmt.stop();//调用stop将会自动从舞台中移除，参看IComment.complete
			}
		}
		/** 暂停舞台上所有可视的评论实例的动作 **/
		public function pause():void {
			var cmt:IComment;
			for (var i:int = 0, len:int = this.numChildren; i < len; i++) {
				cmt = this.getChildAt(i) as IComment;
				cmt.pause();
			}
		}
		/** 恢复舞台上所有可视的评论实例的动作 **/
		public function resume():void {
			var cmt:IComment;
			for (var i:int = 0, len:int = this.numChildren; i < len; i++) {
				cmt = this.getChildAt(i) as IComment;
				cmt.resume();
			}
		}
	}
}