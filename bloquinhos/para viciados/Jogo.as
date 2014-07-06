package
{
	import flash.display.MovieClip
	import flash.display.Sprite
	import flash.events.*
	import flash.events.MouseEvent
	import flash.text.*
	import Box2D.Dynamics.*
	import Box2D.Collision.*
	import Box2D.Collision.Shapes.*
	import Box2D.Common.Math.*
	import flash.utils.Timer;
	import flash.ui.Mouse;
	
	import caurina.transitions.*;
	import Level;
	import SenhasNomes;
	
	import SWFAddress;
	
	public class Jogo extends MovieClip
	{
		
		protected var bodyDef:b2BodyDef;
		protected var boxDef:b2PolygonDef;
		protected var body:b2Body;
		protected var nx:Number;
		protected var ny:Number;
		protected var nn:String;
		protected var n_width:Number;
		protected var n_height:Number;
		protected var n_static:Boolean;
		protected var n_name:String;
		protected var n_destroyable:Boolean;
		protected var n_restitution:Number;
		protected var n_friction:Number;
		
		protected var mousePVec:b2Vec2 = new b2Vec2();
		protected var foundN:Boolean = false;
		protected var NFound:b2Body = null;		
		
		protected var _interface_mc:MovieClip;
		protected var _endLevel_mc:MovieClip;
		protected var _timeDimension:MovieClip;
		protected var _cursor:MovieClip;
		
		
		protected var _levelAtual:uint = 1;
		
		
		public var checkVictory:Boolean;
		
		
		
		public function Jogo()
		{
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		protected function _init(p_e:Event):void
		{
			addEventListener(Event.ENTER_FRAME, Update);
			
			var worldAABB:b2AABB = new b2AABB();
				worldAABB.lowerBound.Set( -100.0, -100.0);
				worldAABB.upperBound.Set(100.0, 100.0);
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			var doSleep:Boolean = true;
			
			m_world = new b2World(worldAABB, gravity, doSleep);
			
			var NContact:b2ContactListener = new b2ContactListener();
			m_world.SetContactListener(NContact);
			
			
			
			// Criar a interface
			_interface_mc = new Interface();
			_interface_mc.x = 100;
			_interface_mc.reiniciar_bt.addEventListener(MouseEvent.MOUSE_DOWN, _onClickEndLevel);
			addChild(_interface_mc);
			
			var playerMusica:Musica = new Musica()
				playerMusica.x = 100;
			addChild(playerMusica);
			
			
			
			
			
			
			// Cursores
			_timeDimension = new TimeDimension();
			_cursor = new Cursor();
			_cursor.mouseEnabled = false;
			MovieClip(parent).addChild(_cursor);
			Mouse.hide();
			
			
			// Criar o Chão
			CreateBox(500, 564, 2000,  14, true, 'Chao', false, 0.3, 0.3, Decode('Chao', "iden"));
			
			
			// Inicio o temporizador
			_initTimer();
			
			
			// Verifico o password
			for (var i:uint = 0; i < SenhasNomes.SENHA.length; i++ )
			{
				var senha:String = MovieClip(parent.parent).password;
				if (senha == SenhasNomes.SENHA[i]) _levelAtual = i + 1; // +1 pelo array
			}
			
			// Inicio o Jogo
			_initLevel();
			
		}
		
		
		
		protected function _initLevel():void
		{
			CreateLevel(Level['L' + _levelAtual]);
			SWFAddress.setValue('fase' + String(_levelAtual));
			
			addChild(_interface_mc);
			
		}
		
		
		protected function _mouseEnable():void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, destroyBody);
		}
		protected function _mouseDisable():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, destroyBody);
		}
		
		
		protected function CreateLevel(LevelArray:Array)
		{
			for (var a:int = 0; a < LevelArray.length; a++)
			{
				for (var b:int = 0; b < 10; b++)
				{
					switch(b)
					{
						case 0:
						nx = LevelArray[a][b]
						break;
						
						case 1:
						ny = LevelArray[a][b]
						break;
						
						case 2:
						n_width = LevelArray[a][b]
						break;
						
						case 3:
						n_height = LevelArray[a][b]
						break;
						
						case 4:
						n_static = LevelArray[a][b]
						break;
						
						case 5:
						n_name = LevelArray[a][b]
						break;
						
						case 6:
						n_destroyable = LevelArray[a][b]
						break;
						
						case 7:
						n_restitution = LevelArray[a][b]
						break;
						
						case 8:
						n_friction = LevelArray[a][b]
						break;
						
						case 9:
						CreateBox(nx, ny, n_width, n_height, n_static, n_name, n_destroyable, n_restitution, n_friction, Decode(LevelArray[a][b], "iden"));
						break;
					}
				}
			}
			
			
			if (_levelAtual < 10)
			{
				_interface_mc.fase_txt.text = '0' + _levelAtual;
			}
			else
			{
				_interface_mc.fase_txt.text = _levelAtual;
			}
			
			_interface_mc.senha_txt.text = SenhasNomes.SENHA[_levelAtual - 1];
			_interface_mc.fase_txt.text = SenhasNomes.FASE[_levelAtual - 1]; // -1 para encaixar no array
			
			
			_mouseEnable();
			findN();
			
		}
		
		protected function CreateBox(x:Number, y:Number, width:Number, height:Number, static:Boolean, name:String, destroyable:Boolean, restitution:Number, friction:Number, Cover)
		{
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(GetB2Nums(width, true), GetB2Nums(height, true));
			if (!static)
			{
				boxDef.density = 1.0;
			}
			else
			{
				boxDef.density = 0.0;
			}
			boxDef.friction = friction;
			boxDef.restitution = restitution;
			bodyDef = new b2BodyDef();
			bodyDef.position.x = GetB2Nums(x, false);
			bodyDef.position.y = GetB2Nums(y, false);
			bodyDef.userData = Cover;
			bodyDef.userData.name = name;
			bodyDef.userData.destroyable = destroyable;
			bodyDef.userData.width = 30 * 2 * GetB2Nums(width, true);
			bodyDef.userData.height = 30 * 2 * GetB2Nums(height, true);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			addChild(bodyDef.userData);
			
		}
		
		protected function Decode(WTD:String, Encryption:String)
		{
			switch(Encryption)
			{
				case "iden":
				if (WTD == "Azul") 			{ return new Azul();	}
				if (WTD == "Marrom")		{ return new Marrom();	}
				if (WTD == "Roxo") 			{ return new Roxo();	}
				if (WTD == "Vermelho") 		{ return new Vermelho();}
				if (WTD == "Preto")			{ return new Preto(); 	}
				if (WTD == "Verde")			{ return new Verde();	}
				if (WTD == "Branco")		{ return new Branco();	}
				if (WTD == "Transparente")	{ return new Transparente(); }
				if (WTD == "Gelo")			{ return new Gelo(); }
				
				/*if (WTD == "Verde30x30") { return new Verde30x30();	}
				if (WTD == "Verde30x60") { return new Verde30x60(); }
				if (WTD == "Verde30x90") { return new Verde30x90();	}
				if (WTD == "Verde30x120") { return new Verde30x120(); }
				if (WTD == "Verde30x150") { return new Verde30x150(); }
				
				if (WTD == "Verde60x30") { return new Verde60x30();	}
				if (WTD == "Verde60x60") { return new Verde60x60();	}
				if (WTD == "Verde60x90") { return new Verde60x90();	}
				if (WTD == "Verde60x120") { return new Verde60x120(); }
				if (WTD == "Verde60x150") { return new Verde60x150(); }
				
				if (WTD == "Verde90x30") { return new Verde90x30();	}
				if (WTD == "Verde90x60") { return new Verde90x60();	}
				if (WTD == "Verde90x90") { return new Verde90x90();	}
				if (WTD == "Verde90x120") { return new Verde90x120(); }
				if (WTD == "Verde90x150") { return new Verde90x150(); }
				
				if (WTD == "Verde120x30") { return new Verde120x30(); }
				if (WTD == "Verde120x60") { return new Verde120x60(); }
				if (WTD == "Verde120x90") { return new Verde120x90(); }
				if (WTD == "Verde120x120") { return new Verde120x120(); }
				if (WTD == "Verde120x150") { return new Verde120x150(); }
				
				if (WTD == "Verde150x30") { return new Verde150x30(); }
				if (WTD == "Verde150x60") { return new Verde150x60(); }
				if (WTD == "Verde150x90") { return new Verde150x90(); }
				if (WTD == "Verde150x120") { return new Verde150x120(); }
				if (WTD == "Verde150x150") { return new Verde150x150(); }*/
				
				if (WTD == "Chao") 		{ return new Chao();	}
				if (WTD == "N") 		{ return new N(); 		}
				if (WTD == "Rio021") 	{ return new Rio021();	}
				if (WTD == "Rio021_90Graus") 	{ return new Rio021_90Graus();	}
				
				break;
			}
		}
		
		
		protected function destroyBody(evt:MouseEvent):void
		{
			var selectedShape = GetBodyAtMouse();
			if (selectedShape)
			{
				for (var i:uint = 0; i < 100; i++)
				{
					if (selectedShape.GetUserData().name == 'Box' + i)
					{
						var user = selectedShape.GetUserData().name;
						var susceptable = selectedShape.GetUserData().destroyable;
						var Child = getChildByName(user);
						if (selectedShape)
						{
							if (susceptable)
							{
								m_world.DestroyBody(selectedShape);
								removeChild(Child);
								Child = null;
								user = null;
								selectedShape = null;
								
								var efeitoExplosao = new Explosao();
									efeitoExplosao.x = mouseX;
									efeitoExplosao.y = mouseY;
								addChild(efeitoExplosao);
								
								_rechargeBomb();
								
							}
						}
						break;
					}
				}
			}
			
		}
		
		protected function GetBodyAtMouse(includeStatic:Boolean = false):b2Body
		{
			var mouseXWorldPhys = (mouseX)/30;
			var mouseYWorldPhys = (mouseY)/30;
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}
		
		protected function findN(includeStaticBodies:Boolean = false)
		{
			for (var tm:b2Body = m_world.m_bodyList; tm; tm = tm.m_next)
			{
				if (tm.m_userData is Sprite)
				{
					if (tm.m_userData.name == "N")
					{
						NFound = tm;
						break;
					}
				}
			}
		}
		
		protected function GetB2Nums(Num:Number, WH:Boolean)
		{
			switch(WH)
			{
				case true:
				return Num/30/2
				break;
				
				case false:
				return Num/30
				break;
			}
		}
		
		public function _checkingVictory():void
		{
			if (checkVictory)
			{
				if (NFound.IsSleeping())
				{
					checkVictory = false;
					NFound.GetUserData().play();
				}
			}
		}
		
		
		public function endLevel(p_resultado:String):void
		{
			_mouseDisable();
			
			
			switch(p_resultado)
			{
				case 'win':
					if (_levelAtual == 21)
					{
						Mouse.show();
						MovieClip(parent).removeChild(_cursor);
						
						
						SWFAddress.setValue('tela_final');
						
						MovieClip(parent.parent).endJogo(_interface_mc.minuto_txt.text, _interface_mc.segundo_txt.text);
					}
					else
					{
						_levelAtual++;
						_endLevel_mc = new ProximaFase();
					}
					break;
					
				case 'lose':
					// quando sai da tela e quebra fora da tela, para nao duplicar - fixme: antes de criar um _endlevel_mc verificar o existente
					if (!_endLevel_mc)
					{
						_endLevel_mc = new TentarNovamente();
					}
					break;
				
			}
			
			if (_endLevel_mc)
			{
				_endLevel_mc.x = 500;
				_endLevel_mc.y = 240;
				_endLevel_mc.alpha = .1;
				_endLevel_mc.scaleX = .1;
				_endLevel_mc.scaleY = .1;
				addChild(_endLevel_mc);
				
				Tweener.addTween(_endLevel_mc, { rotation:720, time:1, transition:'easeInBounce' } );
				Tweener.addTween(_endLevel_mc, { alpha:1, time:1, transition:'easeOutSine' } );
				Tweener.addTween(_endLevel_mc, { scaleX:1, time:1.4, transition:'easeOutBack' } );
				Tweener.addTween(_endLevel_mc, { scaleY:1, time:1.4, transition:'easeOutBack' } );
				
				_endLevel_mc.bt.addEventListener(MouseEvent.CLICK, _onClickEndLevel);
			}
			
		}
		
		
		protected function _onClickEndLevel(p_e:MouseEvent):void
		{
			// quando clicar no botao de reiniciar - fixme: antes de criar um _endlevel_mc verificar o existente
			if (_endLevel_mc)
			{
				removeChild(_endLevel_mc);
				_endLevel_mc = null;
			}
			_cleanLevel();
			_initLevel();
		}
		
		
		protected function _cleanLevel():void
		{
			var node:b2Body = m_world.GetBodyList();
			while (node)
			{
				var b:b2Body = node;
				var b_mc = b.GetUserData()
				node = node.GetNext();
				
				if (b_mc)
				{
					if (b_mc.name != 'Chao')
					{
						m_world.DestroyBody(b);
						removeChild(getChildByName(b_mc.name));
					}
				}
			}
			
		}
		
		
		
		protected function _rechargeBomb():void
		{
			_mouseDisable();
			addChild(_timeDimension);
			_cursor.alpha = 0;
			
			var rechargeTime:Timer = new Timer(500, 1);
				rechargeTime.addEventListener(TimerEvent.TIMER_COMPLETE, _bombRecharged);
				rechargeTime.start();
		}
		
		protected function _bombRecharged(p_e:TimerEvent):void
		{
			_mouseEnable();
			removeChild(_timeDimension);
			_cursor.alpha = 1;
		}
		
		
		protected function _initTimer():void
		{
			var timerUmSegundo:Timer = new Timer(1000, 5939);
				timerUmSegundo.addEventListener(TimerEvent.TIMER, _somarUmSegundo);
				timerUmSegundo.start();
			
		}
		
		protected function _somarUmSegundo(p_e:TimerEvent):void
		{
			_interface_mc.segundo_txt.text = int(_interface_mc.segundo_txt.text) + 1;
			
			if (_interface_mc.segundo_txt.text < 10)
			{
				_interface_mc.segundo_txt.text = '0' + _interface_mc.segundo_txt.text;
			}
			
			if (_interface_mc.segundo_txt.text == 60)
			{
				_interface_mc.segundo_txt.text = '00';
				_interface_mc.minuto_txt.text = int(_interface_mc.minuto_txt.text) + 1;
				if (_interface_mc.minuto_txt.text < 10)
				{
					_interface_mc.minuto_txt.text = '0' + _interface_mc.minuto_txt.text;
				}
			}
		}
		
		
		public function meRemova(p_quem):void
		{
			removeChild(p_quem);
			p_quem = null;
		}
		
		
		
		protected function Update(e:Event):void
		{
			m_world.Step(m_timeStep, m_iterations);
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next)
			{
				if (bb.m_userData is Sprite)
				{
					bb.m_userData.x = bb.GetPosition().x * 30;
					bb.m_userData.y = bb.GetPosition().y * 30;
					bb.m_userData.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}
			
			_checkingVictory();
			
			_cursor.x = mouseX;
			_cursor.y = mouseY;
			
			_timeDimension.x = mouseX;
			_timeDimension.y = mouseY;
			
			
			if (NFound.GetUserData().x > 1015 || NFound.GetUserData().x < -15)
			{
				if (!_endLevel_mc)
				{
					endLevel('lose');
				}
			}
			
		}
		
		protected var m_world:b2World;
		protected var m_timeStep:Number = GetB2Nums(1.0, false);
		protected var m_iterations:int = 10;
		
		
		
		
		
		
		
		
		
		
		
		
		
		public function set levelAtual(value:uint):void 
		{
			_levelAtual = value;
		}
		
		
		
		
	}
}