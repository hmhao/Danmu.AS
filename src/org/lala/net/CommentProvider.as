package org.lala.net
{
	import com.adobe.serialization.json.JSON;
    import flash.events.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import org.lala.event.CommentDataEvent;
    import org.lala.event.EventBus;
    import org.lala.event.MukioEvent;
    import org.lala.utils.CommentDataParser;
    import org.lala.utils.CommentFormat;
    
    /**
    * 弹幕的加载类,用于从外部加载弹幕文件到播放器
    * @author aristotle9
    **/
    public class CommentProvider extends EventDispatcher
    {
		private static const TEXT_XML:String = "text/xml";
		private static const TEXT_JSON:String = "text/json";
		
        /** 用于网络连接的loader **/
        private var _loader:URLLoader;
        /** 文件类型 **/
        private var _textType:String;
		/** 弹幕库 **/
        private var _repo:Array;
        
        public function CommentProvider()
        {
            _repo = [];
            
            EventBus.getInstance().addEventListener(MukioEvent.DISPLAY,displayeHandler);
            //EventBus.getInstance().addEventListener("displayRtmp",displayeHandler);
        }
        /** 接收内部发送的显示消息 **/
        private function displayeHandler(event:MukioEvent):void
        {
            dispatchCommentData(event.data.msg,event.data);
        }
        /** 加载成功 **/
        private function completeHandler(event:Event):void
        {
			this._loader.removeEventListener(Event.COMPLETE, completeHandler);
            this._loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            this.clear();
            try
            {
				if(_textType == TEXT_XML){
					parseXML(XML(_loader.data));
				}else if (_textType == TEXT_JSON) {
					parseJSON(JSON.decode(_loader.data))
				}
            } catch (error:Error) {
                msg("弹幕文件格式有误,无法正确解析.");
            }
        }
        /** 错误处理 **/
        private function errorHandler(event:Event):void
        {
			this._loader.removeEventListener(Event.COMPLETE, completeHandler);
            this._loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            this._loader = null;
            msg(event.toString());
        }
        /** 错误输出 **/
        private function msg(massage:String):void
        {
            EventBus.getInstance().log(massage);
        }
        /** 加载指定地址和格式的弹幕
        * @param url 弹幕文件地址,通常是一个xml文件
        * @param type 弹幕文件格式
        **/
        public function load(url:String,type:String = "",server:CommentServer=null):void
        {
            /** 加载前清理弹幕 **/
            this.dispatchEvent(new CommentDataEvent(CommentDataEvent.CLEAR));
            this._repo.splice(0, this._repo.length);
            if(type == "")
            {
                type = CommentFormat.OLDACFUN;
            }
            if(type == CommentFormat.AMFCMT)
            {
                server.getCmts(dispatchCommentData);
            }
            else
            {
				_textType = url.search(/\.xml$/) != -1 ? TEXT_XML : TEXT_JSON;
                var request:URLRequest = new URLRequest(url);
				if(this._loader == null){
					_loader = new URLLoader();
					_loader.addEventListener(Event.COMPLETE,completeHandler);
					_loader.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
					_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				}
                _loader.load(request);
            }
        }
		private function clear() : void
        {
            this._repo.splice(0, this._repo.length);
            this.dispatchEvent(new CommentDataEvent(CommentDataEvent.CLEAR));
        }
        /**
        * 解析xml
        * 把xml解析成一条条弹幕数据,并分发出去
        * 弹幕数据说明 ...
        **/
        private function parseXML(xml:XML):void
        {
            if(xml.data.length())
            {
                CommentDataParser.acfun_parse(xml,dispatchCommentData);
            }
            else if(xml.l.length())
            {
                CommentDataParser.acfun_new_parse(xml,dispatchCommentData);
            }
            else if(xml.d.length())
            {
                CommentDataParser.bili_parse(xml,dispatchCommentData);
            }
            else
            {
                msg("格式未识别.");
            }
        }
		/**
        * 解析json
        * 把json解析成一条条弹幕数据,并分发出去
        * 弹幕数据说明 ...
        **/
        private function parseJSON(json:Object):void
        {
            if(json && json.status == 200)
            {
                CommentDataParser.kankan_parse(json.data,dispatchCommentData);
            }
        }
        /**
        * 分发函数,处理单个弹幕数据
        **/
        private function dispatchCommentData(msg:String,data:Object):void
        {
            this.dispatchEvent(new CommentDataEvent(msg,data));
            //带有preview属性的不插入弹幕库
            if(data.preview)
            {
                return;
            }
            this._repo.push(data);
        }
        public function get commentResource():Array
        {
            return _repo;
        }
    }
}