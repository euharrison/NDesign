package  projeto.game.core
{
    import com.greensock.TweenMax;

    import flash.events.Event;
    import flash.geom.Point;

    import projeto.game.*;

    import seisd.display.Global;

    /**
	* A Camera é responsável por seguir a trajetória do cabeca no Caminho
	**/
	public class Camera
    {


		
		public var centerPosition:Point;

		
		public function Camera()
        {

		}
		
		public function play():void
        {
			centerPosition = new Point(Game.width/2, Game.height/2);
			
			Global.stage.addEventListener(Event.ENTER_FRAME, _update);
		}
		
		public function pause():void
        {
			Global.stage.removeEventListener(Event.ENTER_FRAME, _update);
		}

		public function reset():void
        {
            pause();
            TweenMax.to(Game.cena, .3, { x:(Global.width - 1000)/2, y:0 } );
		}



		private function _update(e:Event):void
        {
			var d = distancia;
			if (d<0) d *= -1;
			
			//Tentativa de achar uma fórmula que faça a velocidade aumentar conforme a distancia aumenta
			//O problema é quando a distancia ultrapassa o distancia maxima e salta derrepente
			//var velocity:Number = d/maxDistance;
			//var velocity:Number = Math.max(Math.min(d/maxDistance,.9),.6);
			//var velocity:Number =.9;
			
			/*trace("----");
			trace("d: " + d);
			trace("v: " + velocity);
			trace("xcar: " + cabeca.x);
			trace("ycar: " + cabeca.y);
			trace("xcam: " + caminho.x);
			trace("ycam: " + caminho.y);*/
			
			Game.cena.x = - (Game.personagem.mcCabeca.x * Game.cena.scaleX) + centerPosition.x;
			Game.cena.y = - (Game.personagem.mcCabeca.y * Game.cena.scaleY) + centerPosition.y;
		}
		
		private function get distancia():Number
        {
			var a:Number = Game.personagem.mcCabeca.x + Game.cena.x - centerPosition.x; //cateto adjacente
			var b:Number = Game.personagem.mcCabeca.y + Game.cena.y - centerPosition.y; //cateto oposto
			var c:Number = Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2)); //hipotenusa

			return c;
		}


	}
	
}
