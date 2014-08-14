package org.lala.plugins {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.lala.comments.*;
	import org.lala.net.*;
	import org.lala.utils.*;
	
	/**
	 * 纯JWPlayer v5.x的弹幕播放插件:
	 * 只实现弹幕的加载与播放,无发送界面与功能,无过滤器设置界面与功能
	 * @author aristotle9
	 **/ /** 内全屏按下 **/
	[Event(name='innerFullScreen',type='flash.events.Event')]
	
	public class CommentView extends Sprite{		
		/** 弹幕来源,只有唯一一个实例 **/
		private var _provider:CommentProvider;
		/** 弹幕过滤器,只有唯一一个实例 **/
		private var _filter:CommentFilter;
		/** 弹幕管理者 **/
		private var managers:Vector.<CommentManager>;
		/** 弹幕层,类本身是插件层,但是位置不符合弹幕的需求,所以另起一层 **/
		private var _clip:Sprite;
		/** singleton **/
		private static var instance:CommentView;
		/** 时间点 **/
		private var _stime:Number = 0;
		/** 普通弹幕配置 **/
		private var cmtConfig:CommentConfig = CommentConfig.getInstance();
		/** 插件的版本号,非JW播放器 **/
		private var _version:String;
		/** 简化的视频的播放器态,播放或静止 **/
		private var _isPlaying:Boolean = false;
		
		public function CommentView() {
			if (instance != null) {
				throw new Error("class CommentView is a Singleton,please use getInstance()");
			}
			/** 不接收点击事件 **/
			this.mouseEnabled = this.mouseChildren = false;
			_clip = new Sprite();
			_clip.name = 'commentviewlayer';
			_clip.mouseEnabled = _clip.mouseChildren = false;
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
			
			/** 设置播放状态的初值 **/
			_isPlaying = true;
		}
		
		/** 状态改变事件监听器,监听暂停或者播放 **/
		/*private function stateHandler(event:PlayerStateEvent):void {
			var i:int;
			var c:DisplayObject;
			if ((event.newstate == 'PLAYING' && event.oldstate != 'BUFFERING') || (event.newstate == 'BUFFERING' && event.oldstate != 'PLAYING')) {
				for (i = 0; i < _clip.numChildren; i++) {
					c = _clip.getChildAt(i);
					if (c is IComment) {
						IComment(c).resume();
					}
				}
				_isPlaying = true;
			} else if ((event.oldstate == 'PLAYING' && event.newstate != 'BUFFERING') || (event.oldstate == 'BUFFERING' && event.newstate != 'PLAYING')) {
				for (i = 0; i < _clip.numChildren; i++) {
					c = _clip.getChildAt(i);
					if (c is IComment) {
						IComment(c).pause();
					}
				}
				_isPlaying = false;
			}
		}*/
		
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
			_clip.scaleY = _clip.scaleX = r;
			_clip.x = (w - cmtConfig.width * r) / 2;
			_clip.y = (h - cmtConfig.height * r) / 2;
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
		/*private function timeHandler(event:MediaEvent):void {
			if (cmtConfig.visible == false) {
				return;
			}
			_stime = event.position;
			for each (var manager:CommentManager in managers) {
				manager.time(event.position);
			}
		}*/
		
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
			return _isPlaying || true;
		}
	
	}
}