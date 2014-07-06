/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 19/06/11
 * Time: 04:03
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui.personagens
{
    import Box2D.Dynamics.b2Body;

    import flash.display.MovieClip;

    public class Treno extends Personagem
    {


        private var cabeca:b2Body;
        private var tronco:b2Body;
        private var bracoD:b2Body;
        private var antebracoD:b2Body;
        private var maoD:b2Body;
        private var coxaD:b2Body;
        private var peD:b2Body;
        private var carrinho:b2Body;


        //stage
        public var cabeca_mc:MovieClip;
        public var tronco_mc:MovieClip;
        public var bracoD_mc:MovieClip;
        public var antebracoD_mc:MovieClip;
        public var maoD_mc:MovieClip;
        public var coxaD_mc:MovieClip;
        public var peD_mc:MovieClip;
        public var carrinho_mc:MovieClip;



        public function Treno()
        {
			calcaList = [coxaD_mc, peD_mc];
			camisaList = [tronco_mc, bracoD_mc, antebracoD_mc, maoD_mc];
			peleList = [maoD_mc];

            espelharList = [maoD_mc, peD_mc, carrinho_mc]

			mcCabeca = cabeca_mc;
        }

		override public function initBodys():void
		{
            cabeca = createCircle(35/2, cabeca_mc, 0.01);
            tronco = createSquare(9, 26, tronco_mc, 0.1);
            bracoD = createSquare(4, 15, bracoD_mc, 0.1);
            antebracoD = createSquare(4, 15, antebracoD_mc, 0.1);
            maoD = createSquare(9, 9, maoD_mc, 0.1);
            coxaD = createSquare(5, 19, coxaD_mc, 0.1);
            peD = createSquare(4, 18, peD_mc, 0.1);
            carrinho = createCarrinho(35, 26, carrinho_mc);

            bodyList = Vector.<b2Body>([cabeca, tronco, bracoD, antebracoD, coxaD, peD, carrinho]);
            bodyBrokeableList = Vector.<b2Body>([cabeca, tronco]);
            bodyCarrinho = carrinho;
        }

		override public function createAt(xInicial:Number, yInicial:Number, espelhado:Boolean = false):void
		{
            super.createAt(xInicial, yInicial, espelhado);

            position(cabeca, -10, 0, 0);
            position(tronco, -12, 34, 0);
            position(bracoD, -9, 31, -40);
            position(antebracoD, 0, 36, -80);
            position(maoD, 9, 36, -90);
            position(coxaD, -4, 45, -90);
            position(peD, 5, 51, -31);
            position(carrinho, 0, 48, 0);


            createJoint(cabeca, tronco, -12, 21, -15, 15);
            createJoint(bracoD, tronco, -12, 27, -40, -40);
            createJoint(antebracoD, bracoD, -5, 35, -80, -80);
            createJoint(maoD, antebracoD, 6, 36, -90, -90);
            createJoint(coxaD, tronco, -13, 45, -90, -90);
            createJoint(peD, coxaD, 2, 45, -31, -31);

            createJoint(maoD, carrinho, 0, 46, -90, -90);
            createJoint(tronco, carrinho, -3, 44, -90, -90);
            createJoint(coxaD, carrinho, -11, 52, -90, -90);
            createJoint(peD, carrinho, -8, 66, -31, -31);

        }



    }
}
