package org.lala.net {
	import com.worlize.gif.GIFPlayer;
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
		
		public function EmoticonProvider() {
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener ( Event.COMPLETE, onComplete );
			_urlLoader.addEventListener ( IOErrorEvent.IO_ERROR, onIOError );
			start();
		}
		
		private function onIOError ( evt:IOErrorEvent ):void {
			trace(_gifSArr[_curLoadIndex] + "is not found");
			_curLoadIndex++;
			onComplete();
		}
		
		private function onComplete ( evt:Event = null):void  {
			if (evt) {
				_gifArr[_gifSArr[_curLoadIndex]] = evt.target.data;
				_curLoadIndex++;
			}
			if(_curLoadIndex<_gifSArr.length)
				_urlLoader.load(new URLRequest("img/" + _gifSArr[_curLoadIndex]));
		}
		
		private function start():void {
			_curLoadIndex = 0;
			onComplete();
		}
		
		public function getEmoticon(emoticon:String):ByteArray {
			var ba:ByteArray = _gifArr[emoticon];
			var newba:ByteArray = new ByteArray();
			newba.writeBytes(ba);
			newba.position = 0;
			return newba;
		}
		
		public static function getInstance():EmoticonProvider {
            if(instance == null) {
                instance = new EmoticonProvider();
            }
            return instance;
        }
	}
}