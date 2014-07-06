package seisd.display
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Vamoss, Harrison
	 */
	public class MovieClipBase extends MovieClip
	{
		private var _ww:Number;
		private var _hh:Number;
		
		private var _align:Align;
		
		public function MovieClipBase()
		{	
			addEventListener(Event.ADDED_TO_STAGE, added);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		
		/**
		 * Define o tamanho final do movieclip, variáveis úteis para problemas como espera de carregamento de imagens e itens mascarados
		 * @param	w
		 * @param	h
		 * @param	drawBoundingBox Se precisar verificar os valores, defina como true que desenhará uma borda vermelha baseado no ww e hh
		 */
		public function setSize(w:Number, h:Number, drawBoundingBox:Boolean = false):void
		{
			_ww = w ? w : 0;
			_hh = h ? h : 0;
			
			if (drawBoundingBox)
			{
				graphics.clear();
				graphics.lineStyle(1, 0xFF0000);
				graphics.drawRect(0, 0, _ww, _hh);
			}
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		protected function added(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, added);
			
			stage.addEventListener(Event.RESIZE, onResize, false, -1, true);
            onResize();
		}
		
		protected function removed(e:Event):void 
		{
			stage.removeEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(e:Event = null):void
		{

		}
		
		/// Largura fictícia do objeto
		public function get ww():Number { return _ww; }
		public function set ww(value:Number):void 
		{
			setSize(value, _hh);
		}
		
		/// Altura fictícia do objeto
		public function get hh():Number { return _hh; }
		public function set hh(value:Number):void 
		{
			setSize(_ww, value);
		}
		
		
		/// Altura fictícia do objeto
		public function get align():Align
		{
			if (!_align) _align = AutoAlign.getAlign(this) || AutoAlign.add(this, parent);
			return _align;
		}
		
	}
	
}