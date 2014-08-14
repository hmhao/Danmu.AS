package org.lala.utils {
	import com.adobe.serialization.json.JSON;
	import flash.external.*;
	import flash.system.*;
	import flash.text.*;
	
	final public class ApplicationConstants extends Object {
		public static const SharedObjectName:String = "tv.bilibili.player";
		
		public function ApplicationConstants() {
			return;
		}
		
		public static function getDefaultFont():String {
			var fontList:Array = null;
			if (Capabilities.os.indexOf("Linux") != -1) {
				fontList = getCommentFontList();
				if (fontList.indexOf("WenQuanYi Micro Hei") !== -1) {
					return "WenQuanYi Micro Hei";
				}
				if (fontList.length >= 1) {
					return fontList[0];
				}
				return "sans";
			}
			if (Capabilities.os.indexOf("Mac") != -1) {
				return "Hei";
			}
			return "黑体";
		}
		
		public static function doesChangeUIFont():Boolean {
			if (Capabilities.os.indexOf("Linux") != -1 || Capabilities.os.indexOf("Mac") != -1) {
				return true;
			}
			return false;
		}
		
		public static function getCommentFontList():Array {
			var fontList:Array = [];
			var regex:RegExp = /黑|hei|kai/i;
			for each (var font:Font in Font.enumerateFonts(true)) {
				if (!font.fontName.match(regex)) {
					continue;
				}
				fontList.push(font.fontName);
			}
			return fontList;
		}
		
		public static function get chromePpApiPlugin():Object {
			var isPPAPI:Boolean;
			if (!ExternalInterface.available) {
				return "js interface not available!";
			}
			try {
				isPPAPI = ExternalInterface.call("function() {var isPPAPI = false,type = 'application/x-shockwave-flash',mimeTypes = navigator.mimeTypes;var endsWith = function(str, suffix) {return str.indexOf(suffix, str.length - suffix.length) !== -1;};if(mimeTypes && mimeTypes[type] && mimeTypes[type].enabledPlugin){var pluginName = mimeTypes[type].enabledPlugin.filename; if( pluginName == 'pepflashplayer.dll' || pluginName == 'libpepflashplayer.so' || endsWith(pluginName, 'Chrome.plugin')) isPPAPI = true;}return isPPAPI;}");
				return Boolean(isPPAPI);
			} catch (e:Error) {
				return "interface call error:" + e;
			}
			return false;
		}
		
		public static function loadByWebStorage(key:String, default_val:Object = null):Object {
			var str:String;
			try {
				if (ExternalInterface.available) {
					str = ExternalInterface.call("function(key){return localStorage[key];}", key) as String;
					return JSON.decode(decodeURIComponent(str));
				} else {
					return default_val;
				}
			} catch (e:Error) {
				return default_val;
			}
			return default_val;
		}
		
		public static function saveByWebStorage(key:String, value:Object):void {
			try {
				if (ExternalInterface.available) {
					ExternalInterface.call("function(key, val_str){localStorage[key]=val_str;}", key, encodeURIComponent(JSON.encode(value)));
				}
			} catch (e:Error) {
			}
			return;
		}
	}
}
