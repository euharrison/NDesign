package projeto.game
{
    import com.adobe.serialization.json.JSON;
    import com.greensock.TweenMax;

    import flash.display.Sprite;
    import flash.events.Event;

    import projeto.Main;
    import projeto.game.core.Camera;
    import projeto.game.core.Caminho;
    import projeto.game.core.Database;
    import projeto.game.core.Draw;
    import projeto.game.core.Engine;
    import projeto.game.core.UserInfo;
    import projeto.game.ui.ContadorFases;
    import projeto.game.ui.DialogBox;
    import projeto.game.ui.Ferramentas;
    import projeto.game.ui.Levels;
    import projeto.game.ui.Cena;
    import projeto.game.ui.personagens.Personagem;

    import seisd.display.Global;

    /**
	 * ...
	 * @author Harrison, Vamoss
	 */
	public class Game extends Sprite
	{
		
		/// Onde serão desenhados os gráficos
		public static var game:Game;

		/// Onde serão desenhados os gráficos e conterá muito do que for visual, é escalavel e movido pelas ferramentas
		public static var cena:Cena;
		
		/// Tool bar
		public static var ferramentas:Ferramentas;

		/// A Camera é responsável por seguir a trajetória do Carro no Caminho
		public static var camera:Camera;
		
		/// Responsável pela integração com a física (Box2D)
		public static var engine:Engine;

		/// Responsável pelas ações de desenho
		public static var draw:Draw;

		/// Armazena todas as linhas desenhadas num unico level
		public static var caminhoList:Vector.<Caminho>;

        /// Armazena todas os vectors de linhas de cada level para uso ao zerar o jogo
		public static var caminhoFullList:Vector.<Vector.<Caminho>> = new Vector.<Vector.<Caminho>>();

		/// O objeto que segue o caminho
		public static var personagem:Personagem;

		/// Fases, container dos objetivos, controla todos os levels
		public static var levels:Levels;

		/// Boxes que mostram as perguntas, respostas e a tela final
		public static var dialog:DialogBox;

		/// Bolinhas que indicam a fase atual (localizado na equerda do layout)
		public static var contador:ContadorFases;

		/// Integração com o banco de dados
		public static var database:Database;

        /// Contém o state atual do jogo (init, draw, play, pause)
        public static var state:String;

        /// Altura do jogo, contando as compensações do header etc
        public static var height:Number;

        /// Contém o state atual do jogo (init, draw, play, pause)
        public static var width:Number;






		public function Game()
        {
            game = this;

			cena = new Cena();
				addChild(cena);

			engine = new Engine();

			personagem = Main.personagem;
                personagem.x = 0;
                personagem.y = 0;
			    personagem.rotation = 0;
                personagem.visible = false;
			    personagem.initBodys();
				cena.addChild(personagem);
			
			camera = new Camera();

			draw = new Draw();

            caminhoList = new Vector.<Caminho>();

			levels = new Levels();
				addChild(levels);

            ferramentas = new Ferramentas();
                addChild(ferramentas);

            contador = new ContadorFases()
                addChild(contador);

            dialog = new DialogBox()
                addChild(dialog);

            database = new Database();
                database.addEventListener(Database.SAVE_CAMINHO_COMPLETE, saveComplete);
                database.addEventListener(Database.SAVE_CAMINHO_ERROR, saveError);


            Global.stage.addEventListener(Event.RESIZE, resize);
            resize();

            initState();
		}

        private function resize(event:Event = null):void
        {
            this.y = 80;

            Game.width = Global.width;
            Game.height = Global.height - this.y;

            ferramentas.x = Game.width/2;

            dialog.x = Game.width/2;
            dialog.y = Game.height/2;

            contador.y = (Game.height - contador.height) / 2;
        }











        //////////////////
        ///// STATES /////
        //////////////////

        public function initState():void
        {
            state = 'init';

            cleanCaminhos();
            cena.reset();
            levels.create();
            dialog.showPergunta();
            ferramentas.disableAll();
            ferramentas.updatePergunta();
            contador.updateContadores();
        }

		public function drawState():void
        {
            state = 'draw';

            draw.changeState('pencil');
            cena.showStartIconAt(levels.startAt);
            ferramentas.enableForDraw();
            ferramentas.navDrawTools.activate('pencil');
            camera.reset();

            killDelayedDie();
            personagem.visible = false;
		}

		public function playState():void
        {
            createPersonagem();

            state = 'play';

            draw.changeState('play');
            cena.hideStartIcon();
            engine.play();
            camera.play();
            ferramentas.enableForPlay();
		}

		public function pauseState():void
        {
            state = 'pause';

            engine.pause();
            camera.pause();
		}

		public function dieState():void
        {
            if (state != 'die')
            {
                state = 'die';

                personagem.destroy();
                TweenMax.delayedCall(3, delayedDie);
            }
		}



        ///////////////////////////////////////////////////
        ///// AÇÕES - FLUXOS QUE TERMINAM EM UM STATE /////
        ///////////////////////////////////////////////////

		public function stopGame():void
        {
            pauseState();
            destroyPersonagem();
            drawState();
		}

        public function refazer():void
        {
            cleanCaminhos();
            stopGame();
        }

		public function win():void
        {
			pauseState();
            ferramentas.disableAll();
            caminhoFullList[levels.currentLevel] = caminhoList;

			if(levels.currentLevel<levels.totalLevels)
            {
                dialog.showTransicao();
            }
			else
            {
                dialog.showLast();
                save();
            }
		}

        public function replay():void
        {
            destroyPersonagem();
            createPersonagem();
            playState();
        }

        public function avancar():void
        {
            destroyPersonagem();
            levels.next();
            initState();
        }


        /////////////////////////////
        ///// ATALHO DE MÉTODOS /////
        /////////////////////////////

        private function createPersonagem():void
        {
            if (!personagem.created)
            {
                personagem.createAt(levels.startAt.x,levels.startAt.y, levels.startEspelhado);
                personagem.visible = true;
            }
        }

        private function destroyPersonagem():void
        {
            if (personagem.created)
            {
                personagem.destroy();
                personagem.visible = false;
            }
        }

        private function delayedDie():void
        {
            personagem.visible = false;
            pauseState();
            drawState();
        }

        private function killDelayedDie():void
        {
            TweenMax.killDelayedCallsTo(delayedDie);
        }

        private function cleanCaminhos():void
        {
            draw.removeAllPaths();
        }











        ////////////////
        ///// SAVE /////
        ////////////////

        private function save():void
        {
            var userInfo:UserInfo = Main.userInfo;
            var caminho:Caminho;
			var fase:Vector.<Caminho>;

            //Cria JSON dos caminhos
            var obj:Array = new Array();
			for (var j:int = 0; j < caminhoFullList.length; j++){
				fase = caminhoFullList[j];
				obj[j] = new Array();
				for(var i:int=0; i < fase.length;i++)
				{
				   caminho = fase[i];
				   obj[j][i] = {o:{x:caminho.o.x, y:caminho.o.y}, d:{x:caminho.o.x, y:caminho.o.y}, t:caminho.t};
				}
			}
            userInfo.caminho = JSON.encode(obj);
            trace(userInfo.caminho);

            database.saveCaminho(userInfo);
        }

        private function saveError(event:Event):void {
            trace("erro ao salvar no banco de dados");
        }

        private function saveComplete(event:Event):void {
            trace("Salvou",  database.id);
        }














		
	}
	
}