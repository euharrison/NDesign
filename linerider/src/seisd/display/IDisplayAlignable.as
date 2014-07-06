package seisd.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Vamoss
	 */
	public interface IDisplayAlignable
	{
		
		/**
		 * Align properties
		 */
		function set xPercent(value:Number):void;
		function get xPercent():Number;
		
		function set yPercent(value:Number):void;
		function get yPercent():Number;
		
		function set left(value:Number):void;
		function get left():Number;
		
		function set right(value:Number):void;
		function get right():Number;
		
		function set top(value:Number):void;
		function get top():Number;
		
		function set bottom(value:Number):void;
		function get bottom():Number;
		
		function set leftLimit(value:Number):void;
		function get leftLimit():Number;
		
		function set rightLimit(value:Number):void;
		function get rightLimit():Number;
		
		function set topLimit(value:Number):void;
		function get topLimit():Number;
		
		function set bottomLimit(value:Number):void;
		function get bottomLimit():Number;
		
		function set alignTarget(value:DisplayObject):void;
		function get alignTarget():DisplayObject;
		
		/**
		 * Resize Properties
		 */
		function set ww(value:Number):void;
		function get ww():Number;
		
		function set hh(value:Number):void;
		function get hh():Number;
		
		function setSize(w:Number, h:Number, drawBoundingBox:Boolean = false):void;
		
		/**
		 * DisplayObject Properties
		 */
		function get parent():DisplayObjectContainer;
		
		function set x(value:Number):void;
		function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;		
		
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		function removeEventListener (type:String, listener:Function, useCapture:Boolean = false) : void;
		function dispatchEvent (event:Event) : Boolean;
	}
	
}