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

    public class Skate extends Personagem
    {


        private var cabeca:b2Body;
        private var tronco:b2Body;
        private var bracoE:b2Body;
        private var antebracoE:b2Body;
        private var bracoD:b2Body;
        private var antebracoD:b2Body;
        private var coxaE:b2Body;
        private var peE:b2Body;
        private var coxaD:b2Body;
        private var peD:b2Body;
        private var skate:b2Body;


        //stage
        public var cabeca_mc:MovieClip;
        public var tronco_mc:MovieClip;
        public var bracoE_mc:MovieClip;
        public var antebracoE_mc:MovieClip;
        public var bracoD_mc:MovieClip;
        public var antebracoD_mc:MovieClip;
        public var coxaE_mc:MovieClip;
        public var peE_mc:MovieClip;
        public var coxaD_mc:MovieClip;
        public var peD_mc:MovieClip;
        public var skate_mc:MovieClip;



        public function Skate()
        {
			calcaList = [coxaD_mc, coxaE_mc, peD_mc, peE_mc];
			camisaList = [tronco_mc, bracoD_mc, bracoE_mc, antebracoD_mc['camisa'], antebracoE_mc['camisa']];
			peleList = [antebracoD_mc['mao'], antebracoE_mc['mao']];

            espelharList = [antebracoD_mc, antebracoE_mc];

			mcCabeca = cabeca_mc;
        }

		override public function initBodys():void
		{
            cabeca = createCircle(35/2, cabeca_mc, 0.1);
            tronco = createSquare(15, 28, tronco_mc);
            bracoE = createSquare(6, 16, bracoE_mc);
            bracoD = createSquare(6, 16, bracoD_mc);
            antebracoE = createSquare(6, 22, antebracoE_mc);
            antebracoD = createSquare(6, 22, antebracoD_mc);
            coxaE = createSquare(6, 20, coxaE_mc);
            coxaD = createSquare(6, 20, coxaD_mc);
            peE = createSquare(6, 19, peE_mc);
            peD = createSquare(6, 19, peD_mc);
            skate = createCarrinho(30, 8, skate_mc);

            bodyList = Vector.<b2Body>([cabeca, tronco, bracoE, bracoD, antebracoE, antebracoD, coxaE, coxaD, peE, peD, skate]);
            bodyBrokeableList = Vector.<b2Body>([cabeca, tronco]);
            bodyCarrinho = skate;
        }
		
		override public function createAt(xInicial:Number, yInicial:Number, espelhado:Boolean = false):void
		{
            super.createAt(xInicial, yInicial, espelhado);

            position(cabeca, 0, 0, 0);
            position(tronco, 0, 33, 0);
            position(bracoE, -10, 28, 40);
            position(bracoD,  10, 27, -50);
            position(antebracoE, -16, 40, 10);
            position(antebracoD,  16, 39, -10);
            position(coxaE, -7, 50, 30);
            position(coxaD,  7, 50, -17);
            position(peE, -13, 63, 15);
            position(peD,   9, 64, 0);
            position(skate, 1, 75, 0);


            createJoint(cabeca, tronco, 0, 15, -15, 15);
            createJoint(bracoE, tronco, -6, 25, 40, 40);
            createJoint(bracoD, tronco,  6, 25, -50, -50);
            createJoint(antebracoE, bracoE, -15, 34, 10, 10);
            createJoint(antebracoD, bracoD,  16, 33, -10,-10);
            createJoint(coxaE, tronco, -5, 47, 30, 30);
            createJoint(coxaD, tronco,  6, 47, -17, -17);
            createJoint(peE, coxaE, -11, 58, 15, 15);
            createJoint(peD, coxaD,   9, 58, 0, 0);
            createJoint(peE, skate, -15, 73, 15, 15);
            createJoint(peD, skate,   9, 74, 0, 0);

        }



    }
}
