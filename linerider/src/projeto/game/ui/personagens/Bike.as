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

    public class Bike extends Personagem
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



        public function Bike()
        {
			calcaList = [coxaD_mc, peD_mc];
			camisaList = [tronco_mc, bracoD_mc, antebracoD_mc, maoD_mc];
			peleList = [maoD_mc];

            espelharList = [maoD_mc, peD_mc, carrinho_mc]

			mcCabeca = cabeca_mc;
        }

		override public function initBodys():void
		{
            cabeca = createCircle(35/2, cabeca_mc, 0.1);
            tronco = createSquare(9, 26, tronco_mc);
            bracoD = createSquare(4, 15, bracoD_mc);
            antebracoD = createSquare(4, 15, antebracoD_mc);
            maoD = createSquare(9, 9, maoD_mc);
            coxaD = createSquare(5, 19, coxaD_mc);
            peD = createSquare(4, 18, peD_mc);
            carrinho = createCarrinho(40, 38, carrinho_mc);

            bodyList = Vector.<b2Body>([cabeca, tronco, bracoD, antebracoD, coxaD, peD, carrinho]);
            bodyBrokeableList = Vector.<b2Body>([cabeca, tronco]);
            bodyCarrinho = carrinho;
        }
		
		override public function createAt(xInicial:Number, yInicial:Number, espelhado:Boolean = false):void
		{
            super.createAt(xInicial, yInicial, espelhado);

            position(cabeca, 0, 0, 15);
            position(tronco, -10, 33, 17);
            position(bracoD, -5, 31, -23);
            position(antebracoD, 2, 40, -50);
            position(maoD, 10, 45, -60);
            position(coxaD, -7, 47, -52);
            position(peD, -1, 59, 0);
            position(carrinho, 2, 62, 0);


            createJoint(cabeca, tronco, -7, 21, 0, 30);
            createJoint(bracoD, tronco, -7, 26, -33, -13);
            createJoint(antebracoD, bracoD, -2, 37, -60, -40);
            createJoint(maoD, antebracoD, 8, 44, -60, -40);
            createJoint(coxaD, tronco, -13, 42, -52, -52);
            createJoint(peD, coxaD, -1, 52, 0, 0);

            createJoint(maoD, carrinho, 10, 46, -60, -40);
            createJoint(tronco, carrinho, -13, 44, 7, 27);
            createJoint(coxaD, carrinho, -1, 52, -52, -52);
            createJoint(peD, carrinho, 2, 66, 0, 0);
        }



    }
}
