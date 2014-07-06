/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 15:57
 * To change this template use File | Settings | File Templates.
 */
package projeto.pages
{
    import com.greensock.TweenMax;

    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import projeto.Main;
    import projeto.game.Game;
    import projeto.game.ui.personagens.Bike;
    import projeto.game.ui.personagens.CarrinhoCompras;
    import projeto.game.ui.personagens.Personagem;
    import projeto.game.ui.personagens.Skate;
    import projeto.game.ui.personagens.Treno;
    import projeto.gui.PhotoEditor;

    import seisd.display.Global;
    import seisd.display.Page;
    import seisd.form.Form;
    import seisd.form.core.FormItemType;
    import seisd.navigation.core.NavigationEvent;

    public class CrieSeuPersonagem extends Page
    {
		
		private var personagem:Personagem;
		private var coresPele:Array = [
				0xffffff,
				0xffc17e,
				0xfbe954,
				0x000000
				];
		private var cores:Array = [
				0xceda3a,
				0xfbe954,
				0xf9ef9f,
				0xffffff,
				0xbcbec0,
				0x6b6a6a,
				0x000000,
				0x00adee,
				0x69d2e7,
				0x69f3e5,
				0xb676ec,
				0xf62e8d,
				0xffc17e,
				0xa6cc44
				];
		

        //stage
        public var boxPreview:MovieClip;
        public var seletorCalca:MovieClip;
        public var seletorCamisa:MovieClip;
        public var seletorPele:MovieClip;
        public var seletorCabeca:MovieClip;
        public var seletorFoto:PhotoEditor;
        public var seletorPersonagem:MovieClip;
        public var nome_txt:TextField;
        public var next_bt:InteractiveObject;


        public function CrieSeuPersonagem()
        {
            initSeletorPersonagem();
            initSeletorCalca();
            initSeletorCamisa();
            initSeletorPele();
            initSeletorCabeca();
            initSeletorFoto();
            initNomeField();
            initNextButton();

            onResize();
        }

        private function initSeletorPersonagem():void
        {
            seletorPersonagem.skate.addEventListener(MouseEvent.CLICK, clickPersonagem);
            seletorPersonagem.bike.addEventListener(MouseEvent.CLICK, clickPersonagem);
            seletorPersonagem.treno.addEventListener(MouseEvent.CLICK, clickPersonagem);
            seletorPersonagem.carrinhocompras.addEventListener(MouseEvent.CLICK, clickPersonagem);

            Main.userInfo.tipo_carro = 'skate';
            updatePersonagem();
        }

		private function initSeletorCalca():void 
		{
			for (var i:int = 0; i < seletorCalca.numChildren; i++) 
			{
				var item:MovieClip = seletorCalca.getChildAt(i) as MovieClip;
					item.addEventListener(MouseEvent.CLICK, clickCorCalca);
					item.cor = cores[i];
				TweenMax.to(item, 0, { tint:item.cor } );
			}
			updateCor(0xffffff, 'calca');
		}
		
		private function initSeletorCamisa():void 
		{
			for (var i:int = 0; i < seletorCamisa.numChildren; i++) 
			{
				var item:MovieClip = seletorCamisa.getChildAt(i) as MovieClip;
					item.addEventListener(MouseEvent.CLICK, clickCorCamisa);
					item.cor = cores[i];
				TweenMax.to(item, 0, { tint:item.cor } );
			}
			updateCor(0xffffff, 'camisa');
		}
		
		private function initSeletorPele():void 
		{
			for (var i:int = 0; i < seletorPele.numChildren; i++)
			{
				var item:MovieClip = seletorPele.getChildAt(i) as MovieClip;
					item.addEventListener(MouseEvent.CLICK, clickCorPele);
					item.cor = coresPele[i];
				if (i != 0) TweenMax.to(item, 0, { tint:item.cor } );
			}
			updateCor(0xffffff, 'pele');
		}

        private function initSeletorCabeca():void
        {
            for (var i:int = 0; i < seletorCabeca.numChildren; i++)
			{
				var item:MovieClip = seletorCabeca.getChildAt(i) as MovieClip;
					item.addEventListener(MouseEvent.CLICK, clickCabeca);
			}
            updateCabeca('simples');
        }

        private function initSeletorFoto():void
        {
            seletorFoto.addEventListener(Event.COMPLETE, updateFoto);
            seletorFoto.addEventListener(Event.CANCEL, cancelFoto);
        }

        private function initNomeField():void
        {
            var form:Form = new Form('');
                form.add(nome_txt, FormItemType.ALPHABETIC_UPPERCASE);
        }
		
        private function initNextButton():void
        {
            next_bt.addEventListener(MouseEvent.CLICK, clickNext);
        }
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function clickCorCalca(e:MouseEvent):void 
		{
			updateCor(e.currentTarget.cor, 'calca');
		}
		
		private function clickCorCamisa(e:MouseEvent):void 
		{
			updateCor(e.currentTarget.cor, 'camisa');
		}
		
		private function clickCorPele(e:MouseEvent):void 
		{
			updateCor(e.currentTarget.cor, 'pele');
		}
		
		private function updateCor(cor:uint, local:String):void
		{
			switch (local) 
			{
				case 'calca':
					Main.userInfo.cor_calca = cor;
				break;
				case 'camisa':
					Main.userInfo.cor_camisa = cor;
				break;
				case 'pele':
					Main.userInfo.cor_pele = cor;
				break;
			}
			personagem.updateColor();
		}






		private function clickCabeca(e:MouseEvent):void
		{
			updateCabeca(e.currentTarget.name);
		}

        private function updateCabeca(cabeca:String):void
        {
			Main.userInfo.tipo_cabeca = cabeca;
			personagem.updateCabeca();
        }





        private function updateFoto(event:Event):void
        {
            Main.userInfo.imagem_cabeca = seletorFoto.photoName;
            personagem.updateFoto(seletorFoto.photo);
        }

        private function cancelFoto(event:Event):void
        {
            Main.userInfo.imagem_cabeca = '';
            personagem.updateFoto();
        }





        private function clickPersonagem(event:MouseEvent):void
        {
            Main.userInfo.tipo_carro = event.currentTarget.name;
            updatePersonagem();
        }

        private function updatePersonagem():void
        {
            if (personagem && personagem.parent) personagem.parent.removeChild(personagem);

            switch(Main.userInfo.tipo_carro)
            {
                case 'bike':
                    personagem = new Bike();
                break;
                case 'skate':
                    personagem = new Skate();
                break;
                case 'treno':
                    personagem = new Treno();
                break;
                case 'carrinhocompras':
                    personagem = new CarrinhoCompras();
                break;
            }

			personagem.x = boxPreview.x;
			personagem.y = boxPreview.y - (personagem.height/2) + (personagem.mcCabeca.height/2);
			//personagem.rotation = 15;
			addChild(personagem);

			personagem.updateColor();
			personagem.updateCabeca();
			personagem.updateFoto();

			TweenMax.fromTo(personagem, .3, { alpha:0 }, { alpha:1 } );
        }
		
		
		
		
		
		
		
        private function clickNext(event:MouseEvent):void
        {
			Main.personagem = personagem;
			Main.userInfo.nome = nome_txt.text;
			
            navPages.activate('jogo');
        }







		override protected function onResize(e:Event = null):void
		{
            this.x = Global.width/2;
            this.y = 380;
		}



    }
}
