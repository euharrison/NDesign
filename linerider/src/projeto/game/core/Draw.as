package projeto.game.core
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import projeto.game.Game;

    import seisd.display.Global;
    import seisd.utils.ArrayUtils;
    import seisd.utils.ArrayUtils;

    public class Draw
	{

		/**
		* Estados da aplicação
		* pencil, line, erase, hand, zoom, play
		**/
		private var currentState:String;

		/**
		* Faz o preview da linha sendo desenhada
		**/
		private var projecao:Sprite;
		
		/**
		* Armazena última posição de desenho
		**/
		private var lastClickPosition:Point = new Point();




		public function Draw()
		{
			projecao = new Sprite();
				projecao.graphics.beginFill(0xf000f0);
				projecao.graphics.drawRect(0, 0, 1, 1);
				projecao.graphics.endFill();
				projecao.mouseEnabled=false;
				Game.cena.addChild(projecao);
			
			Global.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			//stage.addEventListener(Event.MOUSE_LEAVE, _onMouseUp);
		}
		
		private function _onMouseDown(e:MouseEvent):void 
		{
            Global.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);

            switch (currentState)
            {
                case "pencil":
                case "line":
                    //Testa se o mouse está próximo do último clique
                    //Arredonda a posição para para dar continuidade na linha
                    if(Game.cena.lastClickIcon.visible)
                    {
                        var a:Number = Game.cena.mouseX - lastClickPosition.x; //cateto adjacente
                        var b:Number = Game.cena.mouseY - lastClickPosition.y; //cateto oposto
                        var clickDistance:Number = Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2)); //hipotenusa

                        if (clickDistance > 20)
                        {
                            //O Clique está longe da última posição
                            //Então usa a posição do mouse
                            projecao.x = Game.cena.mouseX;
                            projecao.y = Game.cena.mouseY;
                        }
                        else
                        {
                            projecao.x = lastClickPosition.x;
                            projecao.y = lastClickPosition.y;
                        }
                        Game.cena.hideLastClickIcon()
                    }
                    else
                    {
                        projecao.x = Game.cena.mouseX;
                        projecao.y = Game.cena.mouseY;
                    }

                    Global.stage.addEventListener(Event.ENTER_FRAME, _projetar);
                    projecao.visible = true;
                    break;
                case "erase":
                    Global.stage.addEventListener(Event.ENTER_FRAME, _projetar);
                    break;
                case "hand":
                    Game.cena.startDrag();
                    break;
                case "zoom":
                    Game.cena.zoomStartPosition.x = Global.stage.mouseX;
                    Game.cena.zoomStartPosition.y = Global.stage.mouseY;
                    Global.stage.addEventListener(Event.ENTER_FRAME, _projetar);
                    break;
                case "play":
                    break;
            }
			
		}
		
		private function _onMouseUp(e:MouseEvent = null):void
		{
			switch (currentState)
            {
				case "pencil":
				case "line":
                    if (projecao.visible)
                    {
                        _recordLastPosition(Game.cena.mouseX, Game.cena.mouseY);
                        _desenharCaminho();
                    }
					break;
				case "erase":
					break;
				case "hand":
					Game.cena.stopDrag();
					break;
				case "zoom":
					break;
				case "play":
					break;
			}

            projecao.visible = false;
            Global.stage.removeEventListener(Event.ENTER_FRAME, _projetar);
            Global.stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);

		}
		
		private function _projetar(e:Event):void 
		{
			switch (currentState)
			{	
				case "pencil":
					// tamanho máximo da linha (otimiza processamento?)
					if (distancia < 30) _desenharProjecao();
					else _desenharCaminho();
					break;
				case "line":
					_desenharProjecao();
					break;
				case "zoom":
					var dist:Number = (Game.cena.zoomStartPosition.y - Global.stage.mouseY)/1000 + 1;
					Game.cena.escalar(dist);
					break;
				case "erase":
					for (var i:int = 0; i < Game.caminhoList.length; i++)
					{
                        if (Game.caminhoList[i].g.hitTestPoint(Global.stage.mouseX, Global.stage.mouseY))
                            Game.draw.removerCaminho(i);
					}
					break;
			}
		}













		private function get angulo():Number
		{
			var a:Number = Game.cena.mouseX - projecao.x; //cateto adjacente
			var b:Number = Game.cena.mouseY - projecao.y; //cateto oposto
			
			var angulo:Number = Math.atan2(b, a); //radianos
			    angulo = angulo * 180 / Math.PI; //graus
			return angulo;
		}
		
		private function get distancia():Number
		{
			var a:Number = Game.cena.mouseX - projecao.x; //cateto adjacente
			var b:Number = Game.cena.mouseY - projecao.y; //cateto oposto
			var c:Number = Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2)); //hipotenusa

			return c;
		}













		private function _desenharProjecao():void
		{
			projecao.scaleX = distancia;
			projecao.rotation = angulo;
		}

		private function _desenharCaminho():void
		{
			var xinicial:Number = projecao.x;
			var yinicial:Number = projecao.y;
			
			var xfinal:Number = Game.cena.mouseX;
			var yfinal:Number = Game.cena.mouseY;

			// desenho o caminho pelo graphics
			var tempSprite:Shape = new Shape();
			
			//Hit area
			tempSprite.graphics.lineStyle(10, 0xff0000, 0);
			tempSprite.graphics.moveTo(xinicial, yinicial);
			tempSprite.graphics.lineTo(xfinal, yfinal);
			
			//Linha visivel
            var type:uint = 0;
            var cor:uint = 0x000000;
            switch(Game.ferramentas.typePencil)
            {
                case 'typeNormal':
                    cor = 0x000000;
                    type = Caminho.NORMAL;
                break;
                case 'typeAcelerado':
                    cor = 0xf62e8d;
                    type = Caminho.ACELERADO;
                break;
                case 'typeDecorativo':
                    cor = 0xceda3a;
                    type = Caminho.DECORATIVO;
                break;
            }
			tempSprite.graphics.lineStyle(1, cor);
			tempSprite.graphics.moveTo(xinicial, yinicial);
			tempSprite.graphics.lineTo(xfinal, yfinal);
			
			Game.cena.addChildAt(tempSprite, 0);

            var caminho:Caminho = new Caminho(tempSprite, new Point(xinicial, yinicial), new Point(xfinal,  yfinal), type)
			Game.caminhoList.push(caminho);
			
			// desenho o caminho no engine
			var centro:Point = new Point();
				centro.x = (xinicial + xfinal) / 2;
				centro.y = (yinicial + yfinal) / 2;
				
			if (type != Caminho.DECORATIVO) Game.engine.desenharCaminhoBox2d(caminho, distancia, centro, angulo, type);
			
			// arrumo a projecao para a próxima vez
			projecao.scaleX = 1; //corrige efeito visual
			projecao.x = xfinal;
			projecao.y = yfinal;
		}

        public function onMouseWheel(e:MouseEvent):void
		{
			if (Game.state == "draw")
			{
				Game.cena.zoomStartPosition.x = Global.stage.mouseX;
				Game.cena.zoomStartPosition.y = Global.stage.mouseY;
				if(e.delta>0){
					Game.cena.escalar(1.05);
				}else{
					Game.cena.escalar(0.95);
				}
			}
		}









		public function removeAllPaths():void
		{
            while (Game.caminhoList.length > 0) removerCaminho(0);
		}

		public function removerCaminho(index:int):void
		{
            if (index >= 0 && index < Game.caminhoList.length)
            {
                var caminho:Caminho = Game.caminhoList[index];
                Game.cena.removeChild(caminho.g);
                Game.engine.removerCaminho(caminho);
                ArrayUtils.remove(caminho, Game.caminhoList);

                if (Game.caminhoList.length > 0)
                    _recordLastPosition(Game.caminhoList[Game.caminhoList.length-1].d.x, Game.caminhoList[Game.caminhoList.length-1].d.y);
                else
                    _recordLastPosition(0,0);
            }
        }







        

        private function initEraseMode():void
        {
            Global.stage.addEventListener(Event.ENTER_FRAME, checkCaminho, false, 1);
        }

        private function removeEraseMode():void
        {
            Global.stage.removeEventListener(Event.ENTER_FRAME, checkCaminho);
        }

        private function checkCaminho(event:Event):void
        {
            for (var i:int = 0; i < Game.caminhoList.length; i++)
            {
                Game.caminhoList[i].g.alpha = (Game.caminhoList[i].g.hitTestPoint(Global.stage.mouseX, Global.stage.mouseY)) ? .5 : 1;
            }
        }













		private function _recordLastPosition(x:Number, y:Number):void
		{
			lastClickPosition = new Point(x, y);
            Game.cena.showLastClickIconAt(lastClickPosition);
		}

        public function changeState(state:String):void
        {
            currentState = state;
            if (currentState == 'play') Game.cena.hideLastClickIcon();

            if (currentState == 'erase') initEraseMode();
            else removeEraseMode();
        }




    }

}
