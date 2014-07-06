/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 16:43
 * To change this template use File | Settings | File Templates.
 */
package projeto.gui
{
    import flash.events.Event;

    import seisd.display.Global;
    import seisd.display.MovieClipBase;

    public class Background extends MovieClipBase
    {


        public function Background()
        {
        }

        override protected function onResize(e:Event = null):void
        {
            this.x = Global.width/2;
            this.y = Global.height/2;

            this.width = Math.max(1920, Global.width);
            this.height = Math.max(1000, Global.height);
        }

    }
}
