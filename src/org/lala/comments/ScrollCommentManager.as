package org.lala.comments
{
    import flash.display.Sprite;
    
    import org.lala.event.*;
    import org.lala.net.*;
    import org.lala.utils.*;
    /** 滚动字幕管理 **/
    public class ScrollCommentManager extends CommentManager
    {
        public function ScrollCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 设置空间管理者
         **/
        override protected function setSpaceManager():void
        {
            this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
			this.commentFactory = new GeneralFactory(ScrollComment, 40, 20);
        }
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FLOW_RIGHT_TO_LEFT);
        }
    }
}