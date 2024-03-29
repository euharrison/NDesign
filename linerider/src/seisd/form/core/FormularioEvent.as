package seisd.form.core
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class FormularioEvent extends Event
	{
		
		public static const ERROR_VALIDATION:String = "errorValidation";
		public static const SEND_INIT:String = "sendInit";
		public static const SEND_ERROR:String = "sendError";
		public static const SEND_SUCCESS:String = "sendSuccess";
		
		
		
		public var invalidatedList:Vector.<FormItem>;
		public var errorEvent:ErrorEvent;
		
		
		public function FormularioEvent(type:String, invalidatedList:Vector.<FormItem> = null, errorEvent:ErrorEvent = null) 
		{
			super(type, false, true);
			
			this.invalidatedList = invalidatedList;
			this.errorEvent = errorEvent;
		}
		
	}

}