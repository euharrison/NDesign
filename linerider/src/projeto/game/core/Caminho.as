/**
 * Created by IntelliJ IDEA.
 * User: Vamoss
 * Date: 6/19/11
 * Time: 2:05 AM
 */
package projeto.game.core
{
    import Box2D.Dynamics.b2Body;

    import flash.display.Shape;
    import flash.geom.Point;

    public class Caminho
    {


        public static const NORMAL:uint = 0;
        public static const ACELERADO:uint = 1;
        public static const DECORATIVO:uint = 2;


        /// Graphic
        public var g:Shape;

        /// Origin
        public var o:Point;

        /// Destiny
        public var d:Point;

        /// Type
        public var t:int;

        /// b2Body. Adicionado posteriormente pela engine
        public var body:b2Body;

        public function Caminho(_g:Shape, _o:Point,  _d:Point,  _t:uint)
        {
            g = _g;
            o = _o;
            d = _d;
            t = _t;
        }
    }
}
