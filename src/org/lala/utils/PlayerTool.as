package org.lala.utils
{ 
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
	
    import org.lala.net.CommentServer;
    import org.lala.plugins.CommentView;
    import org.lala.utils.CommentConfig;

    /** 
    * 播放器常用方法集
    * 播放sina视频可以直接调用Player的load方法,因为有SinaMediaProvider
    * 但是播放youku视频要借用SinaMediaProvider,
    * 此外还要对视频信息作解析,这些任务顺序可能较为复杂,因此放在该类中,保证主文件的清洁
    * @author aristotle9
    **/
    public class PlayerTool extends EventDispatcher
    {
        /** 所辅助控制的弹幕插件的引用,主要用来加载弹幕文件 **/
        private var _commentView:CommentView;
		
        private var config:CommentConfig = CommentConfig.getInstance();
        
        public function PlayerTool(target:IEventDispatcher=null)
        {
            _commentView = CommentView.getInstance();
            super(target);
        }
        
        /**
        * 加载一般弹幕文件
        * @params url 弹幕文件地址
        **/
        public function loadCmtFile(url:String):void
        {
            _commentView.loadComment(url);
        }
        /**
        * 加载AMF弹幕文件
        * @params server 弹幕服务器
        **/
        public function loadCmtData(server:CommentServer):void
        {
            _commentView.provider.load('',CommentFormat.AMFCMT,server);
        }
        //以下两个函数在代理测试时使用        
        /**
        * 加载bili弹幕文件
        * @params cid 弹幕id
        **/
        public function loadBiliFile(cid:String):void
        {
            loadCmtFile('http://www.bilibili.us/dm,' + cid + '?r=' + Math.ceil(Math.random() * 1000));
        }
        /**
        * 加载acfun弹幕文件
        * @params cid 弹幕id
        **/
        public function loadAcfunFile(cid:String):void
        {
            loadCmtFile('http://124.228.254.234/newflvplayer/xmldata/' + cid + '/comment_on.xml?r=' + Math.random());
        }
    }
}