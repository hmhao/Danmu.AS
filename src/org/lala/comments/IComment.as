package org.lala.comments
{
    /** 弹幕类接口:实现必须是flash.display.DisplayObject子孙
    * @author aristotle9
    */
    public interface IComment
    {
      function start():void;
      function pause():void;
      function resume():void;
	  function stop():void;
	  function clear():void;
	  function vote():void;
      function set complete(foo:Function):void;
    }
}