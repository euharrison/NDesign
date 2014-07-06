/**
 * Created by IntelliJ IDEA.
 * User: Vamoss
 * Date: 24/06/11
 * Time: 22:14
 */
package projeto.gui
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class ZoomBar extends MovieClip
    {

        /**************
         * Interface
         *************/
        public var bg:MovieClip;
        public var fill:MovieClip;
        public var track:MovieClip;
        public var mascara:MovieClip;

        public function ZoomBar()
        {
            if(stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
		}

        private function init(e:Event = null):void{
            this.addEventListener(MouseEvent.CLICK, click);
            this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        }

        private function click(event:MouseEvent):void
        {
            update();
        }

        private function mouseDown(event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
            this.addEventListener(Event.ENTER_FRAME, update);
        }

        private function mouseUp(event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
            this.removeEventListener(Event.ENTER_FRAME, update);
            update();
        }

        private function update(event:Event = null):void
        {
            var endX:Number = mouseX;
            if(endX < 0) endX = 0;
            if(endX > fill.width - track.width) endX = fill.width - track.width;
            mascara.width = endX;
            track.x = endX;

            dispatchEvent(new Event(Event.CHANGE));
        }

        public function get progress():Number
        {
            return track.x / (fill.width - track.width);
        }
    }
}
