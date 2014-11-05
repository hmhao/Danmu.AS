package org.lala.comments 
{
	import com.worlize.gif.GIFPlayer;
	import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.filters.*;
	import flash.net.URLRequest;
    import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
    import flash.utils.Timer;
	
    import org.lala.utils.CommentConfig;
	import org.lala.net.EmoticonProvider;
    
    /**
     * Comment类,定义了弹幕的生命周期内各种动作:本身为基本字幕
     * 弹幕在舞台的起始与终结
     * @author aristotle9
     */
    public class Comment extends Sprite implements IComment
    {
        /** 完成地调用的函数,无参数 **/
        protected var _complete:Function;
        /** 配置数据 **/
        protected var item:Object;
        /** 空间分配索引,记录所占用的弹幕空间层 **/
        protected var _index:int;
        /** 底部位置,为减少计算 **/
        protected var _bottom:int;
        /** 时计 **/
        protected var _tm:Timer;
		/** 文本 **/
		protected var _textfield:TextField;
		/** 表情 **/
		protected var _emoticon:GIFPlayer;
        /** 配置 **/
        protected var config:CommentConfig;
        /**
         * 构造方法
         * @param	data 弹幕数据信息
         */
        public function Comment() 
        {
			config = CommentConfig.getInstance();
			_textfield = new TextField();
			_textfield.autoSize = TextFieldAutoSize.LEFT;
			_textfield.selectable = false;
			_textfield.borderColor = 0x66FFFF;
            _textfield.filters = config.filter;
			_emoticon = new GIFPlayer();
			addChild(_textfield);
			addChild(_emoticon);
        }
		
        /**
        * 设置空间索引和y坐标
        **/
        public function setY(py:int,idx:int,trans:Function):void
        {
            this.y = trans(py,this);
            this._index = idx;
            this._bottom = py + this.height;
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
        /**
        * 底部位置,在空间检验时用到
        **/
        public function get bottom():int
        {
            return this._bottom;
        }
        /**
        * 右边位置
        **/
        public function get right():int
        {
            return this.x + this.width;
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
            _textfield.defaultTextFormat = new TextFormat(config.font, config.sizee * item.size, item.color, config.bold);
            _textfield.alpha = config.alpha;
            _textfield.text = item.text;
            _textfield.border = item.border;
			var emo:EmoticonProvider = EmoticonProvider.getInstance();
			_emoticon.load(emo.getEmoticon(emo.gifData[Math.floor(Math.random()*emo.gifData.length)].name));
			_emoticon.x = _textfield.x + _textfield.width;
        }
        /**
         * 恢复播放
         */
        public function resume():void
        {
            this._tm.start();
        }
        /**
         * 暂停
         */
        public function pause():void
        {
            this._tm.stop();
        }
        /**
         * 开始播放
         */
        public function start():void
        {
            this._tm = new Timer(250,10);
            this._tm.addEventListener(TimerEvent.TIMER_COMPLETE,completeHandler);
            this._tm.start();
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
		
		public function stop():void {
			this._tm.stop();
			this.completeHandler(null);
		}
		
    }
}