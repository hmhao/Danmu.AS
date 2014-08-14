package {
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.utils.Strings;
	
	import org.lala.event.EventBus;
	import org.lala.event.MukioEvent;
	import org.lala.net.CommentServer;
	import org.lala.plugins.CommentView;
	import org.lala.scriptapis.ScriptDisplayer;
	import org.lala.scriptapis.ScriptPlayer;
	import org.lala.scriptapis.ScriptTool;
	import org.lala.utils.AppConfig;
	import org.lala.utils.CommentConfig;
	import org.lala.utils.CommentDataParser;
	import org.lala.utils.CommentXMLConfig;
	import org.lala.utils.MukioTaskQueue;
	import org.lala.utils.PlayerTool;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	
	public class MukioPlayerPlus extends Sprite {
		private var currentState:String = 'normal';
		private var savedState:String = 'normal';
		private var isInnerFullScreenState:Boolean = false;
		private var player:Player;
		/** 播放器小助手 **/
		private var playerTool:PlayerTool;
		/** 弹幕播放器插件类的引用 **/
		private var commentView:CommentView = CommentView.getInstance();
		/** 服务器端配置 **/
		private var conf:CommentXMLConfig;
		/** 弹幕报务器接口 **/
		private var server:CommentServer;
		/** 应用程序配置 **/
		private var appConfig:AppConfig;
		
		public function MukioPlayerPlus() {
			this.addEventListener(Event.ADDED_TO_STAGE, application1_addedToStageHandler);
		}
		
		/**
		 * 播放器的初始化完成
		 * JWPlayer初始化过程复杂(略去),在这个事件里表示JWPlayer的各部件已经可以使用了
		 * 接下来是用播放器播放视频和让插件加载弹幕
		 * 弹幕的输入和发送类随着界面的建成而实例化
		 * flash参数的说明:
		 * 可以按照标准的JWPlayer嵌入方法来写html参数
		 * SinaMediaProvider是个多段视频提供者.具体使用参见模型测试的代码案例
		 * JWPlayer会自动在playerReady事件之前使用该参数初始化
		 * 可以在playerReady事件中重新定向播放
		 **/
		private function playerReadyHandler(event:Event):void {
			log('播放器初始化完成.');
			player = new Player();
			this.addChild(player);
			playerTool = new PlayerTool(player);
			conf = new CommentXMLConfig(root);
			this.addChild(commentView);
			commentView.initPlugin(player, player.config.pluginConfig(player.config.id));
			player.stop();
			//playerContainer.enabled = false;
			
			var tasks:MukioTaskQueue = new MukioTaskQueue();
			tasks.addEventListener(Event.COMPLETE, tasksCompleteHandler);
			tasks.beginLoad(conf.getConfURL(), confLoaded);
			// ...
			log('开始加载XML配置.');
			tasks.work();
		}
		
		/** 加载配置xml处理函数 **/
		private function confLoaded(data:*):void {
			log("配置加载成功.");
			conf.init(new XML(data));
			server.conf = conf;
		}
		
		/** 初始化脚本引擎 **/
		private function initialScriptEngine():void {
			//接口
			var scriptPlayer:ScriptPlayer = new ScriptPlayer(player);
			var scriptDisplayer:ScriptDisplayer = new ScriptDisplayer();
			var scriptTool:ScriptTool = new ScriptTool();
			var p:Function = function(s:*):void {
				EventBus.getInstance().log(String(s));
			}
			/*MukioEngine.log = p;
			//为引擎添加一些全局变量,为弹幕脚本的API
			MukioEngine.setParam('Player', scriptPlayer);
			MukioEngine.setParam('Display', scriptDisplayer);
			MukioEngine.setParam('D', scriptDisplayer);
			MukioEngine.setParam('Toolkit', scriptTool);
			MukioEngine.setParam('T', scriptTool);
			MukioEngine.setParam('p', p);
			MukioEngine.setParam('print', p);*/
			//                MukioEngine.setParam('alert',function(s:*):void{Alert.show(String(s),'alert:');});
			log("脚本引擎初始化完成.");
		
		}
		
		private function tasksCompleteHandler(event:Event):void {
			log("加载工作结束.");
			if (!conf.initialized) {
				log("配置加载失败.");
			} else {
				initialScriptEngine();
				log("处理播放参数.");
				routeAndPlay();
				//playerContainer.enabled = true;
			}
		}
		
		private function log(content:String):void {
			EventBus.getInstance().log(content);
		}
		
		private function routeAndPlay():void {
			//var params:Object = this.loaderInfo.parameters;
			var params:Object = {type:"video",file:"E:\\123.mp4",cfile:"2093520.xml"};
			if (params.h || conf.isOnHost) {
				/** 有h参数时,转向自定义路由 **/
				log("使用自带的参数处理方案.");
				routeHost(params);
			} else {
				log("使用A/B站的参数处理方案.");
				routeTest(params);
			}
		}
		
		/** flash参数路由测试,使用两站参数 **/
		private function routeTest(params:Object):void {
			var bid:String = '';
			if (params['qid']) {
				playerTool.loadQqVideo(params['qid']);
				bid = params['qid'];
			} else if (params['vid']) {
				playerTool.loadSinaVideo(params['vid']);
				bid = params['vid'];
			} else if (params['ykid']) {
				playerTool.loadYoukuVideo(params['ykid']);
				bid = params['ykid'];
			} else if (params['tdid']) {
				playerTool.loadTuDouVideo(params['tdid']);
				bid = params['tdid'];
			} else if (params['id'] && params['file']) {
				playerTool.loadSingleFile(params['file']);
				bid = params['id'];
			}
			
			if (bid != '') {
				playerTool.loadBiliFile(bid);
				server.cid = bid;
				return;
			}
			
			if (params['id']) {
				if (params['type2']) {
					if (params['type2'] == 'qq') {
						playerTool.loadQqVideo(params['id']);
					} else if (params['type2'] == 'youku') {
						playerTool.loadYoukuVideo(params['id']);
					} else if (params['type2'] == 'tudou') {
						playerTool.loadTuDouVideo(params['id']);
					}
				} else {
					playerTool.loadSinaVideo(params['id']);
				}
				if (params['cid']) {
					playerTool.loadAcfunFile(params['cid']);
					server.cid = params['cid'];
				} else {
					playerTool.loadAcfunFile(params['id']);
					server.cid = params['id'];
				}
			}
		}
		
		/** 自己服务器上的路由,考虑参数兼容性 **/
		private function routeHost(params:Object):void {
			var config:Object = params;
			var cmtItem:Object = {cid: null, cfile: null};
			if (config.type == 'video' || config.type == null) {
				if (config.type2) {
					config.type = config.type2;
				}
			}
			//至此type2不用考虑,但是type有可能是null
			if (config.file == null && (config.id != null || config.vid != null) && (config.type == 'video' || config.type == null)) {
				config.type = 'sina';
			}
			if (config.type != null && config.type != 'video') {
				if (config.vid == null && config.id != null) {
					config.vid = config.id;
				}
			}
			//至此sina不用考虑
			if (config.vid != null) {
				cmtItem.cid = config.vid;
			}
			if (config.id != null) {
				cmtItem.cid = config.id;
			}
			if (config.cid != null) {
				cmtItem.cid = config.cid;
			}
			//cid 转换完成
			if (config.cfile) {
				cmtItem.cfile = config.cfile;
			}
			//开始加载弹幕
			//用于amf
			server.cid = cmtItem.cid;
			/** 用户标识可以使用user值传入 **/
			if (config.user) {
				server.user = config.user;
			}
			//配置在路由时已近加载完成
			if (cmtItem.cfile) {
				playerTool.loadCmtFile(cmtItem.cfile);
			} else if (String(conf.gateway).length) {
				playerTool.loadCmtData(server);
			} else if (cmtItem.cid) {
				playerTool.loadCmtFile(conf.getCommentFileURL(cmtItem.cid));
			} else {
				log('弹幕无法加载,参数有误.');
			}
			//弹幕加载完成
			//开始加载视频
			//sina qq youku video tudou 类型在此处处理
			var typeArray:Array = "sina qq youku video tudou".split(' ');
			if (typeArray.indexOf(config.type) == -1) {
				if (config.file) {
					if (config.type)
						player.load({'type': config.type, 'file': config.file});
					else
						player.load({'file': config.file});
				} else {
					log('视频无法加载,参数有误.');
				}
					//注意,对于无后缀的情况不能处理,直接出错
			} else {
				switch (config.type) {
					case 'video': 
						playerTool.loadSingleFile(config.file);
						break;
					case 'qq': 
						playerTool.loadQqVideo(config.vid);
						break;
					case 'youku': 
						playerTool.loadYoukuVideo(config.vid);
						break;
					case 'tudou': 
						playerTool.loadTuDouVideo(config.vid);
						break;
					case 'sina': 
						playerTool.loadSinaVideo(config.vid);
						break;
				}
			}
			//视频加载完毕
		}
		
		/** 应用程序初始化 **/
		private function application1_applicationCompleteHandler(event:FlexEvent):void {
			currentState = appConfig.state;
			
			commentView.addEventListener("innerFullScreen", innerFullScreenHandler);
			commentView.version = "1.0";
			server = new CommentServer();
			/** 全屏情况处理,更改state **/
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			log('应用程序初始化完成,等待播放器初始化.');
		}
		
		/** 处理播放器的工具条上的隐藏弹幕界面按钮事件 **/
		private function innerFullScreenHandler(event:Event):void {
			if (stage.displayState == 'fullScreen') {
				return;
			}
			if (!isInnerFullScreenState) {
				savedState = currentState;
				currentState = 'fullScreen';
			} else {
				currentState = savedState;
			}
			isInnerFullScreenState = !isInnerFullScreenState;
		}
		
		/**
		 * 全屏处理:fullScreen状态是播放器填满整个flash插件,全屏则是flash插件填满屏幕
		 * 其实是两个不同的状态,但是共用一个state,而使用isInnerFullScreenState来区分
		 ***/
		private function fullScreenHandler(event:FullScreenEvent):void {
			if (isInnerFullScreenState) {
				return;
			}
			if (stage.displayState == 'fullScreen') {
				savedState = currentState;
				currentState = 'fullScreen';
			} else {
				currentState = savedState;
			}
		}
		
		/** 在状态改变后保存状态配置,如果配置实例存在的话 **/
		/*private function application1_currentStateChangeHandler(event:StateChangeEvent):void {
			if (appConfig) {
				appConfig.state = currentState;
			}
		}*/
		
		/** 在loadInfo可读取时立即初始化配置 **/
		protected function application1_addedToStageHandler(event:Event):void {
			appConfig = new AppConfig(loaderInfo.parameters);
			/** 初始化到无界面状态 **/
			if (appConfig.state == 'fullScreen') {
				isInnerFullScreenState = true;
			}
			application1_applicationCompleteHandler(null)
			playerReadyHandler(null);
		}
		
		/**
		 * 是否显示弹幕
		 **/
		protected function visibleButtonHandler(event:Event):void {
			var cmtConfig:CommentConfig = CommentConfig.getInstance();
			var _clip:Sprite = commentView.clip;
			var _visibleButtonIcon:DisplayObject = new Sprite();
			
			if (cmtConfig.visible != false) {
				cmtConfig.visible = false;
				_clip.visible = false;
				_visibleButtonIcon.alpha = .5;
			} else {
				cmtConfig.visible = true;
				_clip.visible = true;
				_visibleButtonIcon.alpha = 1;
			}
		}
	
	}

}