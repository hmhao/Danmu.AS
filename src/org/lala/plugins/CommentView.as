package org.lala.plugins {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.lala.comments.*;
	import org.lala.event.*
	import org.lala.filter.*;
	import org.lala.net.*;
	import org.lala.utils.*;
	
	/**
	 * 弹幕播放插件:
	 * 只实现弹幕的加载与播放
	 **/ 
	
	public class CommentView extends Sprite {
		/** singleton **/
		private static var instance:CommentView;
		/** 弹幕来源,只有唯一一个实例 **/
		private var _provider:CommentProvider;
		/** 弹幕过滤器,只有唯一一个实例 **/
		private var _filter:CommentFilter;
		/** 弹幕管理者 **/
		private var managers:Vector.<CommentManager>;
		/** 弹幕层,类本身是插件层,但是位置不符合弹幕的需求,所以另起一层 **/
		private var _clip:CommentClip;
		/** 输入框 **/
		private var _input:CommentInput;
		/** 时间点 **/
		private var _stime:Number = 0;
		/** 普通弹幕配置 **/
		private var cmtConfig:CommentConfig = CommentConfig.getInstance();
		/** 插件的版本号,非JW播放器 **/
		private var _version:String;
		/** 简化的视频的播放器态,播放或静止 **/
		private var _isPlaying:Boolean = false;
		
		private var _timer:Timer;
		
		public function CommentView() {
			if (instance != null) {
				throw new Error("class CommentView is a Singleton,please use getInstance()");
			}
			/** 不接收点击事件 **/
			this.mouseEnabled = this.mouseChildren = false;
			_clip = new CommentClip();
			_clip.name = 'commentviewlayer';
			_clip.mouseEnabled = _clip.mouseChildren = false;
			_input = new CommentInput();
			_input.name = 'commentinput';
			managers = new Vector.<CommentManager>();
			init();
		}
		
		/** 单件 **/
		public static function getInstance():CommentView {
			if (instance == null) {
				instance = new CommentView();
			}
			return instance;
		}
		
		/** 接口方法:初始化插件,这时插件层已经添加到播放器的plugins层上,为最表层 **/
		public function initPlugin():void {
			/**
			 * 把层放置在紧随masked之后
			 * 从View.setupLayers函数可以看到JWP的层次结构,Plugin在最表层
			 **/
			var _p:DisplayObjectContainer = this.parent;
            var _root:DisplayObjectContainer = _p.parent;
			_root.addChild(clip);
			_root.addChild(input);
			
			/** 设置播放状态的初值 **/
			_isPlaying = true;
			
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, timeHandler);
			_timer.start();
		}
		
		/** 接口方法:播放器调整大小时被调用 **/
		public function resize(width:Number, height:Number):void {
			var w:int = width;
			var h:int = height;
			var rw:Number = w / cmtConfig.width;
			var rh:Number = h / cmtConfig.height;
			if (rw < rh)
				var r:Number = rw;
			else
				r = rh;
			//_clip.scaleY = _clip.scaleX = r;
			//_clip.x = (w - cmtConfig.width * r) / 2;
			//_clip.y = (h - cmtConfig.height * r) / 2;
			
			_input.setRectangle(w, h);//设置宽高会自动调整位置了
			
			/** 通知到位 **/
			for each (var manager:CommentManager in managers) {
				manager.resize(w, h);
			}
		}
		
		/** 接口方法,唯一的,小写字母标识 **/
		public function get id():String {
			return 'commentview';
		}
		
		/**
		 * 加载弹幕
		 * @param url 弹幕文件路径
		 **/
		public function loadComment(url:String):void {
			this._provider.load(url);
		}
		
		/**
		 * 播放时间事件
		 **/
		private function timeHandler(event:TimerEvent):void {
			if (cmtConfig.visible == false) {
				return;
			}
			_stime = _timer.currentCount;
			for each (var manager:CommentManager in managers) {
				manager.time(_stime);
			}
		}
		
		private function clearCommentDataHandler(event:CommentDataEvent) : void {
            this._clip.clear();
        }
		
		public function showComments(value:Boolean) : void {
			this.cmtConfig.visible = value;
			this._input.visible = value;
			this._clip.visible = value;
            this._clip.clear();
        }

		
		/**
		 * 当前时间
		 **/
		public function get stime():Number {
			return _stime;
		}
		
		/**
		 * 自身的初始化
		 **/
		private function init():void {
			this._provider = new CommentProvider();
			this._provider.addEventListener(CommentDataEvent.CLEAR, this.clearCommentDataHandler);
			this._filter = CommentFilter.getInstance();
			addManagers();
		}
		
		/**
		 * 添加弹幕管理者,每一种弹幕模式对应一个弹幕管理者
		 */
		private function addManagers():void {
			addManager(new CommentManager(_clip));
			addManager(new BottomCommentManager(_clip));
			addManager(new ScrollCommentManager(_clip));
			addManager(new RScrollCommentManager(_clip));
			addManager(new FixedPosCommentManager(_clip));
			addManager(new ZoomeCommentManager(_clip));
			addManager(new ScriptCommentManager(_clip));
		}
		
		/**
		 * 添加弹幕管理者
		 **/
		private function addManager(manager:CommentManager):void {
			manager.provider = this._provider;
			manager.filter = this._filter;
			this.managers.push(manager);
		}
		
		/**
		 * 返回弹幕提供者
		 **/
		public function get provider():CommentProvider {
			return this._provider;
		}
		
		/**
		 * 返回弹幕过滤器
		 **/
		public function get filter():CommentFilter {
			return this._filter;
		}
		
		/**
		 * 返回弹幕舞台
		 **/
		public function get clip():Sprite {
			return _clip;
		}
		
		/**
		 * 返回弹幕输入框
		 **/
		public function get input():CommentInput {
			return _input;
		}
		
		/** 插件版本号 **/
		public function get version():String {
			return _version;
		}
		
		/**
		 * 插件版本号
		 */
		public function set version(value:String):void {
			_version = value;
		}
		
		/** 简化的视频的播放器态,播放或静止 **/
		public function get isPlaying():Boolean {
			return _isPlaying;
		}
		public function set isPlaying(value:Boolean):void {
			_isPlaying = value;
		}
	}
}