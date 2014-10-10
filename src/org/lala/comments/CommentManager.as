package org.lala.comments 
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    import org.lala.event.*;
    import org.lala.net.*;
	import org.lala.filter.*;
    import org.lala.plugins.*;
    import org.lala.utils.*;

    /**
     * CommentManager的基类:本身实现顶端字幕管理
     * 维护了一个时间轴,可以在这个时间轴上添加弹幕
     * 外部通过调用time方法来驱动时间轴
     * 驱动时调用弹幕自身的播放方法
     * play,pause方法用来恢复,暂停已经被驱动了的弹幕的动作,因为即使停止驱动时间轴弹幕动作也可能在播放
     * @author aristotle9
     */
    public class CommentManager
    {
        /** 时间轴,为弹幕数据信息数组,按时间顺序插入 **/
        protected var timeLine:Array = [];
        /** 弹幕舞台 **/
        protected var clip:Sprite;
        /** 弹幕来源 **/
        protected var _provider:CommentProvider = null;
        /** 弹幕过滤器 **/
        protected var _filter:CommentFilter = null;
        /** 弹幕空间管理者 **/
        protected var space_manager:CommentSpaceManager;
		/** 弹幕创建者工厂 **/
		protected var commentFactory:GeneralFactory;
        /** 弹幕模式集,用于监听 **/
        protected var mode_list:Array = [];
        /** 普通弹幕配置类 **/
        protected var config:CommentConfig = CommentConfig.getInstance();
        /** 准备栈 **/
        protected var prepare_stack:Array = [];
        /**
         * 构造函数
         */
        public function CommentManager(clip:Sprite) 
        {
            this.clip = clip;
            this.setSpaceManager();
            this.setModeList();
        }
        /**
        * 设置要监听的模式
        **/
        protected function setModeList():void
        {
            /** 因为本类管理顶部字幕,所以监听TOP消息 **/
            this.mode_list.push(CommentDataEvent.TOP);
        }
        /**
        * 设置空间管理者
        **/
        protected function setSpaceManager():void
        {
            this.space_manager = new CommentSpaceManager();
			this.commentFactory = new GeneralFactory(Comment, 20, 20);
        }
        /**
        * 设置弹幕来源,同时监听好弹幕分发事件
        * @param prd 弹幕来源类实例
        **/
        public function set provider(prd:CommentProvider):void
        {
            var mode:String;
            if(this._provider != null)
            {
                for each(mode in this.mode_list)
                {
                    this._provider.removeEventListener(mode,commentDataHandler);
                }
                this._provider.removeEventListener(CommentDataEvent.CLEAR,clearDataHandler);
            }
            this._provider = prd;
            for each(mode in this.mode_list)
            {
                this._provider.addEventListener(mode,commentDataHandler);
            }
            this._provider.addEventListener(CommentDataEvent.CLEAR,clearDataHandler);
        }
        /**
        * 弹幕分发事件监听器
        **/
        protected function commentDataHandler(event:CommentDataEvent):void
        {
            insert(event.data);
        }
        /**
        * 弹幕清除事件监听器
        **/
        protected function clearDataHandler(event:CommentDataEvent):void
        {
            this.clean();
        }
        /**
        * 设置弹幕过滤器
        * @param flt 弹幕过滤器实例
        **/
        public function set filter(flt:CommentFilter):void
        {
            this._filter = flt;
        }
        /**
         * 清除时间轴上所有弹幕数据
         */
        public function clean():void
        {
            this.timeLine = [];
        }
        /**
         * 暂停在该Manager上的所有弹幕的动作
         */
        public function pause():void
        {
            
        }
        /**
         * 继续播放在该Manager上的所有弹幕的动作
         */
        public function resume():void
        {
            
        }
        /**
         * 在该Manager上添加一个弹幕
         * @param	data 弹幕数据信息
         */
        public function insert(data:Object):void
        {
            /* 拷贝副本 */
            var obj:Object = {on:false};
            for (var key:String in data)
            {
                obj[key] = data[key];
            }
			/* 如果没有颜色,则显示默认颜色*/
			if (!obj.color) 
			{
				obj.color = config.color;
			}
            /* 如果带有边框,则立即呈现播放 */
            if (obj.border) 
            {
                this.start(obj);
            }
            /* 带有preview属性则不插入时间轴 */
            if (obj.preview) 
            {
                return;
            }
            if (timeLine[data.stime] == null) 
			{
				timeLine[data.stime] = [];
			}
			timeLine[data.stime].push(data);
            start_all();
        }
        /**
         * 开始播放一个弹幕
         * @param	data 弹幕数据信息
         */
        protected function start(data:Object):void
        {
            /** 在终结前不再被渲染 **/
            data['on'] = true;
            var cmt:IComment = this.getComment(data);
            var self:CommentManager = CommentManager(this);
            cmt.complete = function():void 
			{
                self.complete(data);
                self.removeFromSpace(cmt);
                clip.removeChild(DisplayObject(cmt));
            };
            this.add2Space(cmt);
			if (Comment(cmt).index > -1)
			{
				/** 添加到舞台 **/
				clip.addChild(DisplayObject(cmt));
				/** 压入准备栈,在所有弹幕准备完成后一同出栈 **/
				prepare_stack.push(cmt);
			}
        }
        /**
        * 空间分配
        **/
        protected function add2Space(cmt:IComment):void
        {
            this.space_manager.add(Comment(cmt));
        }
        /**
        * 空间回收
        **/
        protected function removeFromSpace(cmt:IComment):void
        {
            this.space_manager.remove(Comment(cmt));
			this.commentFactory.putObject(cmt);
        }
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
        protected function getComment(data:Object):IComment
        {
            var cmt:Comment = this.commentFactory.getObject() as Comment;
			cmt.data = data;
			return cmt;
        }
        /**
         * 当一个弹幕完成播放动作时调用
         * @param	data 弹幕数据信息
         */
        protected function complete(data:Object):void
        {
            data['on'] = false;
        }
        /**
         * 更改Manager的宽高参数,这些参数影响了弹幕的位置与大小
         * @param	width 宽度
         * @param	height 高度
         */
        public function resize(width:Number, height:Number):void
        {
            //this.space_manager.setRectangle(config.width,config.height);
            this.space_manager.setRectangle(width,height);
        }
        /**
         * 驱动Manager的时间轴
         * @param	position 时间,单位秒
         */
        public function time(position:Number):void
        {
            position = Math.ceil(position);
			if (this.timeLine[position] && this.timeLine[position].length > 0) 
			{
				for each(var data:Object in this.timeLine[position]) 
				{
					this.start(data);
				}
			}
            //弹出所有准备栈中的可视弹幕实例
            start_all();
        }
        /**
        * 启动弹幕,该方法跟在所有的this.start之后调用
        ***/
        protected function start_all():void
        {
			var cmt:IComment;
			while (prepare_stack.length) 
			{
				cmt = prepare_stack.pop();
				cmt.start();
				/** 暂停时发送的弹幕,在显示后立即暂停 **/
				!CommentView.getInstance().isPlaying && cmt.pause();
			}
        }
        /**
         * 校验函数,决定是否显示该弹幕
         * @param	data 弹幕数据
         * @return true表示允许显示,false表示不允许显示
         */
        protected function validate(data:Object):Boolean
        {
            if (data['on'])
            {
                return false;
            }
            return _filter.validate(data);
        }
        /**
         * 在数组arr中二分搜索
         * @param	arr 搜索的数组
         * @param	a 搜索目标
         * @param	fn 比较函数
         * @return 位置索引
         */
        public static function bsearch(arr:Array, a:*,fn:Function):int
        {
            if (arr.length == 0) 
            {
                return 0;
            }
            if (fn(a, arr[0]) < 0)
            {
                return 0;
            }
            if (fn(a, arr[arr.length - 1]) >= 0)
            {
                return arr.length;
            }
            var low:int = 0;
            var hig:int = arr.length - 1;
            var i:int;
            var count:int = 0;
            while (low <= hig)
            {
                i = Math.floor((low + hig + 1) / 2);
                count++;
                if (fn(a, arr[i - 1]) >= 0 && fn(a, arr[i]) < 0) 
                {
                    return i;
                } else if (fn(a, arr[i - 1]) < 0) 
                {
                    hig = i - 1;
                } else if (fn(a, arr[i]) >= 0) 
                {
                    low = i;
                } else 
                {
                    throw new Error('查找错误.');
                }
                if (count > 1000) {
                    throw new Error('查找超时.');
                    break;
                }
            }
            return -1;
        }
        /**
         * 二分插入
         * @param	arr 插入的数组
         * @param	a 插入对象
         * @param	fn 比较函数
         */
        public static function binsert(arr:Array, a:*, fn:Function):void
        {
            var i:int = bsearch(arr, a, fn);
            arr.splice(i, 0, a);
        }
    }
    
}