package org.lala.comments 
{
	import com.worlize.gif.GIFPlayer;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.filters.*;
	import flash.net.URLRequest;
    import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
    import flash.utils.Timer;
	
    import org.lala.utils.CommentConfig;
	import org.lala.utils.GeneralFactory;
	import org.lala.net.EmoticonProvider;
    
    /**
     * Comment类,定义了弹幕的生命周期内各种动作:本身为基本字幕
     * 弹幕在舞台的起始与终结
     * @author aristotle9
     */
    public class Comment extends Sprite implements IComment
    {
		/** 文本创建者工厂 所有Comment类共用**/
		protected static var tfFactory:GeneralFactory = new GeneralFactory(TextField,20,20);
		/** 表情创建者工厂 所有Comment类共用**/
		protected static var emFactory:GeneralFactory = new GeneralFactory(GIFPlayer,20,20);
		/** 完成地调用的函数,无参数 **/
        /** 完成地调用的函数,无参数 **/
        protected var _complete:Function;
        /** 配置数据 **/
        protected var item:Object;
        /** 空间分配索引,记录所占用的弹幕空间层 **/
        protected var _index:int;
        /** 宽 **/
		protected var _width:Number;
		/** 高 **/
		protected var _height:Number;
        /** 时计 **/
        protected var _tm:Timer;
		/** 文本样式 **/
		protected var _textFormat:TextFormat;
		/** 文本边框 **/
		protected var _border:Shape;
		/** 文本边框 **/
		protected var _agree:Agree;
        /** 配置 **/
        protected var config:CommentConfig;
		protected var _isPausing:Boolean;
        /**
         * 构造方法
         * @param	data 弹幕数据信息
         */
        public function Comment() 
        {
			config = CommentConfig.getInstance();
			_textFormat = new TextFormat(config.font, null, null, config.bold);
			_border = new Shape();
			_border.visible = false;
			addChild(_border);
			_agree = new Agree();
			addChild(_agree);
			this.mouseChildren = false;
			this.buttonMode = true;
        }
		
        /**
        * 设置空间索引和y坐标
        **/
        public function setY(py:int,idx:int,trans:Function):void
        {
            this.y = trans(py,this);
            this._index = idx;
        }
		/** 
        * 弹幕数据
        **/
		public function set data(item:Object):void 
		{
			this.item = item;
            init();
		}
		public function get data():Object 
		{
			return this.item;
		}
        /** 
        * 空间索引读取,在移除出空间时被空间管理者使用
        **/
        public function get index():int
        {
            return this._index;
        }
		override public function get width():Number 
		{
			return this._width;
		}
		
		override public function get height():Number 
		{
			return this._height;
		}
        /**
        * 底部位置,在空间检验时用到
        **/
        public function get bottom():int
        {
            return this.y + this._height;
        }
        /**
        * 右边位置
        **/
        public function get right():int
        {
            return this.x + this._width;
        }
        /**
        * 开始时间
        **/
        public function get stime():Number
        {
            return this.item['stime'];
        }
        /**
         * 初始化,由构造函数最后调用
         */
        protected function init():void
        {
			if (this.item) {
				this._width = 0;
				this._height = 34;
				this._textFormat.size = config.sizee * this.item.size;
				this._textFormat.color = this.item.color;
				this._textFormat.bold = config.bold;
				var emop:EmoticonProvider = EmoticonProvider.getInstance();
				CONFIG::debug {
					var text:String = this.item.text;
					var randomEmoNum:int = Math.floor(Math.random() * 5);
					var randomEmo:Object;
					for (var j:int = 0, index:int = 0; j < randomEmoNum; j++ ) {
						index = Math.floor(Math.random() * text.length);
						randomEmo = emop.gifData[Math.floor(Math.random() * emop.gifData.length)];
						text = text.replace(text.charAt(index), randomEmo.name);
					}
					this.item.text = text;
				}
				var content:String;
				if (this.item.border) {
					content = "【我】: " + this.item.text;
				} else {
					content = this.item.text;
				}
				var items:Array = this.analyseText(content);
				var emo:Object, item:Object;
				for (var i:int = 0; i < items.length; i++ ) {
					emo = emop.getEmoticon(items[i]);
					if (emo) {
						item = emFactory.getObject();
						(item as GIFPlayer).load(emo);
					}else {
						item = tfFactory.getObject();
						(item as TextField).autoSize = TextFieldAutoSize.LEFT;
						(item as TextField).selectable = false;
						(item as TextField).filters = config.filter;
						(item as TextField).alpha = config.alpha;
						(item as TextField).text = items[i];
						(item as TextField).setTextFormat(_textFormat);
					}
					addChildAt(item as DisplayObject, 0);
					item.x = this._width;
					this._width += (item as DisplayObject).width+1;
					//this._height = Math.max(this._height, (item as DisplayObject).height);
				}
				_agree.num = Math.floor(Math.random() * 20);
				_agree.color = this.item.color;
				_agree.x = this._width;
				this._width += _agree.width+1;
				if (this.item.border) {
					_border.graphics.clear();
					_border.graphics.lineStyle(1, 0x66FFFF);
					_border.graphics.drawRect(0, 0, this._width, this._height);
					_border.graphics.endFill();
					_border.visible = true;
				}else {
					_border.visible = false;
				}
			}
        }
		/** 分析图文 */
		protected function analyseText(text:String):Array {
			var emoRegExp:RegExp = /(\[(?:[^\x00-\xff]|[a-zA-Z]){2}\])/g;//匹配仅包含两个中文或英文的字符
			var aResult:Array = [];
			var lastStart:int = 0;
			for (var result:Object = emoRegExp.exec(text); result; result = emoRegExp.exec(text)) {
				if (result.index > 0 && lastStart != result.index) {
					aResult.push(text.substring(lastStart, result.index));
				}
				aResult.push(result[1]);
				lastStart = emoRegExp.lastIndex;
			}
			if(lastStart != text.length)
				aResult.push(text.substring(lastStart));
			return aResult;
		}
        /**
         * 恢复播放
         */
        public function resume():void
        {
            this._tm.start();
			_isPausing = false;
        }
        /**
         * 暂停
         */
        public function pause():void
        {
            this._tm.stop();
			_isPausing = true;
        }
        /**
         * 开始播放
         */
        public function start():void
        {
            this._tm = new Timer(250,10);
            this._tm.addEventListener(TimerEvent.TIMER_COMPLETE,completeHandler);
            !_isPausing && this._tm.start();
        }
        /**
        * 时计结束事件监听
        */
        private function completeHandler(event:TimerEvent):void
        {
            this._complete();
        }
        /**
         * 设置完成播放时调用的函数,调用一次仅一次
         * @param	foo 完成时调用的函数,无参数
         */
        public function set complete(foo:Function):void
        {
            this._complete = foo;
        }
		/** 停止播放 */
		public function stop():void {
			this._tm.stop();
			_isPausing = false;
			this.completeHandler(null);
		}
		
		/** 清除 */
		public function clear():void {
			var item:Object;
			while (this.numChildren > 2) {
				item = this.removeChildAt(0);
				item is GIFPlayer ? emFactory.putObject(item) : tfFactory.putObject(item);//回收元件
			}
		}
		
		public function vote():void {
			_agree.vote();
		}
    }
}