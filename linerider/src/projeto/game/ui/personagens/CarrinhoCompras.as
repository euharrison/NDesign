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

    public class CarrinhoCompras extends Personagem
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



        public function CarrinhoCompras()
        {
			calcaList = [coxaD_mc, peD_mc];
			camisaList = [tronco_mc, bracoD_mc, antebracoD_mc, maoD_mc];
			peleList = [maoD_mc];

            espelharList = [maoD_mc, carrinho_mc]

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
            carrinho = createCarrinho(20, 27, carrinho_mc);

            bodyList = Vector.<b2Body>([cabeca, tronco, bracoD, antebracoD, coxaD, peD, carrinho]);
            bodyBrokeableList = Vector.<b2Body>([cabeca]);
            bodyCarrinho = carrinho;
        }

		override public function createAt(xInicial:Number, yInicial:Number, espelhado:Boolean = false):void
		{
            super.createAt(xInicial, yInicial, espelhado);

            position(cabeca, 0, 0, 0);
            position(tronco, -2, 33, 0);
            position(bracoD, 0, 30, -29);
            position(antebracoD, 8, 38, -60);
            position(maoD, 15, 40, -73);
            position(coxaD, 2, 38, -140);
            position(peD, 10, 38, -37);
            position(carrinho, 8, 42, 0);


            createJoint(cabeca, tronco, -1, 22, -15, 15);
            createJoint(bracoD, tronco, -2, 26, -29, -29);
            createJoint(antebracoD, bracoD, 3, 35, -60, -60);
            createJoint(maoD, antebracoD, 13, 40, -73, -73);
            createJoint(coxaD, tronco, -3, 43, -140, -140);
            createJoint(peD, coxaD, 6, 32, -37, -37);

            createJoint(tronco, carrinho, -2, 29, 0, 0);
            createJoint(bracoD, carrinho, 3, 35, -29, -29);
            createJoint(antebracoD, carrinho, 13, 40, -60, -60);
            createJoint(maoD, carrinho, 18, 41, -73, -73);
            createJoint(coxaD, carrinho, 6, 32, -140, -140);
            createJoint(peD, carrinho, 15, 43, -37, -37);
        }



    }
}
