/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 15:51
 * To change this template use File | Settings | File Templates.
 */
package projeto.pages
{
    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import seisd.display.Global;
    import seisd.display.Page;

    public class Conceito extends Page
    {

        //stage
        public var next_bt:InteractiveObject;
        public var back_bt:InteractiveObject;
        public var tema_bt:InteractiveObject;
        public var video_bt:InteractiveObject;


        public function Conceito()
        {
            initButtons();
        }

        private function initButtons():void
        {
            next_bt.addEventListener(MouseEvent.CLICK, clickNext);
            tema_bt.addEventListener(MouseEvent.CLICK, clickTema);
            video_bt.addEventListener(MouseEvent.CLICK, clickVideo);
        }

        private function clickNext(event:MouseEvent):void
        {
             navPages.activateNext();
        }

        private function clickTema(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://ndesign.org.br/2011/o-evento/proposta/'), '_blank');
        }

        private function clickVideo(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://www.youtube.com/watch?v=PwG99yBLgw0'), '_blank');
        }





		override protected function onResize(e:Event = null):void
		{
            this.x = Global.width/2;
            this.y = 380;
		}



    }
}
