/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 16:43
 * To change this template use File | Settings | File Templates.
 */
package projeto.gui
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import seisd.display.Global;
    import seisd.display.MovieClipBase;

    public class Footer extends MovieClipBase
    {


        //stage
        public var siteoficial_bt:MovieClip;


        public function Footer()
        {
            siteoficial_bt.buttonMode = true;
            siteoficial_bt.addEventListener(MouseEvent.CLICK, clickSiteOficial);
        }

        private function clickSiteOficial(event:MouseEvent):void
        {
            navigateToURL(new URLRequest('http://www.ndesign.org.br/2011'), '_blank');
        }

        override protected function onResize(e:Event = null):void
        {
            this.x = Global.width;
            this.y = Global.height;
        }


    }
}
