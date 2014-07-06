/**
 * Created by IntelliJ IDEA.
 * User: Vamoss
 * Date: 24/06/11
 * Time: 22:14
 */
package projeto.gui
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import projeto.Config;

    public class PhotoContainer extends MovieClip
    {

        /**************
         * Interface
         *************/
        public var real:MovieClip;
        public var fake:MovieClip;
        public var btConfirm:SimpleButton;
        public var btCancel:SimpleButton;
        public var rotateBar:RotateBar;
        public var zoomBar:ZoomBar;

        private var photo:BitmapData;
        private var realBmp:Bitmap;
        private var fakeBmp:Bitmap;
        private var realContainer:Sprite;
        private var fakeContainer:Sprite;

        private var originMouse:Point;
        private var originPhoto:Point;
        private var draggable:Boolean;

        private const photoMask:Number = Config.photoSize;

        public function PhotoContainer()
        {
            if(stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
		}

        private function init(e:Event = null):void
        {
            btConfirm.addEventListener(MouseEvent.MOUSE_DOWN, photoConfirm);
            btCancel.addEventListener(MouseEvent.MOUSE_DOWN, photoCancel);

            zoomBar.addEventListener(Event.CHANGE, update);
            rotateBar.addEventListener(Event.CHANGE, update);
			
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);

            hideControls();
        }
		
		
		
		
		
		private function photoConfirm(e:MouseEvent):void 
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function photoCancel(e:MouseEvent):void 
		{
			face = null;
            dispatchEvent(new Event(Event.CANCEL));
		}
		
		
		

        private function mouseDown(event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);

            if (event.target == realContainer || event.target == fakeContainer)
            {
                draggable = true;
                originMouse = new Point(realContainer.mouseX,  realContainer.mouseY);
                originPhoto = new Point(realBmp.x, realBmp.y);
            }
        }

        private function mouseUp(event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);

            draggable = false;
        }

        private function mouseMove(event:MouseEvent):void
        {
            if(draggable)
            {
                realBmp.x = originPhoto.x + realContainer.mouseX - originMouse.x;
                realBmp.y = originPhoto.y + realContainer.mouseY - originMouse.y;

                //trace(realBmp.x,  realBmp.y,  realBmp.width, realBmp.height);

                //esse enquadramento tem que levar em consideracao a rotacao e a escala do realContainer
                //if(realBmp.x > - photoMask * .5) realBmp.x  = - photoMask * .5;
                //if(realBmp.y > - photoMask * .5) realBmp.y  = - photoMask * .5;
                //if(realBmp.x < - realBmp.width * .5 - photoMask * .5) realBmp.x  = - realBmp.width * .5 - photoMask * .5;
                //if(realBmp.y < - realBmp.height * .5 - photoMask * .5) realBmp.y  = - realBmp.height * .5 - photoMask * .5;

                fakeBmp.x = realBmp.x;
                fakeBmp.y = realBmp.y;
            }

        }

        public function update(event:Event = null):void
        {
            realContainer.scaleX = realContainer.scaleY = zoomBar.progress + .5;
            realContainer.rotation = rotateBar.progress * 180 - 90;

            fakeContainer.scaleX = fakeContainer.scaleY = realContainer.scaleX;
            fakeContainer.rotation = fakeContainer.rotation = realContainer.rotation;
        }
		
		
		
		

        public function set face(value:BitmapData)
        {
			if (photo) removePhoto();
			
            photo = value;

			if(value) addPhoto();
        }

        public function get face():BitmapData
        {
            return photo;
        }
		
		
		

        private function addPhoto():void
		{
            realBmp = new Bitmap(photo);
            fakeBmp = new Bitmap(photo);

            realBmp.smoothing = fakeBmp.smoothing = true;

            realBmp.height = fakeBmp.height = Config.photoSize + 20;
            realBmp.scaleX = fakeBmp.scaleX = realBmp.scaleY;


            fakeBmp.x = realBmp.x = -realBmp.width * .5;
            fakeBmp.y = realBmp.y = -realBmp.height * .5;

            fakeBmp.alpha = .3;

            realContainer = new Sprite();
            fakeContainer = new Sprite();

            realContainer.x = fakeContainer.x =
            realContainer.y = fakeContainer.y = photoMask/2;

            realContainer.addChild(realBmp);
            fakeContainer.addChild(fakeBmp);

            real.addChild(realContainer);
            fake.addChild(fakeContainer);
			
			showControls();
        }
		
        private function removePhoto():void
		{
            realContainer.removeChild(realBmp);
            fakeContainer.removeChild(fakeBmp);

            real.removeChild(realContainer);
            fake.removeChild(fakeContainer);
			
			hideControls();
        }
		
		
		
		
		private function showControls():void
		{
			btConfirm.visible =
			btCancel.visible =
            zoomBar.visible =
            rotateBar.visible = true;
		}
		
		private function hideControls():void
		{
			btConfirm.visible =
			btCancel.visible =
            zoomBar.visible =
            rotateBar.visible = false;
		}

    }
}
