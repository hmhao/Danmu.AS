package {
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import org.lala.net.CommentServer;
	import org.lala.plugins.CommentView;
	import org.lala.plugins.CommentButton;
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
		/** 弹幕开关按钮 **/
		private var commentButton:CommentButton;
		/** 服务器端配置 **/
		private var conf:CommentXMLConfig;
		/** 弹幕报务器接口 **/
		private var server:CommentServer;
		/** 状态文本**/
		private var status:TextField;
		
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
			commentButton = new CommentButton();
			commentButton.x = stage.stageWidth - commentButton.width;
			commentButton.y = stage.stageHeight - commentButton.height;
			this.addChild(commentButton);
			commentView.initPlugin();
			commentView.resize(stage.stageWidth, stage.stageHeight);
			commentView.showComments(commentButton.isOn);
			playerTool.loadCmtFile("danmu2.json");
			
			status = new TextField();
			status.autoSize = "left";
			status.textColor = 0xFFFFFF;
			status.text = "play";
			status.x = 0;
			status.y = stage.stageHeight - status.height;
			this.addChild(status);
			
			commentButton.addEventListener(MouseEvent.CLICK, onCommentButtonClick);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			onResize(null);
		}
		
		private function onResize(evt:Event):void {
			commentView.resize(stage.stageWidth, stage.stageHeight-80);
		}
		
		private function onMouseClick(evt:MouseEvent):void {
			if(evt.target == evt.currentTarget){
				commentView.isPlaying = !commentView.isPlaying;
				status.text = commentView.isPlaying ? "play" : "pause";
			}
		}
		
		private function onCommentButtonClick(evt:MouseEvent):void {
			commentButton.isOn = !commentButton.isOn;
			commentView.showComments(commentButton.isOn);
		}
	}
}