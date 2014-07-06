package seisd.display
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class Global extends MovieClip 
	{
		
		/// Instancia estática do stage
		static public var stage:Stage;
		
		/**
		 * Classe que o Main deve extender.
		 * Ela serve para o acesso universal(static) de variáveis
		 */
		public function Global()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/// @private Define as variáveis iniciais
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Global.stage = this.stage;
		}
		
		
		
		
		
		
		/////////////////
		///// ÚTEIS /////
		/////////////////
		
		/**
		 * Define o stage.align e o scaleMode
		 */
		public function stageConfig(align:String = 'TL', scaleMode:String = 'noScale'):void 
		{
			Global.stage.align = align;
			Global.stage.scaleMode = scaleMode;
		}
		
		
		
		
		
		
		
		///////////////////
		///// GETTERS /////
		///////////////////
		
		/// Largura do stage. Global.stage.stageWidth
		public static function get width():Number
		{
			return Global.stage.stageWidth;
		}
		
		/// Altura do stage. Global.stage.stageHeight
		public static function get height():Number
		{
			return Global.stage.stageHeight;
		}
		
		
		
		
		
		
		
		
		
		
	}
	
}