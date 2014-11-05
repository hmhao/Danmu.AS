package org.lala.net {
	import com.worlize.gif.GIFPlayer;
	import com.worlize.gif.GIFDecoder;
	import com.worlize.gif.events.AsyncDecodeErrorEvent;
	import com.worlize.gif.events.GIFDecoderEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author hmh
	 */
	public class EmoticonProvider {
		private static var instance:EmoticonProvider;
		private var _gifData:Array = [];
		private var _gifArr:Dictionary = new Dictionary();
		private var _curLoadIndex:int = 0;
		private var _urlLoader:URLLoader;
		private var _gifDecoder:GIFDecoder;
		
		public function EmoticonProvider() {
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener ( Event.COMPLETE, onComplete );
			_urlLoader.addEventListener ( IOErrorEvent.IO_ERROR, onIOError );
			
			CONFIG::debug {
				var bqmap:Array =  [
					{name:"[hi]",uri:"hi"}, {name:"[崇拜]",uri:"cb"}, {name:"[鬼脸]",uri:"gl"}, {name:"[害羞]",uri:"hx"},
					{name:"[加油]",uri:"jy"}, {name:"[接钱]",uri:"sq"}, {name:"[惊吓]",uri:"jx"}, {name:"[忙碌]",uri:"ml"},
					{name:"[扭捏]",uri:"nn"}, {name:"[撒花]",uri:"sh"}, {name:"[稍等]",uri:"sd"}, {name:"[喜欢]",uri:"xh"}
				]
				for(var i:int = 0; i<bqmap.length; i++){
					_gifData.push({name:bqmap[i].name,url:'http://img.kankan.xunlei.com/img/kankan/mp4_v3/bq/'+bqmap[i].uri+'.gif'});
				}
				this.load(_gifData);
			}
		}
		
		private function onIOError (event:IOErrorEvent ):void {
			trace(this + _gifData[_curLoadIndex].name + " is not found");
			_curLoadIndex++;
			if(_curLoadIndex<_gifData.length){
				handleDecodeComplete();
			}
		}
		
		private function onComplete(event:Event):void  {
			_gifDecoder = new GIFDecoder();
			_gifDecoder.addEventListener(GIFDecoderEvent.DECODE_COMPLETE, handleDecodeComplete);
			_gifDecoder.addEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, handleAsyncDecodeError);
			_gifDecoder.decodeBytes(event.target.data);
		}
		
		private function handleDecodeComplete(event:GIFDecoderEvent = null):void {
			var data:Object = _gifData[_curLoadIndex];
			if (event) {
				var gifConfig:Object = { };
				gifConfig.loopCount = _gifDecoder.loopCount;
				gifConfig.frames = _gifDecoder.frames;
				gifConfig.width = _gifDecoder.width;
				gifConfig.height = _gifDecoder.height;
				gifConfig.name = data.name;
				gifConfig.url = data.url;
				_gifDecoder.cleanup();
				_gifDecoder.removeEventListener(GIFDecoderEvent.DECODE_COMPLETE, handleDecodeComplete);
				_gifDecoder.removeEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, handleAsyncDecodeError);
				_gifDecoder = null;
				_gifArr[data.name] = gifConfig;
				_curLoadIndex++;
				data = _gifData[_curLoadIndex];
				//trace(this + data.name + " decode complete");
			}
			if(_curLoadIndex<_gifData.length){
				_urlLoader.load(new URLRequest(data.url));
			}
		}
		
		private function handleAsyncDecodeError(event:AsyncDecodeErrorEvent):void {
			trace(this + _gifData[_curLoadIndex].name + " decode error");
			_curLoadIndex++;
			if(_curLoadIndex<_gifData.length){
				handleDecodeComplete();
			}
		}
		/**
		 * 加载gif
		 * @param	gifData	
		 * 	[
		 * 	  	{name:1,url:1.gif},
		 * 	  	{name:2,url:2.gif}
		 * 		...
		 *  ]
		 */
		public function load(gifData:Array):void {
			_gifData = gifData;
			if(_gifData.length>0){
				_curLoadIndex = 0;
				handleDecodeComplete();
			}else {
				trace(this + "load empty gif");
			}
		}
		
		public function getEmoticon(emoticon:String):Object {
			return _gifArr[emoticon];
		}
		
		public static function getInstance():EmoticonProvider {
            if(instance == null) {
                instance = new EmoticonProvider();
            }
            return instance;
        }
		
		public function get gifData():Array {
			return _gifData;
		}
	}
}