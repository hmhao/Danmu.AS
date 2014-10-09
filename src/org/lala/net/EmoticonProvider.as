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
		public var _gifSArr:Array = ["hi.gif", "崇拜.gif", "鬼脸.gif", 
									"害羞.gif", "加油.gif", "接钱.gif", 
									"惊吓.gif", "忙碌.gif", "扭捏.gif", 
									"撒花.gif", "稍等.gif", "喜欢.gif"];
		private var _curLoadIndex:int = 0;
		private var _gifArr:Dictionary = new Dictionary();
		private var _urlLoader:URLLoader;
		private var _gifDecoder:GIFDecoder;
		
		public function EmoticonProvider() {
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener ( Event.COMPLETE, onComplete );
			_urlLoader.addEventListener ( IOErrorEvent.IO_ERROR, onIOError );
			start();
		}
		
		private function onIOError (event:IOErrorEvent ):void {
			trace(_gifSArr[_curLoadIndex] + "is not found");
			_curLoadIndex++;
			handleDecodeComplete();
		}
		
		private function onComplete (event:Event):void  {
			_gifDecoder = new GIFDecoder();
			_gifDecoder.addEventListener(GIFDecoderEvent.DECODE_COMPLETE, handleDecodeComplete);
			_gifDecoder.addEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, handleAsyncDecodeError);
			_gifDecoder.decodeBytes(event.target.data);
		}
		
		private function handleDecodeComplete(event:GIFDecoderEvent = null):void {
			if (event) {
				var gifConfig:Object = {};
				gifConfig.loopCount = _gifDecoder.loopCount;
				gifConfig.frames = _gifDecoder.frames;
				gifConfig.imageWidth = _gifDecoder.width;
				gifConfig.imageHeight = _gifDecoder.height;
				_gifDecoder.cleanup();
				_gifDecoder.removeEventListener(GIFDecoderEvent.DECODE_COMPLETE, handleDecodeComplete);
				_gifDecoder.removeEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, handleAsyncDecodeError);
				_gifDecoder = null;
				_gifArr[_gifSArr[_curLoadIndex]] = gifConfig;
				_curLoadIndex++;
			}
			if(_curLoadIndex<_gifSArr.length){
				_urlLoader.load(new URLRequest("img/" + _gifSArr[_curLoadIndex]));
			}else {
				
			}
		}
		
		private function handleAsyncDecodeError(event:AsyncDecodeErrorEvent):void {
			trace(_gifSArr[_curLoadIndex] + "decode error");
			_curLoadIndex++;
			handleDecodeComplete();
		}
		
		private function start():void {
			_curLoadIndex = 0;
			handleDecodeComplete();
		}
		
		public function getEmoticon(emoticon:String):Object {
			return _gifArr[emoticon] || {};
		}
		
		public static function getInstance():EmoticonProvider {
            if(instance == null) {
                instance = new EmoticonProvider();
            }
            return instance;
        }
	}
}