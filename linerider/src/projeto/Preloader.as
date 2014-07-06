package projeto
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import com.greensock.TweenNano;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
    import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

    /**
	 * ...
	 * @author Vamoss
	 */
	public class Preloader extends MovieClip
	{

		//stage
		public var animacao:MovieClip;
		public var percent:TextField;
		
		private var swfIndex:MovieClip;
		
		public function Preloader()
        {
			initStage();
			
			resize();
			
			load();
		}
		
		private function initStage():void 
		{
			stage.align = 'TL';
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resize);
		}
		
		private function load():void
		{
			var loader:LoaderMax = new LoaderMax( { auditSize:true, onProgress:progress, onComplete:completeLoader } );
				loader.append(new SWFLoader('Main.swf', { name:'index' } ));
			loader.load();
			
			initPercent();
		}
		
		private function progress(e:LoaderEvent):void 
		{
			percent.text = String(Math.floor(e.target.progress * 100)) + '%';
		}
		
		private function completeLoader(e:LoaderEvent):void 
		{
			swfIndex = LoaderMax.getLoader('index').rawContent;
			swfIndex.alpha = 0;
			
			TweenNano.to(animacao, 1, { alpha:0, onComplete:function() {
				removeChild(animacao);
				stage.removeEventListener(Event.RESIZE, resize);
				stage.addChild(swfIndex);
				TweenNano.to(swfIndex, .5, { alpha:1 } );
			}} );
			
			destroyPercent();
		}
		
		private function initPercent():void 
		{
			addEventListener(Event.ENTER_FRAME, percentFollowMouse);
		}
		
		private function destroyPercent():void 
		{
			TweenNano.to(percent, 1, { alpha:0, onComplete:function() {
				removeChild(percent);
				removeEventListener(Event.ENTER_FRAME, percentFollowMouse);
			}} );
		}
		
		private function percentFollowMouse(e:Event):void 
		{
			TweenNano.to(percent, 1, { x:mouseX + 15, y:mouseY + 25 } );
		}
		

        private function resize(event:Event = null):void
        {
			if (animacao)
			{
				animacao.x = stage.stageWidth/2;
				animacao.y = stage.stageHeight / 2;
			}
        }
		
	}
	
}