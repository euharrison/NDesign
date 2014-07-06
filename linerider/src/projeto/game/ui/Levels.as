package  projeto.game.ui
{
    import com.greensock.loading.LoaderMax;
	import com.greensock.TweenMax;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.net.FileReference;
    import flash.utils.getDefinitionByName;

    import projeto.game.*;

    public class Levels extends Sprite
	{

		private var levelIndex:uint;
		private var _resposta:String;
		
		//XML
		public var xml:XML;
		
		//Armazena os Sprites com as respostas
		private var escolhasList:Vector.<Escolha> = new Vector.<Escolha>();
		
		//Armazena as Setas
		private var setasList:Vector.<Seta> = new Vector.<Seta>();
		
		public function Levels()
		{
			xml = LoaderMax.getContent("xmlLevel");

            levelIndex = 0;
		}

        /**
         * Inseri as perguntas e respostas
         */
		public function create():void
		{
			//Cria respostas
			for (var i:int=0; i < currentXML.resposta.length(); i++)
            {
				var resposta = currentXML.resposta[i];
				
				var tMC:Class = getDefinitionByName(resposta.@tipo) as Class;
				var newMc:Escolha = new tMC() as Escolha;
                    newMc.x = resposta.@x;
                    newMc.y = resposta.@y;
                    newMc.value = resposta.@value;
                    newMc.setLabel(resposta.@label);
				Game.cena.addChild(newMc);
				escolhasList.push(newMc);
				
				var tSeta:Seta = new Seta(resposta.@x, resposta.@y);
				addChild(tSeta);
				setasList.push(tSeta);
			}
		}

        /**
         * Limpa as perguntas e muda para o poximo level
         */
		public function next():void
		{
			levelIndex++;

            //clean obejtivos
            for(var i:int=0;i<escolhasList.length;i++)
            {
				Game.cena.removeChild(escolhasList[i]);
				escolhasList[i] = null;
			}
			escolhasList = new Vector.<Escolha>();

            //clean setas
			for(i=0;i<setasList.length;i++)
            {
				removeChild(setasList[i]);
				setasList[i] = null;
			}
			setasList = new Vector.<Seta>()
		}
		
		/**
		* Verifica se o personagem acertou algum destino
		**/
		public function get check():Boolean
		{
			for (var i:int = 0; i < escolhasList.length; i++)
			{
				if (Game.personagem.hitTestObject(escolhasList[i].hit))
				{
					if (escolhasList[i].value == 'die')
					{
						if (!TweenMax.isTweening(escolhasList[i])) TweenMax.to(escolhasList[i], .2, { alpha:0, yoyo:true, repeat:1, repeatDelay:1 } );
						
						Game.game.dieState();
						return false;
					}
					else 
					{
						_resposta = escolhasList[i].value;
						return true;
					}
				}
			}
			return false;
		}








		
		/**
		* Retorna level atual
		**/
		public function get currentLevel():int
        {
			return levelIndex;
		}

		/**
		* Retorna level atual em forma de xml
		**/
		public function get currentXML():XML
        {
			return xml.level[levelIndex];
		}

		/**
		* Retorna a posicao que o personagem deve comecar
		**/
		public function get startAt():Point
        {
			return new Point(currentXML.startAt.@x, currentXML.startAt.@y);
		}

        /**
         * Verifica se o personagem precisa estar espelhado. -1 para espelhado. 1 para normal (face para direita)
         */
        public function get startEspelhado():Boolean
        {
            return Boolean(currentXML.startAt.@espelhado == 'true')
        }
		
		/**
		* Retorna total de levels
		**/
		public function get totalLevels():int
        {
			return xml.level.length()-1;
		}

		/**
		* Retorna pergunta atual
		**/
		public function get pergunta():String
        {
			return currentXML.pergunta.text();
		}

		/**
		* Retorna resposta atual
		**/
		public function get resposta():String
        {
			return _resposta;
		}
    }
	
}
