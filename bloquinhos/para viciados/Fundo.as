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
			
			
			nuvem1.x = NUVEM1_X - (porcentagemX / 1);
			nuvem1.y = NUVEM1_Y - (porcentagemY / 1);
			nuvem1.scaleX
			nuvem1.scaleY = scale;
			
			nuvem2.x = NUVEM2_X - (porcentagemX / 3);
			nuvem2.y = NUVEM2_Y - (porcentagemY / 3);
			nuvem2.scaleX
			nuvem2.scaleY = scale;
			
			nuvem3.x = NUVEM3_X - (porcentagemX / 3);
			nuvem3.y = NUVEM3_Y - (porcentagemY / 3);
			nuvem3.scaleX
			nuvem3.scaleY = scale;
			
			nuvem4.x = NUVEM4_X - (porcentagemX / 5);
			nuvem4.y = NUVEM4_Y - (porcentagemY / 5);
			nuvem4.scaleX
			nuvem4.scaleY = scale;
			
			nuvem5.x = NUVEM5_X - (porcentagemX / 15);
			nuvem5.y = NUVEM5_Y - (porcentagemY / 15);
			nuvem5.scaleX
			nuvem5.scaleY = scale;
			
			
			
			sombra1.x = NUVEM1_X - (porcentagemX / 1);
			sombra1.scaleX = scale;
			
			sombra2.x = NUVEM2_X - (porcentagemX / 3);
			sombra2.scaleX = scale;
			
			sombra3.x = NUVEM3_X - (porcentagemX / 3);
			sombra3.scaleX = scale;
			
			sombra4.x = NUVEM4_X - (porcentagemX / 5);
			sombra4.scaleX = scale;
			
			sombra5.x = NUVEM5_X - (porcentagemX / 15);
			sombra5.scaleX = scale;
			
			
			
			
			montanhas.x = -20 -(porcentagemX / 10);
			
		}
	}
	
}