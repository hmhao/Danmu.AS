package {
	import flash.events.MouseEvent;
	import org.lala.net.CommentServer;
	import org.lala.plugins.CommentView;
	import org.lala.utils.CommentConfig;
	import org.lala.utils.CommentDataParser;
	import org.lala.utils.CommentXMLConfig;
	import org.lala.utils.PlayerTool;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	
	public class MukioPlayerPlus extends Sprite {
		/** 播放器小助手 **/
		private var playerTool:PlayerTool;
		/** 弹幕播放器插件类的引用 **/
		private var commentView:CommentView = CommentView.getInstance();
		/** 服务器端配置 **/
		private var conf:CommentXMLConfig;
		/** 弹幕报务器接口 **/
		private var server:CommentServer;
		
		public function MukioPlayerPlus() {
			this.addEventListener(Event.ADDED_TO_STAGE, playerReadyHandler);
		}
		
		private function playerReadyHandler(evt:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			playerTool = new PlayerTool();
			//conf = new CommentXMLConfig(root);
			server = new CommentServer();
			
			this.addChild(commentView);
			commentView.initPlugin();
			commentView.resize(stage.stageWidth, stage.stageHeight);
			playerTool.loadCmtFile("2093520.xml");
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onResize(evt:Event):void {
			commentView.resize(stage.stageWidth, stage.stageHeight);
		}
		
		private function onClick(evt:MouseEvent):void {
			CommentView.getInstance().isPlaying = !CommentView.getInstance().isPlaying;
		}
	}
}