/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 19/06/11
 * Time: 00:36
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui.personagens
{
    import Box2D.Collision.Shapes.b2CircleDef;
    import Box2D.Collision.Shapes.b2MassData;
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Collision.Shapes.b2ShapeDef;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.Joints.b2Joint;
    import Box2D.Dynamics.Joints.b2RevoluteJointDef;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;

    import com.greensock.TweenMax;
    import com.greensock.loading.ImageLoader;
    import com.greensock.loading.LoaderMax;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;

    import projeto.Config;
    import projeto.Main;
    import projeto.game.Game;

    public class Personagem extends Sprite
    {

        protected var xInicial:Number;
        protected var yInicial:Number;
        protected var bodyList:Vector.<b2Body>;
        protected var jointList:Vector.<b2Joint>;

		
		//usado pelo game
		public var created:Boolean;
		public var mcCabeca:MovieClip;
		public var bodyCarrinho:b2Body;
		public var bodyBrokeableList:Vector.<b2Body>;

        //usado pelo startAt()
		public var espelhado:Boolean;
		public var espelharList:Array;

		
		//usado pelo "crie seu personagem"
		public var calcaList:Array;
		public var camisaList:Array;
		public var peleList:Array;



        public function Personagem()
        {

        }

		public function initBodys():void
		{
			//sobreescreva-me
		}
		
		public function createAt(xInicial:Number, yInicial:Number, espelhado:Boolean = false):void
		{
            created = true;
            this.espelhado = espelhado;

            for(var i:uint = 0; i < bodyList.length; i++)
            {
                bodyList[i].SetLinearVelocity(new b2Vec2());
                bodyList[i].SetAngularVelocity(0);
            }

            for(var j:uint = 0; j < espelharList.length; j++)
            {
                espelharList[j].scaleX = (espelhado) ? -1 : 1;
            }

            this.xInicial = xInicial;
            this.yInicial = yInicial;

            jointList = new Vector.<b2Joint>();

			//sobreescreva-me
		}

		public function destroy():void
		{
            created = false;

			destroyJoints();

            //TweenLite.delayedCall(5, Skatista(this).init, [500, 0]);
		}
		
		





		
		
		

        protected function createCircle(raio:Number, userData:*, density:Number = 1):b2Body
        {
            return createBody(raio, 0, userData, density, true);
        }

        protected function createSquare(width:Number, height:Number, userData:*, density:Number = 1):b2Body
        {
            return createBody(width, height, userData, density);
        }

        protected function createCarrinho(width:Number, height:Number, userData:*, density:Number = 90):b2Body
        {
            var body:b2Body = createBody(width, height, userData, density);
			
			for (var i:int = 0; i < 2; i++) 
			{
				var posX:Number = ((i == 0) ? ( -width / 2) : (width / 2)) / 30;
				
				var shapeDef:b2CircleDef = new b2CircleDef();
					shapeDef.localPosition = new b2Vec2(posX, 0);
					shapeDef.radius = (height/2) / 30;
					shapeDef.density = density;
					shapeDef.friction = 0;
				body.CreateShape(shapeDef);
			}

			body.SetMassFromShapes();

			return body;
        }

        protected function createBody(width:Number, height:Number, userData:*, density:Number = 1, isCircle:Boolean = false):b2Body
        {
			var bodyDef:b2BodyDef = new b2BodyDef();
                bodyDef.userData = userData;

			var shapeDef:b2ShapeDef;
                if (isCircle) {
                    shapeDef = new b2CircleDef();
                    b2CircleDef(shapeDef).radius = width / 30;
                }
                else {
                    shapeDef = new b2PolygonDef();
                    b2PolygonDef(shapeDef).SetAsBox(width / 2 / 30, height / 2 / 30);
                }
                shapeDef.density = density;
                shapeDef.friction = 0;

            var body:b2Body = Game.engine.world.CreateBody(bodyDef);
			    body.CreateShape(shapeDef);
			    body.SetMassFromShapes();

            return body;
        }

        protected function position(body:b2Body, x:Number, y:Number, rotation:Number = 0):void
        {
            body.SetXForm(new b2Vec2((xInicial + espelhe(x)) / 30, (yInicial + y) / 30), (espelhe(rotation) * Math.PI) / 180);
        }

        protected function createJoint(body1:b2Body, body2:b2Body, x:Number, y:Number, lowerAngle:Number = NaN, upperAngle:Number = NaN):void
        {
            var joint:b2RevoluteJointDef = new b2RevoluteJointDef();
                joint.Initialize(body1, body2, new b2Vec2((xInicial + espelhe(x)) / 30, (yInicial + y) / 30));

            if (lowerAngle || upperAngle)
            {
                if (espelhado)
                {
                    joint.upperAngle = espelhe(lowerAngle) / 180;
                    joint.lowerAngle = espelhe(upperAngle) / 180;
                }
                else
                {
                    joint.lowerAngle = lowerAngle / 180;
                    joint.upperAngle = upperAngle / 180;
                }
                joint.enableLimit = true;
            }

            jointList.push(Game.engine.world.CreateJoint(joint));
        }

        protected function destroyJoints():void
        {
            if (jointList)
            {
                for (var i:uint = 0; i < jointList.length; i++)
                {
                    Game.engine.world.DestroyJoint(jointList[i]);
                }
            }
        }









		protected function espelhe(n:Number):Number
		{
            if (espelhado) return -n;
            else return n;
		}















		public function updateColor():void
		{
            //algum bug com removeTint:false, por isso um modo mais passo-a-passo


			for each (var calcaItem:Sprite in calcaList)
            {
                var objCalca:Object =  { tint:Main.userInfo.cor_calca }
                if (Main.userInfo.cor_calca == 0xffffff) objCalca.removeTint = true;

				TweenMax.to(calcaItem, .2, objCalca);
            }

            for each (var camisaItem:Sprite in camisaList)
            {
                var objCamisa:Object =  { tint:Main.userInfo.cor_camisa }
                if (Main.userInfo.cor_camisa == 0xffffff) objCamisa.removeTint = true;

				TweenMax.to(camisaItem, .2, objCamisa);
            }

            for each (var peleItem:Sprite in peleList)
            {
                var objPele:Object =  { tint:Main.userInfo.cor_pele }
                if (Main.userInfo.cor_pele == 0xffffff) objPele.removeTint = true;

				TweenMax.to(peleItem, .2, objPele);
            }
		}

        public function updateCabeca():void
        {
            mcCabeca.gotoAndStop(Main.userInfo.tipo_cabeca);
        }

        public function updateFoto(bitmapData:BitmapData = null):void
        {
            while (mcCabeca.foto.numChildren > 0) mcCabeca.foto.removeChildAt(0);

            if (bitmapData)
            {
                var foto:Bitmap = new Bitmap(bitmapData, 'auto', true);
                    foto.height = 50;
                    foto.scaleX = foto.scaleY;
                    foto.x = -foto.width/2;
                    foto.y = -foto.height/2;
                mcCabeca.foto.addChild(foto);
            }
            else if (Main.userInfo.imagem_cabeca)
            {
                var url:String = Config.urlPhotoTratada + Main.userInfo.imagem_cabeca
                var imageLoader:ImageLoader = LoaderMax.getLoader(url);
                if (!imageLoader)
                {
                    imageLoader = new ImageLoader(url, { smoothing:true, height:50, width:50, scaleMode:'proportionalInside', centerRegistration:true });
                    imageLoader.load();
                }
                mcCabeca.foto.addChild(imageLoader.content);
            }
        }





    }
}
