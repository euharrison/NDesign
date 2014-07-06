/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 15:52
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

    public class ComoJogar extends Page
    {

        //stage
        public var next_bt:InteractiveObject;
        public var back_bt:InteractiveObject;
        public var exemplos_bt:InteractiveObject;


        public function ComoJogar()
        {
            initButtons();
        }

        private function initButtons():void
        {
            next_bt.addEventListener(MouseEvent.CLICK, clickNext);
            exemplos_bt.addEventListener(MouseEvent.CLICK, clickExemplos);
        }

        private function clickNext(event:MouseEvent):void
        {
             navPages.activateNext();
        }

        private function clickExemplos(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://www.youtube.com/results?search_query=best+line+rider&aq=f'), '_blank');
        }





		override protected function onResize(e:Event = null):void
		{
            this.x = Global.width/2;
            this.y = 380;
		}



    }
}
