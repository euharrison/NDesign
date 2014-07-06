package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Musica extends MovieClip
	{
		
		protected var canal:SoundChannel;
		protected var som:Sound;
		protected var posicao:Number;
		
		
		public function Musica()
		{
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		protected function _init(p_e:Event):void
		{
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, _onClick);
			
			som = new Sound();
			som.load(new URLRequest('musica.mp3'));
			
			canal = new SoundChannel();
			
			posicao = 0;
		}
		
		
		protected function _onClick(p_e:MouseEvent):void
		{
			if (this.currentLabel == 'on')
			{
				posicao = canal.position;
				canal.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				canal.stop();
				gotoAndStop('off');
			}
			else
			{
				canal = som.play(posicao);
				canal.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				gotoAndStop('on');
			}
			
		}
		
		function _onSoundComplete(e:Event):void
		{
			posicao = 0;
			canal = som.play(posicao);
			canal.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
		}
		
		
		
	}
	
}