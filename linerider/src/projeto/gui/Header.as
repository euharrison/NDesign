/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 16:43
 * To change this template use File | Settings | File Templates.
 */
package projeto.gui
{
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import projeto.Config;
    import projeto.Main;

    import seisd.display.Global;
    import seisd.display.MovieClipBase;
    import seisd.social.Share;

    public class Header extends MovieClipBase
    {


        //stage
        public var fundo:MovieClip;
        public var home_bt:InteractiveObject;
        public var twitter_bt:InteractiveObject;
        public var facebook_bt:InteractiveObject;
        public var ondeseraon2011_bt:InteractiveObject;
        public var oqueeon021_bt:InteractiveObject;
        public var paraviciados_bt:InteractiveObject;


        public function Header()
        {
            initButtons();
        }

        override protected function onResize(e:Event = null):void
        {
            this.x = Global.width/2;
            fundo.width = Global.width;
        }

        private function initButtons():void
        {
            home_bt.addEventListener(MouseEvent.CLICK, clickHome);
            twitter_bt.addEventListener(MouseEvent.CLICK, clickTwitter);
            facebook_bt.addEventListener(MouseEvent.CLICK, clickFacebook);
            ondeseraon2011_bt.addEventListener(MouseEvent.CLICK, clickOndeSeraON2011);
            oqueeon021_bt.addEventListener(MouseEvent.CLICK, clickOQueEON021);
            paraviciados_bt.addEventListener(MouseEvent.CLICK, clickParaViciados);
        }

        private function clickHome(event:MouseEvent):void
        {
            //navigateToURL(new URLRequest('http://www.ndesign.org.br/2011'), '_blank');
            projeto.Main.main.navPages.activate('home');
        }

        private function clickTwitter(event:MouseEvent):void
        {
            Share.twitter(Config.urlAbsoluta, Config.twitterMessage);
        }

        private function clickFacebook(event:MouseEvent):void
        {
            Share.facebook(Config.urlAbsoluta, Config.facebookTitle, Config.facebookMessage, Config.facebookImage);
        }

        private function clickOndeSeraON2011(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://ndesign.org.br/2011/jogos/ondeseraon021/'), '_blank');
        }

        private function clickOQueEON021(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://ndesign.org.br/2011/jogos/oqueeon021/'), '_blank');
        }

        private function clickParaViciados(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://apps.facebook.com/nrio-paraviciados/'), '_blank');
        }


    }
}
