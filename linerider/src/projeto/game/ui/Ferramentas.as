/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 04/07/11
 * Time: 23:12
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui
{
    import com.greensock.TweenMax;
    import com.greensock.easing.Quint;

    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    import flash.ui.Mouse;

    import projeto.Main;
    import projeto.game.Game;

    import seisd.display.Global;
    import seisd.navigation.Navigation;
    import seisd.navigation.core.NavigationEvent;

    public class Ferramentas extends Sprite
    {

        public var navDrawTools:Navigation;
        private var toolsList:Vector.<MovieClip>;

        public var typePencil:String;

        private var mouseDown:Boolean;


        //stage
        public var icones:MovieClip;
        public var pencil:MovieClip;
        public var line:MovieClip;
        public var erase:MovieClip;
        public var hand:MovieClip;
        public var zoom:MovieClip;
        public var trash:MovieClip;
        public var playGame:MovieClip;
        public var stopGame:MovieClip;
        public var help:MovieClip;

        public var typeNormal:MovieClip;
        public var typeAcelerado:MovieClip;
        public var typeDecorativo:MovieClip;
        public var typeMarker:MovieClip;

        public var box_ajuda_completo:MovieClip;
        public var box_ajuda:MovieClip;
        public var fechar_bt_ajuda:InteractiveObject;

        public var pergunta:TextField;
        public var numero:TextField;

        public var cursor:MovieClip;




        public function Ferramentas()
        {
            //cursor
            Main.main.layerCursor.mouseEnabled =
            Main.main.layerCursor.mouseChildren = false;
            Main.main.layerCursor.addChild(cursor);
            cursor.visible = false;


            //ferramentas
            icones.mouseEnabled =
            icones.mouseChildren = false;

            toolsList = Vector.<MovieClip>([pencil, line, erase, hand, zoom, playGame, stopGame, trash, help]);

            for (var i:uint = 0; i < toolsList.length; i++)
                toolsList[i].addEventListener(MouseEvent.MOUSE_DOWN, click);

            navDrawTools = new Navigation();
            navDrawTools.addEventListener(NavigationEvent.ACTIVATED, activated);
            navDrawTools.addEventListener(NavigationEvent.DEACTIVATED, deactivated);
            navDrawTools.addItem(pencil)
            navDrawTools.addItem(line)
            navDrawTools.addItem(erase)
            navDrawTools.addItem(hand)
            navDrawTools.addItem(zoom)



            //tipo de traco

            typeMarker.mouseEnabled =
            typeMarker.mouseChildren = false;

            typeNormal.addEventListener(MouseEvent.MOUSE_DOWN, clickPencilType);
            typeAcelerado.addEventListener(MouseEvent.MOUSE_DOWN, clickPencilType);
            typeDecorativo.addEventListener(MouseEvent.MOUSE_DOWN, clickPencilType);



            //ajuda (help)
            box_ajuda = box_ajuda_completo.box;
            fechar_bt_ajuda = box_ajuda_completo.fechar_bt;
            fechar_bt_ajuda.addEventListener(MouseEvent.MOUSE_DOWN, clickFecharAjuda);
            fecharAjuda(0);


            //para cursor/desenho
			Global.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			Global.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
        }

        private function click(event:MouseEvent):void
        {
            switch(event.currentTarget)
            {
                case pencil:
                case line:
                case erase:
                case hand:
                case zoom:
                    navDrawTools.activate(event.currentTarget);
                break;
                case playGame:
                    navDrawTools.deactivate();
                    Game.game.playState();
                break;
                case stopGame:
                    Game.game.stopGame();
                break;
                case trash:
		            Game.game.refazer();
                break;
                case help:
                    abrirAjuda();
                break;
            }

            //evita de conflitar para desenhos no stage
            event.stopImmediatePropagation();
        }

        private function activated(event:NavigationEvent):void
        {
            Game.draw.changeState(navDrawTools.currentItem.name);

            MovieClip(navDrawTools.currentItem).gotoAndStop(2);

            Mouse.hide();
            cursor.visible = true;
            cursor.gotoAndStop(navDrawTools.currentItem.name);
            addEventListener(Event.ENTER_FRAME, enterFrameCursor);
        }

        private function deactivated(event:NavigationEvent):void
        {
            MovieClip(navDrawTools.currentItem).gotoAndStop(1);

            Mouse.show();
            cursor.visible = false;
            removeEventListener(Event.ENTER_FRAME, enterFrameCursor);
        }








        private function clickPencilType(event:MouseEvent):void
        {
            var type:MovieClip = event.currentTarget as MovieClip;

            typeMarker.x = type.x;
            typeMarker.y = type.y;

            typePencil = type.name;

            //evita de conflitar para desenhos no stage
            event.stopImmediatePropagation();
        }











        private function clickFecharAjuda(event:MouseEvent):void
        {
            fecharAjuda();

            //evita de conflitar para desenhos no stage
            event.stopImmediatePropagation();
        }

        private function fecharAjuda(time:Number = .3):void
        {
            TweenMax.to(fechar_bt_ajuda, time, { rotation:-90, autoAlpha:0, ease:Quint.easeOut } );
            TweenMax.to(box_ajuda, time, { scaleX:0, scaleY:0, autoAlpha:0, ease:Quint.easeOut } );
        }

        private function abrirAjuda(time:Number = .3):void
        {
            TweenMax.to(fechar_bt_ajuda, time, { rotation:0, autoAlpha:1, ease:Quint.easeOut } );
            TweenMax.to(box_ajuda, time, { scaleX:1, scaleY:1, autoAlpha:1, ease:Quint.easeOut } );
        }










        private function _onMouseDown(event:MouseEvent):void
        {
            this.mouseDown = true;
        }

        private function _onMouseUp(event:MouseEvent):void
        {
            this.mouseDown = false;
        }

        private function enterFrameCursor(event:Event):void
        {
            cursor.x = Global.stage.mouseX;
            cursor.y = Global.stage.mouseY;

            if (cursor.getChildAt(0) is MovieClip) MovieClip(cursor.getChildAt(0)).gotoAndStop(Number(mouseDown) + 1);
        }











        ///////////////////
        ///// ATALHOS /////
        ///////////////////

        private function keyDown(event:KeyboardEvent):void
        {
            switch(event.keyCode)
            {
                case Keyboard.SPACE:
                    navDrawTools.activate(hand);
                break;
                case 90: //keycode do Z
                    if (event.ctrlKey) Game.draw.removerCaminho(Game.caminhoList.length-1);
                break;
            }
        }

        private function keyUp(event:KeyboardEvent):void
        {
            switch(event.keyCode)
            {
                case Keyboard.SPACE:
                    if (navDrawTools.currentItem == hand)
                    {
                        Global.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
                        navDrawTools.activate(navDrawTools.previousItem);
                    }
                break;
            }
        }

		private function mouseWheel(e:MouseEvent):void
		{
            Game.draw.onMouseWheel(e);
		}








        ///////////////////////////////////
        ///// HABILITAR E DESABILITAR /////
        ///////////////////////////////////

        public function enableAll():void
        {
            Global.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            Global.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			Global.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);

            for (var i:uint = 0; i < toolsList.length; i++)
                toolsList[i].mouseEnabled = toolsList[i].mouseChildren = true;
        }

        public function disableAll():void
        {
            Global.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            Global.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			Global.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);

            for (var i:uint = 0; i < toolsList.length; i++)
                toolsList[i].mouseEnabled = toolsList[i].mouseChildren = false;
        }

        public function enableForDraw():void
        {
            enableAll();
            stopGame.mouseEnabled = stopGame.mouseChildren = false;
        }

        public function enableForPlay():void
        {
            disableAll();
            stopGame.mouseEnabled = stopGame.mouseChildren = true;
            trash.mouseEnabled = trash.mouseChildren = true;
        }







        public function updatePergunta():void
        {
            pergunta.text = Game.levels.pergunta;
            numero.text = DialogBox.fillZero(Game.levels.currentLevel+1);
        }

    }
}
