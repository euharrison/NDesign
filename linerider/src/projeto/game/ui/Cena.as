/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 06/07/11
 * Time: 00:07
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.Point;
	import seisd.display.Global;

    import projeto.Main;
    import projeto.game.Game;

    public class Cena extends Sprite
    {


		private const maxScale:Number = 5;
		private const minScale:Number = .3;
		public var zoomStartPosition:Point = new Point();


        //stage
        public var lastClickIcon:MovieClip;
        public var startIcon:MovieClip;

        public function Cena()
        {
            hideLastClickIcon();
            hideStartIcon();
        }

        public function reset()
        {
            scaleX =
            scaleY = 1;
            x = (Global.width - 1000)/2;
            y = 0;
        }

		public function escalar(dist:Number):void
		{
			if (scaleX*dist >= maxScale) dist = maxScale/scaleX;
			if (scaleX*dist <= minScale) dist = minScale/scaleX;

			if (dist != 1)
			{
				/*var m:Matrix=GamePlay.caminho.transform.matrix;
				m.tx -= projecao.x;
				m.ty -= projecao.y;
				m.scale(dist, dist);
				m.tx += projecao.x;
				m.ty += projecao.y;
				engine.transform.matrix =
				GamePlay.caminho.transform.matrix = m;*/

				x = zoomStartPosition.x - ((zoomStartPosition.x - x) * dist);
				y = zoomStartPosition.y - ((zoomStartPosition.y - y) * dist);
				scaleX = scaleX*(dist);
				scaleY = scaleY*(dist);
			}

		}







        public function showLastClickIconAt(point:Point):void
        {
            lastClickIcon.visible = true;
            lastClickIcon.x = point.x;
            lastClickIcon.y = point.y;
        }

        public function hideLastClickIcon():void
        {
            lastClickIcon.visible = false;
        }

        public function showStartIconAt(point:Point):void
        {
            startIcon.visible = true;
            startIcon.x = point.x;
            startIcon.y = point.y;

            var tipo:String = Main.userInfo.tipo_carro;
            if (Game.levels.startEspelhado) tipo += '_espelho';

            startIcon.gotoAndStop(tipo);
        }

        public function hideStartIcon():void
        {
            startIcon.visible = false;
        }

    }
}
