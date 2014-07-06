package
{
	import caurina.transitions.*
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Fundo extends MovieClip
	{
		protected var NUVEM1_X:uint;
		protected var NUVEM2_X:uint;
		protected var NUVEM3_X:uint;
		protected var NUVEM4_X:uint;
		protected var NUVEM5_X:uint;
		
		protected var NUVEM1_Y:uint;
		protected var NUVEM2_Y:uint;
		protected var NUVEM3_Y:uint;
		protected var NUVEM4_Y:uint;
		protected var NUVEM5_Y:uint;
		
		public function Fundo()
		{
			NUVEM1_X = nuvem1.x;
			NUVEM2_X = nuvem2.x;
			NUVEM3_X = nuvem3.x;
			NUVEM4_X = nuvem4.x;
			NUVEM5_X = nuvem5.x;
			
			NUVEM1_Y = nuvem1.y;
			NUVEM2_Y = nuvem2.y;
			NUVEM3_Y = nuvem3.y;
			NUVEM4_Y = nuvem4.y;
			NUVEM5_Y = nuvem5.y;
			
			this.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		protected function _onEnterFrame(p_e:Event):void
		{
			var porcentagemX = (mouseX / stage.stageWidth) * 50;
			var porcentagemY = (mouseY / stage.stageHeight) * 20;
			//var scale = ((mouseY / stage.stageHeight) / 20) + 0.95;
			var scale = 1;
			
			Tweener.addTween (nuvem1, { x:NUVEM1_X - (porcentagemX / 1), y:NUVEM1_Y - (porcentagemY / 1), scaleX:scale, scaleY:scale, time:1 } );
			Tweener.addTween (nuvem2, { x:NUVEM2_X - (porcentagemX / 3), y:NUVEM2_Y - (porcentagemY / 3), scaleX:scale, scaleY:scale, time:1 } );
			Tweener.addTween (nuvem3, { x:NUVEM3_X - (porcentagemX / 3), y:NUVEM3_Y - (porcentagemY / 3), scaleX:scale, scaleY:scale, time:1 } );
			Tweener.addTween (nuvem4, { x:NUVEM4_X - (porcentagemX / 5), y:NUVEM4_Y - (porcentagemY / 5), scaleX:scale, scaleY:scale, time:1 } );
			Tweener.addTween (nuvem5, { x:NUVEM5_X - (porcentagemX / 15), y:NUVEM5_Y - (porcentagemY / 15), scaleX:scale, scaleY:scale, time:1 } );
			
			Tweener.addTween (sombra1, { x:NUVEM1_X - (porcentagemX / 1), scaleX:scale, time:1 } );
			Tweener.addTween (sombra2, { x:NUVEM2_X - (porcentagemX / 3), scaleX:scale, time:1 } );
			Tweener.addTween (sombra3, { x:NUVEM3_X - (porcentagemX / 3), scaleX:scale, time:1 } );
			Tweener.addTween (sombra4, { x:NUVEM4_X - (porcentagemX / 5), scaleX:scale, time:1 } );
			Tweener.addTween (sombra5, { x:NUVEM5_X - (porcentagemX / 15), scaleX:scale, time:1 } );
			
			Tweener.addTween (montanhas, { x: -20 -(porcentagemX / 10), time:1 } );
			
		}
	}
	
}