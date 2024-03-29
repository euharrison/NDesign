package seisd.display 
{
	import flash.events.MouseEvent;
	import seisd.display.MovieClipReversible;
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class ButtonReversible extends MovieClipReversible 
	{
		
		/**
		 * Cria um Botao baseado no MovieClipReversible que funciona com o ROLL_OVER e ROLL_OUT
		 */
		public function ButtonReversible()
		{
			super(true);
			unfreeze();
		}
		
		/**
		 * Congela o efeito reversível do movieclip.
		 * @param	gotoLastFrame true para ele dar play() e ir ao último frame
		 */
		public function freeze(gotoLastFrame:Boolean = true):void
		{
			buttonMode = false;
			mouseChildren = true;
			
			removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
			removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
			
			if (gotoLastFrame && currentFrame != totalFrames) play();
		}
		
		/**
		 * Descongela o efeito reversível permitindo o movieclip dar play() e playback() com o ROLL_OVER e ROLL_OUT
		 * @param	gotoFirstFrame true para ele dar playBack() e ir ao primeiro frame
		 */
		public function unfreeze(gotoFirstFrame:Boolean = true):void
		{	
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, rollOver);
			addEventListener(MouseEvent.MOUSE_OUT, rollOut);
			
			if (gotoFirstFrame && currentFrame != 1) playBack();
		}
		
		
		
		
		
		
		////////////////////
		///// HANDLERS /////
		////////////////////
		
		/// @private Handler do ROLL_OVER
		private function rollOver(e:MouseEvent):void 
		{
			play();
		}
		
		/// @private Handler do ROLL_OUT
		private function rollOut(e:MouseEvent):void 
		{
			playBack();
		}
		
		
		
	}
	
}