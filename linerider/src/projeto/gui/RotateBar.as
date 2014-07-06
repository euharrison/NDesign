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

    public class RotateBar extends MovieClip
    {

        /**************
         * Interface
         *************/
        public var bg:MovieClip;
        public var fill:MovieClip;
        public var track:MovieClip;
        public var mascara:MovieClip;

        public function RotateBar()
        {
            if(stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
		}

        private function init(e:Event = null):void
        {
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
            var endRot:Number = (mouseY / fill.height * 70 - 35) * -1;
            if(endRot < -35) endRot = -35;
            if(endRot > 35) endRot = 35;
            mascara.rotation = endRot;
            track.rotation = endRot;

            dispatchEvent(new Event(Event.CHANGE));
        }

        public function get progress():Number
        {
            return (track.rotation + 35) / 70;
        }
    }
}
