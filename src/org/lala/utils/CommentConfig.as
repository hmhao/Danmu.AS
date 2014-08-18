package org.lala.utils
{
    import com.adobe.serialization.json.JSON;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.net.SharedObject;

    /** 配置,主要是外观的配置,存储在本地SharedObject中 **/
    public class CommentConfig extends EventDispatcher
    {
        private static var instance:CommentConfig;
        
        /** 是否应用到界面字体 **/
        private var _isChangeUIFont:Boolean = false;
        /** 是否启用播放器控制API **/
        private var _isPlayerControlApiEnable:Boolean = true;
		/** 字体 **/
        private var _font:String = '黑体';
		/** 是否显示弹幕,没有存储到本地 **/
        public var visible:Boolean=true;
        /** 粗体 **/
        public var bold:Boolean = true;
		/** 颜色 **/
        public var color:uint=0xFFFFFF;
        /** 透明度:0-1 **/
        public var alpha:Number=1;
        /** 滤镜:0-2 **/
        public var filterIndex:int = 0;
		/** 滤镜效果 **/
        public var filtersArr:Array;
        /** 速度因子:0.1-2 **/
        public var speede:Number = 1.2;
        /** 字号缩放因子:0.1-2 **/
        public var sizee:Number = 1;
        
        private var _width:int = 970;
        private var _height:int = 540;
        
        /** 宽度 **/
        public function get width():int
        {
            return _width;
        }
        /** 高度 **/
        public function get height():int
        {
            return _height;
        }

        public function CommentConfig()
        {
            if(instance != null)
            {
                throw new Error("CommentConfig is a singleton");
            }
			filtersArr = [
				{label:"细边",data:[new GlowFilter(0, 0.7, 3,3)]},
				{label:"浅影",data:[new DropShadowFilter(2, 45, 0, 0.6)]},
				{label:"深影",data:[new GlowFilter(0, 0.85, 4, 4, 3, 1, false, false)]}
			];
			
			/*filtersArr = [
				{label: "重墨", black: [new GlowFilter(0, 0.85, 4, 4, 3, 1, false, false)], 
								white: [new GlowFilter(16777215, 0.9, 3, 3, 4, 1, false, false)] }, 
				{label: "描边", black: [new GlowFilter(0, 0.7, 3, 3, 2, 1, false, false)], 
								white: [new GlowFilter(16777215, 0.7, 3, 3, 2, 1, false, false)] }, 
				{label: "45°投影", black: [new DropShadowFilter(1, 45, 0, 0.8, 2, 2, 2)], 
								white: [new DropShadowFilter(1, 45, 16777215, 0.8, 2, 2, 2)]}];
			*/
			reset();
            load();
        }
        
        public static function getInstance():CommentConfig
        {
            if(instance == null)
            {
                instance = new CommentConfig();
            }
            return instance;
        }
        
        public function reset():void
        {
            bold = true;
            alpha = 1;
            filterIndex = 0;
            speede = 1;
            sizee = 1;
            font = ApplicationConstants.getDefaultFont();
            isChangeUIFont = ApplicationConstants.doesChangeUIFont();
            isPlayerControlApiEnable = true;
        }
        
        override public function toString():String
        {
            var a:Array = [];
            a.push(bold,alpha,filterIndex,speede,sizee,font,isChangeUIFont,isPlayerControlApiEnable);
            return JSON.encode(a);
        }
        
        public function fromString(source:String):void
        {
            try
            {
                var a:Array = JSON.decode(source) as Array;
                bold = a[0];
                alpha = a[1];
                filterIndex = a[2];
                speede = a[3];
                sizee = a[4];
                font = a[5];
                isChangeUIFont = a[6];
                isPlayerControlApiEnable = a[7];
            }
            catch(e:Error){}
            if(speede <= 0)
            {
                speede = 0.1;
            }
            if(sizee <= 0)
            {
                sizee = 0.1;
            }
        }
        
        public function load():void
        {
            try
            {
                var so:SharedObject = SharedObject.getLocal('MukioPlayer','/');
                var str:String = so.data['CommentConfig'];
                if(str)
                {
                    fromString(str);
                }
            }
            catch(e:Error){}
        }
        
        public function save():void
        {
            try
            {
                var so:SharedObject = SharedObject.getLocal('MukioPlayer','/');
                so.data['CommentConfig'] = toString();
                so.flush();
            }
            catch(e:Error){}
        }
        
        public function get filter():Array
        {
            return filtersArr[filterIndex].data;
        }

        /** 是否让界面使用弹幕字体?,在非中文系统中可以解决
         * Spark组件不能显示汉字的问题 **/
        public function get isChangeUIFont():Boolean
        {
            return _isChangeUIFont;
        }

        /**
         * @private
         */
        public function set isChangeUIFont(value:Boolean):void
        {
            _isChangeUIFont = value;
        }
		
        public function get font():String
        {
            return _font;
        }

        public function set font(value:String):void
        {
            _font = value;
            dispatchEvent(new Event('fontChange'));
        }

        /** 是否启用播放器控制API **/
        public function get isPlayerControlApiEnable():Boolean
        {
            return _isPlayerControlApiEnable;
        }

        /**
         * @private
         */
        public function set isPlayerControlApiEnable(value:Boolean):void
        {
            _isPlayerControlApiEnable = value;
            dispatchEvent(new Event('playerControlApiEnableChange'));
        }
    }
}