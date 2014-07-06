/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 15:49
 * To change this template use File | Settings | File Templates.
 */
package projeto.pages
{
    import flash.display.InteractiveObject;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import seisd.display.Global;
    import seisd.display.Page;

    public class Home extends Page
    {

        //stage
        public var jogo_bt:SimpleButton;
        public var fistaile_bt:SimpleButton;
        //public var vejaoutros_bt:InteractiveObject;


        public function Home()
        {
            initButtons();
        }

        private function initButtons():void
        {
            jogo_bt.addEventListener(MouseEvent.CLICK, clickJogo);

            fistaile_bt.useHandCursor = false;
            //fistaile_bt.addEventListener(MouseEvent.CLICK, clickFistaile);

            //vejaoutros_bt.addEventListener(MouseEvent.CLICK, clickVejaOutros);
        }

        private function clickJogo(event:MouseEvent):void
        {
             navPages.activate('conceito');
        }

        private function clickFistaile(event:MouseEvent):void
        {
             //navPages.activate('fistaile');
        }

        private function clickVejaOutros(event:MouseEvent):void
        {

        }





		override protected function onResize(e:Event = null):void
		{
            this.x = Global.width/2;
            this.y = 380;
		}



    }
}
