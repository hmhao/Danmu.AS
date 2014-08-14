package org.lala.filter {
	import com.adobe.serialization.json.JSON;
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	/**
	 * 弹幕过滤器类,把原来的文件改改就拿来用了
	 * @author aristotle9
	 **/
	public class CommentFilter extends EventDispatcher {
		/** 过滤器数据数组 **/
		private var fArr:Array;
		private var initialized:Boolean = false;
		
		public var enable:Boolean = true; //过滤总开关
		
		private static var instance:CommentFilter;
		
		public function CommentFilter() {
			if (instance != null) {
				throw new Error("class CommentFilter is a Singleton,please use getInstance()");
			}
			
			fArr = [{4: true, 5: true}, {}, {}];
			initialized = true;
			loadFromSharedObject();
		}
		
		public function get filterSource():Array {
			return fArr;
		}
		
		/** 单件 **/
		public static function getInstance():CommentFilter {
			if (instance == null) {
				instance = new CommentFilter();
			}
			return instance;
		}
		
		/**
		 * 启用|不启用过滤模式
		 * @param mode		参看CommentFilterMode
		 * @param key
		 * @param enable
		 */
		public function setModeEnable(mode:int, key:String, enable:Boolean):void {
			fArr[mode][key] = enable;
			if (initialized) {
				savetoSharedObject();
			}
		}
		
		/**
		 * 添加过滤模式
		 * @param mode		参看CommentFilterMode
		 * @param key
		 * @param enable
		 */
		public function addItem(mode:int, key:String, enable:Boolean = true):void {
			setModeEnable(mode, key, enable);
		}
		
		/**
		 * 删除过滤模式
		 * @param mode		参看CommentFilterMode
		 * @param key
		 */
		public function deleteItem(mode:int, key:String):void {
			delete fArr[mode][key];
			if (initialized) {
				savetoSharedObject();
			}
		}
		
		public function savetoSharedObject():void {
			trace("savetoSharedObject");
			try {
				var cookie:SharedObject = SharedObject.getLocal("MukioPlayer", '/');
				cookie.data['CommentFilter'] = toString();
				cookie.flush();
				trace(cookie.data['CommentFilter']);
			} catch (e:Error) {
			};
		}
		
		public function loadFromSharedObject():void {
			try {
				var cookie:SharedObject = SharedObject.getLocal("MukioPlayer", '/');
				fromString(cookie.data['CommentFilter']);
			} catch (e:Error) {
			};
		}
		
		override public function toString():String {
			var a:Array = [];
			a.push(fArr, enable);
			return JSON.encode(a);
		}
		
		public function fromString(source:String):void {
			try {
				var a:Array = JSON.decode(source);
				fArr = a[0];
				enable = a[1];
				trace(a);
			} catch (e:Error) {
			}
		}
		
		/**
		 * 校验接口
		 * @param item 弹幕数据
		 * @return 通过校验允许播放时返回true
		 **/
		public function validate(item:Object):Boolean {
			if (!enable) {
				return true;
			}
			var res:Boolean = true;
			var tmp:Object;
			for (var i:int = 0; i < fArr.length; i++) {
				tmp = fArr[i];
				if (tmp[item.mode] || //位置
					tmp[item.color] || //颜色
					tmp[item.id]) //用户
				{
					res = false;
					break;
				}
			}
			return res;
		}
	}
}