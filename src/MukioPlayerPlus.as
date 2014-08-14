package {
	import org.lala.net.CommentServer;
	import org.lala.plugins.CommentView;
	import org.lala.utils.CommentConfig;
	import org.lala.utils.CommentDataParser;
	import org.lala.utils.CommentXMLConfig;
	import org.lala.utils.PlayerTool;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
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
		
		private function playerReadyHandler(event:Event):void {
			playerTool = new PlayerTool();
			//conf = new CommentXMLConfig(root);
			server = new CommentServer();
			
			this.addChild(commentView);
			commentView.initPlugin();
			playerTool.loadCmtFile("2093520.xml");
		}
	}
}