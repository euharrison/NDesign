package
{
	import caurina.transitions.*;
	import flash.display.Sprite;
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
		
		
		public function Main()
		{
			var loaderAssets:Loader = new Loader();
				loaderAssets.load(new URLRequest('assets.swf'));
				loaderAssets.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onProgress);
				loaderAssets.contentLoaderInfo.addEventListener(Event.COMPLETE, _onComplete);
				
			preloader_mc.entrar_bt.addEventListener(MouseEvent.CLICK, _init);
			preloader_mc.ranking_bt.addEventListener(MouseEvent.CLICK, _onClickRanking);
			
			stage.addEventListener(Event.ENTER_FRAME, _nuvemPerseguirMouse);
			
			preloader_mc.mask = preloaderMask;
			siteConteiner.mask = siteMask;
			
			
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
			
			Tweener.addTween(preloader_mc.entrar_bt, { scaleX:1, scaleY:1, rotation:720, alpha:1, time:.6, delay:.6, transition:'easeInSine' } );
			Tweener.addTween(preloader_mc.ranking_bt, { scaleX:1, scaleY:1, rotation:720, alpha:1, time:.6, delay:.6, transition:'easeInSine' } );
			
			assets = p_e.target.applicationDomain;
			
		}
		
		protected function _init(p_e:MouseEvent):void
		{
			_initFundo();
		}
		
		private function _onClickRanking(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest('ranking/'));
		}
		
		
		
		protected function _initFundo():void
		{
			var Fundo:Class = assets.getDefinition("Fundo") as Class;
			
			var fundo_mc = new Fundo();
				fundo_mc.alpha = 0;
			
			siteConteiner.addChild(fundo_mc);
			Tweener.addTween(fundo_mc, { alpha:1, time:1, transition:'easeOutSine', onComplete:_initIntro1 } );
		}
		
		protected function _initIntro1():void
		{
			var Intro1:Class = assets.getDefinition("Intro1") as Class;
			
			intro1_mc = new Intro1();
			intro1_mc.x = 1000;
			
			siteConteiner.addChild(intro1_mc);
			Tweener.addTween(intro1_mc, { x:0, time:1, transition:'easeOutSine' } );
			
			intro1_mc.avancar_bt.addEventListener(MouseEvent.CLICK, _aoAvancarIntro1);
		}
		
		
		protected function _aoAvancarIntro1(p_e:MouseEvent):void
		{
			intro1_mc.avancar_bt.visible = false;
			_leaveIntro1();
			_initIntro2();
		}
		
		
		protected function _leaveIntro1():void
		{
			Tweener.addTween(intro1_mc, { x: -1000, time:1, transition:'easeOutSine' } );
		}
		
		
		protected function _initIntro2():void
		{			
			var Intro2:Class = assets.getDefinition("Intro2") as Class;
			
			intro2_mc = new Intro2();
			intro2_mc.x = 1000;
			
			siteConteiner.addChild(intro2_mc);
			Tweener.addTween(intro2_mc, { x:0, time:1, transition:'easeOutSine' } );
			
			intro2_mc.avancar_bt.addEventListener(MouseEvent.CLICK, _aoAvancarIntro2);
		}
		
		
		protected function _aoAvancarIntro2(p_e:MouseEvent):void
		{
			_leaveIntro2();
			_initJogo();
		}		
		
		
		protected function _leaveIntro2():void
		{
			Tweener.addTween(intro2_mc, { x: -1000, time:1, transition:'easeOutSine' } );
		}
		
		
		protected function _initJogo():void
		{
			var Jogo:Class = assets.getDefinition("Jogo") as Class;
			
			jogo_mc = new Jogo();
			
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