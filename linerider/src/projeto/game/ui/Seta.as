/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 06/07/11
 * Time: 00:05
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui
{
    import flash.display.Sprite;
    import flash.events.Event;

    import projeto.game.Game;

    import seisd.utils.MathUtils;

    public class Seta extends Sprite
    {

        private var alvoX:Number;
        private var alvoY:Number;

        public function Seta(alvoX:Number, alvoY:Number)
        {
            this.alvoX = alvoX;
            this.alvoY = alvoY;

            addEventListener(Event.ADDED_TO_STAGE, added)
            addEventListener(Event.REMOVED_FROM_STAGE, removed)
        }

        private function added(event:Event):void
        {
			addEventListener(Event.ENTER_FRAME, apontaObjetos);
        }

        private function removed(event:Event):void
        {
			removeEventListener(Event.ENTER_FRAME, apontaObjetos);
        }

        private function apontaObjetos(e:Event)
		{
            var xGlobal = Game.cena.x + (alvoX * Game.cena.scaleX);
            var yGlobal = Game.cena.y + (alvoY * Game.cena.scaleY);

            if (
                xGlobal < -Escolha.RAIO ||
                xGlobal > Game.width + Escolha.RAIO ||
                yGlobal < -Escolha.RAIO ||
                yGlobal > Game.height + Escolha.RAIO
               )
            {
                visible = true;

                x = MathUtils.between(xGlobal, 0, Game.width);
                y = MathUtils.between(yGlobal, 0, Game.height);

                var distanciaX:Number = xGlobal - x;
                var distanciaY:Number = yGlobal - y;
                var radianos:Number = Math.atan2(distanciaY,distanciaX);
                rotation = radianos * 180 / Math.PI;
            }
            else
            {
                visible = false;
            }
		}



    }
}
