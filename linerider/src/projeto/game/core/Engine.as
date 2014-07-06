package projeto.game.core
{
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;

    import projeto.game.*;

    import seisd.display.Global;

    /**
	* Responsável pela integração com a física (Box2D)
	**/
	public class Engine
	{
		
		public var world:b2World;
		private var b2Scale:Number = 30;


		public var parede:b2Body;
		
		
		public function Engine()
		{
			var worldAABB:b2AABB = new b2AABB();
                worldAABB.lowerBound.Set(-200.0, -200.0);
                worldAABB.upperBound.Set(200.0, 200.0);
			
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			var doSleep:Boolean = true;
			
			world = new b2World(worldAABB, gravity, doSleep);

			// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			Game.cena.addChild(dbgSprite);
			dbgDraw.m_sprite = dbgSprite;
			dbgDraw.m_drawScale = 30.0;
			dbgDraw.m_fillAlpha = 0.0;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = 0xFFFFFFFF;
			//world.SetDebugDraw(dbgDraw);



            criarParedesWorld();
            world.SetContactListener(new EngineListener());


		}

        private function criarParedesWorld():void
        {
            var minDimension:Number = 5;
            var maxDimension:Number = 200;
            var distance:Number = maxDimension;

            var bodyDef:b2BodyDef = new b2BodyDef();
            parede = world.CreateBody(bodyDef);

			var shapeDef:b2PolygonDef = new b2PolygonDef();
                shapeDef.density = 0;

                shapeDef.SetAsOrientedBox(minDimension, maxDimension, new b2Vec2(distance, 0));
			    parede.CreateShape(shapeDef);
                shapeDef.SetAsOrientedBox(maxDimension, minDimension, new b2Vec2(0, distance));
			    parede.CreateShape(shapeDef);
                shapeDef.SetAsOrientedBox(minDimension, maxDimension, new b2Vec2(-distance, 0));
			    parede.CreateShape(shapeDef);
                shapeDef.SetAsOrientedBox(maxDimension, minDimension, new b2Vec2(0, -distance));
			    parede.CreateShape(shapeDef);

		    parede.SetMassFromShapes();

            //display
            var pixelDistance:Number = (distance - minDimension) * b2Scale;
            var mc:Sprite = new Sprite();
                mc.mouseChildren =
                mc.mouseEnabled = false;
                mc.graphics.lineStyle(1, 0x000000, 1, true);
                mc.graphics.moveTo(-pixelDistance, -pixelDistance);
                mc.graphics.lineTo(pixelDistance, -pixelDistance);
                mc.graphics.lineTo(pixelDistance, pixelDistance);
                mc.graphics.lineTo(-pixelDistance, pixelDistance);
                mc.graphics.lineTo(-pixelDistance, -pixelDistance);
            Game.cena.addChild(mc);

        }












		public function play():void
		{
            Global.stage.addEventListener(Event.ENTER_FRAME, _update, false, 0, true); //modo correto
		}
		
		public function pause():void
		{
            Global.stage.removeEventListener(Event.ENTER_FRAME, _update); //modo correto
		}
		




		
		
		
		public function desenharCaminhoBox2d(caminho:Caminho, largura:Number, centro:Point, anguloGraus:Number, type:uint):void
		{
			var shapeDef:b2PolygonDef;
                shapeDef = new b2PolygonDef();
                shapeDef.SetAsOrientedBox(largura / b2Scale / 2, 1 / b2Scale, new b2Vec2(centro.x / b2Scale, centro.y / b2Scale), anguloGraus * Math.PI / 180);
                shapeDef.friction = 0;
                shapeDef.density = 0;

			var bodyDef:b2BodyDef = new b2BodyDef();
			    bodyDef.position.Set(0, 0);

	        var body:b2Body = world.CreateBody(bodyDef);
                body.CreateShape(shapeDef);
                body.SetUserData(type);
			caminho.body = body;
		}

		public function removerCaminho(caminho:Caminho):void
		{
			if (caminho.body) world.DestroyBody(caminho.body);
		}
		
		






		private function _update(e:Event):void
		{
			world.Step(1/30, 10);

			// Go through body list and update sprite positions/rotations
			for (var bb:b2Body = world.m_bodyList; bb; bb = bb.m_next)
			{
				if (bb.m_userData is Sprite)
				{
					bb.m_userData.x = bb.GetPosition().x * 30;
					bb.m_userData.y = bb.GetPosition().y * 30;
					bb.m_userData.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}

            //TODO CRIAR UM SENSOR
			if (Game.levels.check && Game.state != 'die') Game.game.win();
		}


	}

}