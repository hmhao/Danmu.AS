package org.lala.comments
{
    import flash.display.Sprite;
	import org.lala.plugins.CommentClip;
    import org.lala.event.*;
    import org.lala.net.*;
    import org.lala.utils.*;
    /** 反向滚动弹幕 **/
    public class RScrollCommentManager extends ScrollCommentManager
    {
        public function RScrollCommentManager(clip:CommentClip)
        {
            super(clip);
        }
		override protected function setSpaceManager():void 
		{
			this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
			this.commentFactory = new GeneralFactory(RScrollComment, 0, 20);
		}
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FLOW_LEFT_TO_RIGHT);
        }
    }
}