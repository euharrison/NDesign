/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 05/07/11
 * Time: 00:30
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui
{
    import com.greensock.TimelineMax;
    import com.greensock.TweenMax;

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import projeto.Config;
    import projeto.game.Game;

    import seisd.social.Share;

    public class DialogBox extends Sprite
    {


        //stage
        public var pergunta:MovieClip;
        public var transicao:MovieClip;
        public var last:MovieClip;


        public function DialogBox()
        {
            pergunta.visible = false;
            transicao.visible = false;
            last.visible = false;

			pergunta["jogar"].addEventListener(MouseEvent.CLICK, clickJogar);

			transicao["replay"].addEventListener(MouseEvent.CLICK, clickReplay);
			transicao["refazer"].addEventListener(MouseEvent.CLICK, clickRefazer);
			transicao["avancar"].addEventListener(MouseEvent.CLICK, clickAvancar);

			last["facebook"].addEventListener(MouseEvent.CLICK, _onClickFacebook);
			last["twitter"].addEventListener(MouseEvent.CLICK, _onClickTwitter);
			last["inscrevase"].addEventListener(MouseEvent.CLICK, _onClickInscrevase);
			last["recomecar"].addEventListener(MouseEvent.CLICK, _onClickRecomecar);
        }






        public function showPergunta():void
        {
            pergunta["texto"].text = Game.levels.pergunta;
			pergunta["numero"].text = fillZero(Game.levels.currentLevel+1);
            show(pergunta);
        }

        public function showTransicao():void
        {
			transicao["numero"].text = fillZero(Game.levels.currentLevel+1);
            show(transicao);
        }

        public function showLast():void
        {
            show(last);
        }




		private function show(mc:MovieClip):void
        {
            TweenMax.to(mc, .3, { autoAlpha:1 } );
		}

		private function hide(mc:MovieClip):void
        {
            TweenMax.to(mc, .3, { autoAlpha:0 } );
		}








        //////////////////
        //// PERGUNTA ////
        //////////////////

        private function clickJogar(event:MouseEvent):void
        {
			hide(pergunta);
			Game.game.drawState();
        }


        ///////////////////
        //// TRANSICAO ////
        ///////////////////

        private function clickReplay(event:MouseEvent):void
        {
			hide(transicao);
            Game.game.replay();
        }

        private function clickRefazer(event:MouseEvent):void
        {
			hide(transicao);
			Game.game.refazer();
        }

        private function clickAvancar(event:MouseEvent):void
        {
			hide(transicao);
			Game.game.avancar();
        }


        //////////////
        //// LAST ////
        //////////////

		private function _onClickFacebook(e:MouseEvent):void
		{
            Share.facebook(Config.urlAbsoluta, Config.facebookTitle, Config.facebookMessage, Config.facebookImage);
		}
		
		private function _onClickTwitter(e:MouseEvent):void
		{
            Share.twitter(Config.urlAbsoluta, Config.twitterMessage);
		}
		
		private function _onClickInscrevase(e:MouseEvent):void
		{
            navigateToURL(new URLRequest('http://ndesign.org.br/2011/2011/07/13/porque-vir-ao-ndesign/'), '_blank');
		}
		
		private function _onClickRecomecar(e:MouseEvent):void
		{
            navigateToURL(new URLRequest(Config.urlAbsoluta), '_self');
		}







        public static function fillZero(value:uint, length:uint = 3):String
        {
            var string:String = String(value);

            for (var i:uint = 1; i < length; i++)
                if (value < Math.pow(10, i)) string = '0' + string;

            return string;
        }















    }
}
