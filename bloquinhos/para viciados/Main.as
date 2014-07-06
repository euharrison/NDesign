package
{
	import caurina.transitions.*;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	
	
	public class Main extends MovieClip
	{
		protected var assets:ApplicationDomain;
		
		protected var intro1_mc:MovieClip;
		protected var intro2_mc:MovieClip;
		protected var jogo_mc:MovieClip;
		public var interface_mc:MovieClip;
		protected var telaFinal_mc:MovieClip;
		
		protected var mx:Number;
		protected var my:Number;
		
		public var password:String;
		
		
		public function Main()
		{
			this.scaleX = 
			this.scaleY = 0.95;
			
			
			var loaderAssets:Loader = new Loader();
				loaderAssets.load(new URLRequest('assets.swf'));
				loaderAssets.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onProgress);
				loaderAssets.contentLoaderInfo.addEventListener(Event.COMPLETE, _onComplete);
			
			
			stage.addEventListener(Event.ENTER_FRAME, _nuvemPerseguirMouse);
			
			preloader_mc.mask = preloaderMask;
			siteConteiner.mask = siteMask;
			
			
			
			preloader_mc.primeiroJogo_bt.addEventListener(MouseEvent.CLICK, _onClickPrimeiroJogo);
			
			
		}
		
		private function _onClickPrimeiroJogo(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest('http://www.oqueeon021.com.br'), '_blank');
		}
		
		
		
		
		
		
		
		
		protected function _nuvemPerseguirMouse(p_e:Event):void
		{
			if (mx > mouseX)
			{
				//nuvem olha para esquerda
				preloader_mc.nuvem_receiver.nuvem.scaleX = -1;
			}
			else if (mx < mouseX)
			{
				 //olha para direita
				preloader_mc.nuvem_receiver.nuvem.scaleX = 1;
			}
			
			mx = mouseX;
			my = mouseY;
		}
		
		protected function _onProgress(p_e:ProgressEvent):void
		{
			var porcentagem:Number = p_e.bytesLoaded / p_e.bytesTotal;
			
			Tweener.addTween(preloader_mc.nuvem_receiver, { x:mouseX, time:1 } );
			Tweener.addTween(preloader_mc.nuvem_receiver, { y:mouseY, time:1 } );
			
			preloader_mc.nuvem_receiver.porcentagem_txt.text = int(porcentagem * 100);
		}
		
		
		protected function _onComplete(p_e:Event):void
		{
			Tweener.addTween(preloader_mc.nuvem_sender, { scaleX:.1, scaleY:.1, rotation:720, alpha:0, time:.6, transition:'easeInSine' } );
			Tweener.addTween(preloader_mc.nuvem_receiver, { scaleX:.1, scaleY:.1, rotation:720, alpha:0, time:.6, transition:'easeInSine' } );
			
			Tweener.addTween(preloader_mc.password_mc, { scaleX:1, scaleY:1, rotation:-720, alpha:1, time:.6, delay:.6, transition:'easeInSine' } );
			
			preloader_mc.password_mc.entrar_bt.buttonMode = true;
			preloader_mc.password_mc.entrar_bt.addEventListener(MouseEvent.CLICK, _init);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyPress);
			
			
			//arrumo o input para ficar legal e com focus (nao funciona o style e nao sei pq)
            var styleObj:Object = new Object();
				styleObj.fontWeight = "bold";
				styleObj.color = "#660066";
				
			var newStyle:StyleSheet = new StyleSheet();
				newStyle.setStyle(".defStyle", styleObj);
				
			var input:TextField  = preloader_mc.password_mc.password_txt;
            	//input.styleSheet = newStyle;
			
			stage.focus = input;
			
			
			
			
			
			
			
			
			
			assets = p_e.target.applicationDomain;
			
		}
		
		private function _onKeyPress(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyPress);
				_init();
			}
		}
		
		protected function _init(p_e:MouseEvent = null):void
		{
			_initFundo();
		}
		
		
		protected function _initFundo():void
		{
			var Fundo:Class = assets.getDefinition("Fundo") as Class;
			
			var fundo_mc = new Fundo();
				fundo_mc.alpha = 0;
			
			siteConteiner.addChild(fundo_mc);
			Tweener.addTween(fundo_mc, { alpha:1, time:1, transition:'easeOutSine', onComplete:_initJogo } );
		}
		
		
		
		protected function _initJogo():void
		{
			var Jogo:Class = assets.getDefinition("Jogo") as Class;
			
			jogo_mc = new Jogo();
			password = preloader_mc.password_mc.password_txt.text;
			
			siteConteiner.addChild(jogo_mc);
			
		}
		
		public function endJogo(p_minutos:uint, p_segundos:uint):void
		{
			Tweener.addTween(jogo_mc, { alpha:0, time:1, transition:'easeOutSine', onComplete:_apagarJogoMC } );
			_initTelaFinal(p_minutos, p_segundos);
		}
		
		protected function _apagarJogoMC():void
		{
			siteConteiner.removeChild(jogo_mc)
			jogo_mc = null;
		}
		
		protected function _initTelaFinal(p_minutos:uint, p_segundos:uint):void
		{
			var TelaFinal:Class = assets.getDefinition("TelaFinal") as Class;
			
			telaFinal_mc = new TelaFinal(p_minutos, p_segundos);
			telaFinal_mc.x = 1000;
			
			siteConteiner.addChild(telaFinal_mc);
			Tweener.addTween(telaFinal_mc, { x:0, time:1, delay:.7, transition:'easeOutSine' } );
			
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
	
}