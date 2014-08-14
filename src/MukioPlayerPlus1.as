<?xml version="1.0" encoding="utf-8"?>
<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009" 
               xmlns:s="library://ns.adobe.com/flex/spark" 
               xmlns:mx="library://ns.adobe.com/flex/mx"
               xmlns:jw="com.longtailvideo.jwplayer.player.*"
               xmlns:mk="org.lala.components.*" applicationComplete="application1_applicationCompleteHandler(event)" backgroundColor.fullScreen="#000000" backgroundColor.normal="#FFFFFF" height.normal="100%" width.normal="100%" backgroundColor.wideScreen="#FFFFFF" height.wideScreen="100%" width.wideScreen="100%" currentStateChange="application1_currentStateChangeHandler(event)" addedToStage="application1_addedToStageHandler(event)">
    <fx:Style source="MukioPlayerPlus.css"/>
    <s:states>
        <s:State name="normal"/>
        <s:State name="fullScreen"/>
        <s:State name="wideScreen"/>
    </s:states>
    <fx:Metadata>
        [SWF(backgroundColor="0x0", width="950", height="445")]
    </fx:Metadata>
    <fx:Declarations>
        <fx:String id='version'>2.000</fx:String>
        <fx:Array id="cmtColumns">
            <mx:DataGridColumn headerText="时间" dataField="stime" width="45" labelFunction="digit"/>
            <mx:DataGridColumn headerText="评论({commentView.provider.commentResource.length}条)" dataField="text"  minWidth="150" minWidth.wideScreen="110" labelFunction="textTrim"/>
            <mx:DataGridColumn dataField="date" headerText="发送日期" includeIn="normal" width="130"/>
        </fx:Array>
    </fx:Declarations>
    <fx:Script>
        <![CDATA[
            import com.longtailvideo.jwplayer.player.Player;
            import com.longtailvideo.jwplayer.utils.Strings;
            
            import mx.controls.Alert;
            import mx.events.FlexEvent;
            import mx.events.ResizeEvent;
            import mx.events.StateChangeEvent;
            import mx.utils.ObjectUtil;
            
            import org.lala.components.skins.IconButtonSkin;
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
            
            private var savedState:String = 'normal';
            private var isInnerFullScreenState:Boolean = false;
            private var player:Player;
            /** 播放器小助手 **/
            private var playerTool:PlayerTool;
            [Bindable]
            /** 弹幕播放器插件类的引用 **/
            private var commentView:CommentView = CommentView.getInstance();
            /** 服务器端配置 **/
            private var conf:CommentXMLConfig;
            /** 弹幕报务器接口 **/
            private var server:CommentServer;
            /** 应用程序配置 **/
            private var appConfig:AppConfig;
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
            private function playerReadyHandler(event:Event):void
            {
                log('播放器初始化完成.');
                player = playerContainer.player;
                playerTool = new PlayerTool(player);
                conf = new CommentXMLConfig(root);
                
                player.stop();
                playerContainer.enabled = false;

                var tasks:MukioTaskQueue = new MukioTaskQueue();
                tasks.addEventListener(Event.COMPLETE,tasksCompleteHandler);
                tasks.beginLoad(conf.getConfURL(),confLoaded);
                // ...
                log('开始加载XML配置.');
                tasks.work();
            }
            /** 加载配置xml处理函数 **/
            private function confLoaded(data:*):void
            {
                log("配置加载成功.");
                conf.init(new XML(data));
                server.conf = conf;
            }
            /** 初始化脚本引擎 **/
            private function initialScriptEngine():void
            {
                //接口
                var scriptPlayer:ScriptPlayer = new ScriptPlayer(player);
                var scriptDisplayer:ScriptDisplayer = new ScriptDisplayer();
                var scriptTool:ScriptTool = new ScriptTool();
                var p:Function = function(s:*):void
                {
                    EventBus.getInstance().log(String(s));
                }
                /*MukioEngine.log = p;
                //为引擎添加一些全局变量,为弹幕脚本的API
                MukioEngine.setParam('Player',scriptPlayer);
                MukioEngine.setParam('Display',scriptDisplayer);
                MukioEngine.setParam('D',scriptDisplayer);
                MukioEngine.setParam('Toolkit',scriptTool);
                MukioEngine.setParam('T',scriptTool);
                MukioEngine.setParam('p',p);
                MukioEngine.setParam('print',p);*/
//                MukioEngine.setParam('alert',function(s:*):void{Alert.show(String(s),'alert:');});
                log("脚本引擎初始化完成.");
                
            }
            private function tasksCompleteHandler(event:Event):void
            {
                log("加载工作结束.");
                if(!conf.initialized)
                {
                    log("配置加载失败.");
                }
                else
                {
                    initialScriptEngine();                
                    log("处理播放参数.");
                    routeAndPlay();
                    playerContainer.enabled = true;
                }
            }
            private function log(content:String):void
            {
                EventBus.getInstance().log(content);
            }
            private function routeAndPlay():void
            {
                var params:Object = systemManager.loaderInfo.parameters;
                if(params.h || conf.isOnHost)
                {
                    /** 有h参数时,转向自定义路由 **/
                    log("使用自带的参数处理方案.");
                    routeHost(params);
                }
                else
                {
                    log("使用A/B站的参数处理方案.");
                    routeTest(params);
                }
            }
            /** flash参数路由测试,使用两站参数 **/
            private function routeTest(params:Object):void
            {
                var bid:String = '';
                if(params['qid'])
                {
                    playerTool.loadQqVideo(params['qid']);
                    bid = params['qid'];
                }
                else if(params['vid'])
                {
                    playerTool.loadSinaVideo(params['vid']);
                    bid = params['vid'];
                }
                else if(params['ykid'])
                {
                    playerTool.loadYoukuVideo(params['ykid']);
                    bid = params['ykid'];
                }
                else if(params['tdid'])
                {
                    playerTool.loadTuDouVideo(params['tdid']);
                    bid = params['tdid'];
                }
                else if(params['id'] && params['file'])
                {
                    playerTool.loadSingleFile(params['file']);
                    bid = params['id'];
                }
                
                if(bid != '')
                {
                    playerTool.loadBiliFile(bid);
                    server.cid = bid;
                    return;
                }
                
                if(params['id'])
                {
                    if(params['type2'])
                    {
                        if(params['type2'] == 'qq')
                        {
                            playerTool.loadQqVideo(params['id']);
                        }
                        else if(params['type2'] == 'youku')
                        {
                            playerTool.loadYoukuVideo(params['id']);
                        }
                        else if(params['type2'] == 'tudou')
                        {
                            playerTool.loadTuDouVideo(params['id']);
                        }
                    }
                    else
                    {
                        playerTool.loadSinaVideo(params['id']);
                    }
                    if(params['cid'])
                    {
                        playerTool.loadAcfunFile(params['cid']);
                        server.cid = params['cid'];
                    }
                    else
                    {
                        playerTool.loadAcfunFile(params['id']);
                        server.cid = params['id'];
                    }
                }
            }
            /** 自己服务器上的路由,考虑参数兼容性 **/
            private function routeHost(params:Object):void
            {
                var config:Object = ObjectUtil.copy(params);
                var cmtItem:Object = {
                    cid:null,
                    cfile:null
                };
                if(config.type == 'video' || config.type == null)
                {
                    if(config.type2)
                    {
                        config.type = config.type2;
                    }
                }
                //至此type2不用考虑,但是type有可能是null
                if(config.file == null 
                    && (config.id != null || config.vid !=null)
                    && (config.type == 'video' || config.type == null))
                {
                    config.type = 'sina';
                }
                if(config.type != null && config.type != 'video')
                {
                    if(config.vid == null && config.id != null)
                    {
                        config.vid = config.id;
                    }
                }
                //至此sina不用考虑
                if(config.vid != null)
                {
                    cmtItem.cid = config.vid;
                }
                if(config.id != null)
                {
                    cmtItem.cid = config.id;
                }
                if(config.cid != null)
                {
                    cmtItem.cid = config.cid;
                }
                //cid 转换完成
                if(config.cfile)
                {
                    cmtItem.cfile = config.cfile;
                }
                //开始加载弹幕
                //用于amf
                server.cid = cmtItem.cid;
                /** 用户标识可以使用user值传入 **/
                if(config.user)
                {
                    server.user = config.user;
                }
                //配置在路由时已近加载完成
                if(cmtItem.cfile)
                {
                    playerTool.loadCmtFile(cmtItem.cfile);
                }
                else if(String(conf.gateway).length)
                {
                    playerTool.loadCmtData(server);  
                }
                else if(cmtItem.cid)
                {
                    playerTool.loadCmtFile(conf.getCommentFileURL(cmtItem.cid));
                }
                else
                {
                    log('弹幕无法加载,参数有误.');
                }
                //弹幕加载完成
                //开始加载视频
                //sina qq youku video tudou 类型在此处处理
                var typeArray:Array = "sina qq youku video tudou".split(' ');
                if(typeArray.indexOf(config.type) == -1)
                {
                    if(config.file)
                    {   
                        if(config.type)
                            player.load({'type':config.type,'file':config.file});
                        else
                            player.load({'file':config.file});
                    }
                    else
                    {
                        log('视频无法加载,参数有误.');
                    }
                    //注意,对于无后缀的情况不能处理,直接出错
                }
                else
                {
                    switch(config.type)
                    {
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
            private function application1_applicationCompleteHandler(event:FlexEvent):void
            {
                currentState = appConfig.state;
                
                commentView.addEventListener("innerFullScreen",innerFullScreenHandler);
                commentView.version = version;
                server = new CommentServer();
                /** 全屏情况处理,更改state **/
                stage.addEventListener( FullScreenEvent.FULL_SCREEN, fullScreenHandler );
                log('应用程序初始化完成,等待播放器初始化.');
            }
            /** 处理播放器的工具条上的隐藏弹幕界面按钮事件 **/
            private function innerFullScreenHandler(event:Event):void
            {
                if(stage.displayState == 'fullScreen')
                {
                    return;
                }
                if(!isInnerFullScreenState)
                {
                    savedState = currentState;
                    currentState = 'fullScreen';
                }
                else
                {
                    currentState = savedState;
                }
                isInnerFullScreenState = !isInnerFullScreenState;
            }
            /** 
             * 全屏处理:fullScreen状态是播放器填满整个flash插件,全屏则是flash插件填满屏幕
             * 其实是两个不同的状态,但是共用一个state,而使用isInnerFullScreenState来区分
             ***/
            private function fullScreenHandler(event:FullScreenEvent):void
            {
                if(isInnerFullScreenState)
                {
                    return;
                }
                if(stage.displayState == 'fullScreen')
                {
                    savedState = currentState;
                    currentState = 'fullScreen';
                }
                else
                {
                    currentState = savedState;
                }
            }
            /** 辅助函数:LabelFunction **/
            private function digit(item:Object, column:DataGridColumn):String
            {
                return Strings.digits(item['stime']);
            }
            /** 辅助函数:LabelFunction **/
            private function textTrim(item:Object, column:DataGridColumn):String
            {
                return CommentDataParser.cut((item['text']));
            }
            /** 在状态改变后保存状态配置,如果配置实例存在的话 **/
            private function application1_currentStateChangeHandler(event:StateChangeEvent):void
            {
                if(appConfig)
                {
                    appConfig.state = currentState;
                }
            }
            /** 在loadInfo可读取时立即初始化配置 **/
            protected function application1_addedToStageHandler(event:Event):void
            {
                appConfig = new AppConfig(loaderInfo.parameters);
                /** 初始化到无界面状态 **/
                if(appConfig.state == 'fullScreen')
                {
                    isInnerFullScreenState = true;
                }
            }
            /**
             * 是否显示弹幕
             **/
            protected function visibleButtonHandler(event:Event):void
            {
                var cmtConfig:CommentConfig = CommentConfig.getInstance();
                var _clip:Sprite = commentView.clip;
                var _visibleButtonIcon:DisplayObject = visibleToggleBt;
                
                if (cmtConfig.visible != false)
                {
                    cmtConfig.visible  = false;
                    _clip.visible = false;
                    _visibleButtonIcon.alpha = .5;
                }
                else
                {
                    cmtConfig.visible  = true;
                    _clip.visible = true;
                    _visibleButtonIcon.alpha = 1;
                }
            }
        ]]>
    </fx:Script>
    <s:Group height.fullScreen="100%" width.fullScreen="100%" bottom.normal="0" left.normal="0" right.normal="0" top.normal="0" bottom.wideScreen="0" left.wideScreen="0" right.wideScreen="0" top.wideScreen="0">
        <s:layout>
            <s:HorizontalLayout gap.normal="0" gap.wideScreen="0"/>
        </s:layout>
        <s:Group height.fullScreen="100%" width.fullScreen="100%" height.normal="100%" width.normal="100%" height.wideScreen="100%" width.wideScreen="100%">
            <s:layout>
                <s:VerticalLayout gap="1" paddingTop="0" paddingBottom="0"/>
            </s:layout>
            <s:BorderContainer backgroundColor="#000000" borderWeight="0" height.normal="100%" width.normal="100%" borderVisible.normal="false" backgroundColor.normal="#000000" borderVisible.fullScreen="false" backgroundColor.wideScreen="#000000" borderVisible.wideScreen="false" height.wideScreen="100%" width.wideScreen="100%" height.fullScreen="100%" width.fullScreen="100%">
                <jw:JWPlayer playerReady="playerReadyHandler(event)" id='playerContainer' top.normal="0" bottom.fullScreen="0" left.fullScreen="0" right.fullScreen="0" top.fullScreen="0" height.normal="100%" width.normal="100%" chromeColor.normal="#E00A0A" left.normal="0" chromeColor.wideScreen="#E00A0A" height.wideScreen="100%" left.wideScreen="0" top.wideScreen="0" width.wideScreen="100%"/>
            </s:BorderContainer>
            <s:HGroup excludeFrom="fullScreen" width="100%" gap="1">
                <mk:NormalCommentInput id="normalCommentInput" width="100%" height="22" />
                <mk:IconButton id="visibleToggleBt" icon="@Embed(source='assets/commentShowIcon.png')" right="0" click="visibleButtonHandler(event)" width="26" height="22" skinClass="org.lala.components.skins.IconButtonSkin"/>
                <mk:IconButton id="wideToggleBt" icon="@Embed(source='assets/wideScreenIcon.png')" right="0" click="currentState=currentState=='wideScreen'?'normal':'wideScreen'" width="26" height="22" skinClass="org.lala.components.skins.IconButtonSkin"/>
            </s:HGroup>
        </s:Group>
        <mx:TabNavigator height="100%" width="100%" tabStyleName="boldStyle" excludeFrom="fullScreen" paddingTop="0" borderVisible="false" width.normal="410" width.wideScreen="166" right="0" top="0">
            <s:NavigatorContent label="弹幕" width="100%" height="100%" icon="@Embed(source='assets/listIcon.png')">
                <mk:CmtDataGrid id="cmtTable" headerStyleName="boldStyle" x="0" y="0" width="100%" height="100%" horizontalScrollPolicy.wideScreen="on" dataProvider="{commentView.provider.commentResource}" columns="{cmtColumns}" />
            </s:NavigatorContent>
            <mx:Accordion label="配置" headerStyleName="boldStyle" icon="@Embed(source='assets/configIcon.png')">
                <s:NavigatorContent label="过滤配置" width="100%" height="100%">
                    <mk:CommentFilterInput id="commentFilterInput" enabled="{currentState=='normal'}"/>
                </s:NavigatorContent>
                <s:NavigatorContent label="弹幕配置" width="100%" height="100%">
                    <mk:CommentConfigInput id="commentConfigInput" enabled="{currentState=='normal'}"/>
                </s:NavigatorContent>
            </mx:Accordion>
            <mx:Accordion label="高级" headerStyleName="boldStyle" icon="@Embed(source='assets/scriptIcon.png')">
                <s:NavigatorContent label="zoome字幕" width="100%" height="100%">
                    <mk:ZoomeCommentInput id="zoomeCommentInput" enabled="{currentState=='normal'}"/>
                </s:NavigatorContent>
                <s:NavigatorContent label="bili字幕" width="100%" height="100%">
                    <mk:FixedPosCommentInput id="fixedPosCommentInput" enabled="{currentState=='normal'}"/>
                </s:NavigatorContent>
                <s:NavigatorContent label="脚本试验" width="100%" height="100%">
                    <mk:ScriptCommentInput id="scriptCommentInput" enabled="{currentState=='normal'}"/>
                </s:NavigatorContent>
            </mx:Accordion>
        </mx:TabNavigator>
    </s:Group>
</s:Application>
