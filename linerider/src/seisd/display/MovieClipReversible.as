package seisd.display
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class MovieClipReversible extends MovieClipBase
	{
		
		
		/**
		 * Cria um MovieclipBase que possui a opção de dar playBack() e possui um stop no seu último frame
		 */
		public function MovieClipReversible(stopAtStart:Boolean = false)
		{	
			addFrameScript(totalFrames - 1, stop);
			if (stopAtStart) stop();
		}
		
		/**
		 * Dá play invertido
		 */
		public function playBack():void 
		{
            stop();
			addEventListener(Event.ENTER_FRAME, goBack);
		}
		
		/// override no stop apenas para pausar também um eventual playback
		override public function stop():void 
		{
			super.stop();
			removeEventListener(Event.ENTER_FRAME, goBack);
		}
		
		
		
		
		
		
		////////////////////
		///// HANDLERS /////
		////////////////////
		
		/// @private Dá prevFrame() a cada frame. Se chegar no primeiro frame, dá stop()
		private function goBack(e:Event):void
		{
			(currentFrame == 1) ? stop() : prevFrame();
		}
		
		
		
	}
	
}