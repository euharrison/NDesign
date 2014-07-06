/**
 * Created by IntelliJ IDEA.
 * User: Vamoss
 * Date: 24/06/11
 * Time: 22:14
 */
package projeto.gui
{
	/**
	 * Controlador do asset PhotoEditor na Library
	 * Quando o usuário completa a ediçao da photo, o PhotoEditor dispara o evento Event.COMPLETE
	 * e preenche a variável "photo" com o bitmapData
	 * e "photoName" com o nome da imagem no servidor
	 */

    import com.adobe.images.JPGEncoder;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Matrix;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.system.Security;
    import flash.utils.ByteArray;

    import projeto.Config;

    import seisd.social.FacebookInterface;
    import seisd.social.events.FacebookEvent;

    import seisd.utils.FileReferenceUtils;

    public class PhotoEditor extends MovieClip
    {

        /**************
         * Interface
         *************/
        public var photoContainer:PhotoContainer;
        public var btFacebook:MovieClip;
        public var btPhotoUpload:MovieClip;
        public var porcentagem:MovieClip;

        public var photo:BitmapData;
        public var photoName:String;
		
		private var fileUploader:FileReferenceUtils;
		private var fileSaver:URLLoader;
		private var fileLoader:Loader;

        private var facebook:FacebookInterface;

        public function PhotoEditor()
        {
            if(stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
		}

        private function init(e:Event = null):void
		{

            //remover o facebook temporariamente
            btFacebook.visible = false;

			btFacebook.buttonMode = true;
			btPhotoUpload.buttonMode = true;
			btFacebook.addEventListener(MouseEvent.CLICK, selectFacebookPhoto);
			btPhotoUpload.addEventListener(MouseEvent.CLICK, selectUploadPhoto);

			fileUploader = new FileReferenceUtils(Config.uploadScript, Config.uploadPathOriginais);
			fileUploader.addEventListener(FileReferenceUtils.ON_INIT, photoInit);
			fileUploader.addEventListener(FileReferenceUtils.ON_IMAGE_UPLOADED, photoUploaded);
			fileUploader.addEventListener(FileReferenceUtils.ON_PROGRESS, photoUploadProgress);
			fileUploader.addEventListener(FileReferenceUtils.ON_UPLOAD_ERROR, photoUploadError);
			
			fileLoader = new Loader();
			fileLoader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, photoLoadProgress );
			fileLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, photoLoaded );
			fileLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, photoLoadError );
			fileLoader.contentLoaderInfo.addEventListener( ErrorEvent.ERROR, photoLoadError );
			
			photoContainer.addEventListener( Event.COMPLETE, savePhoto );
			photoContainer.addEventListener( Event.CANCEL, saveCancel );

			facebook = new FacebookInterface('183434241717885', 'http://ndesign.org.br/2011/jogos/aondevocepensaquevai/', '183434241717885', '4f45352d19b6a4854266f116dff9fa03');
            facebook.addEventListener(FacebookEvent.FB_PROFILE_READY, facebookReady);

            hidePorcentagem();
        }






		
		
		//UI Buttons
		private function selectUploadPhoto(e:MouseEvent):void 
		{
			fileUploader.browse();
		}
		
		private function selectFacebookPhoto(e:MouseEvent):void 
		{
            facebook.init();
		}

        private function facebookReady(event:FacebookEvent):void
        {
            trace(facebook.getMyProfile())
        }






		//////////////////////////////////////////
        ///// UPLOAD IMAGEM CRUA PARA SERVER /////
        //////////////////////////////////////////

        private function photoInit(e:Event):void
        {
            showPorcentagem();
            porcentagem.texto.text = 'carregando...';
        }

		private function photoUploadProgress(e:Event):void
		{
			trace("UPLOADING", fileUploader.progress);
            porcentagem.texto.text = String(Math.floor(50 * fileUploader.progress)) + '%';
		}

		private function photoUploaded(e:Event):void
		{
			trace("UPLOADED", fileUploader.fileName);
			trace("LOAD", Config.urlPhotoOriginais + fileUploader.fileName);
			fileLoader.load( new URLRequest( Config.urlPhotoOriginais + fileUploader.fileName ) );
		}

		private function photoUploadError(e:Event):void
		{
			trace("ERROR UPLOADING");
            hidePorcentagem();
		}



		////////////////////////////////////////////////////
        ///// DOWNLOAD DA IMAGEM CARREGADA PREVIAMENTE /////
        ////////////////////////////////////////////////////]

		private function photoLoadProgress(e:ProgressEvent):void
		{
			trace("UPLOADING", e.bytesLoaded / e.bytesTotal);
            porcentagem.texto.text = String(Math.floor(50 * e.bytesLoaded / e.bytesTotal) + 50) + '%';
		}

		private function photoLoaded(e:Event):void 
		{
			trace("LOADED", fileLoader.content);
            photoContainer.face = Bitmap(fileLoader.content).bitmapData.clone();

            hideIcons();
            hidePorcentagem();
		}
		
		private function photoLoadError(e:*):void 
		{
			trace("ERROR LOADING");
            hidePorcentagem();
		}
		
		








		////////////////////////////////////////////////////
        ///// SALVAR NO BANCO O BITMAP APOS TRATAMENTO /////
        ////////////////////////////////////////////////////

        private function savePhoto(e:Event):void
        {
            // set up a new bitmapdata object that matches the dimensions of the captureContainer;
            var bmd:BitmapData = new BitmapData( Config.photoSize, Config.photoSize, true, 0xFFFFFFFF );

            // draw the bitmapData from the captureContainer to the bitmapData object;
            bmd.draw( photoContainer.real, new Matrix(), null, null, null, true );

            // jpeg or png export quality;
            var m_imageQuality:Number = 90;

            // create a new JPEG byte array with the adobe JPEGEncoder Class;
            var byteArray:ByteArray = new JPGEncoder( m_imageQuality ).encode( bmd );

            // create and store the image name;
            var fileName:String = getUniqueName() + ".jpg";

            // set up the request & headers for the image upload;
            var urlRequest : URLRequest = new URLRequest();
            urlRequest.url = Config.uploadScript + '?path=' + Config.uploadPathTratadas;
            urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
            urlRequest.method = URLRequestMethod.POST;
            urlRequest.data = UploadPostHelper.getPostData( fileName, byteArray );
            urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );

            // create the image loader & send the image to the server;
            fileSaver = new URLLoader();
            fileSaver.dataFormat = URLLoaderDataFormat.BINARY;
            fileSaver.addEventListener( Event.COMPLETE, saveComplete );
            fileSaver.addEventListener( IOErrorEvent.IO_ERROR, saveCancel );
            fileSaver.addEventListener( SecurityErrorEvent.SECURITY_ERROR, saveCancel );
            fileSaver.load( urlRequest );

            photo = bmd;
            photoName = fileName;

            showPorcentagem();
            porcentagem.texto.text = 'salvando...';
        }

        /**
        *	returns new string representing the month, day, hour, minute and millisecond of creation for use as the image name;
        */
        private function getUniqueName () : String
        {
            var d : Date = new Date();

            return d.getMonth() + 1 + '' + d.getDate() + '' + d.getHours() + '' + d.getMinutes() + ''  + d.getMilliseconds();
        }

		private function saveCancel(e:*):void
		{
			trace("PHOTO CANCEL", e);
			dispatchEvent(new Event(Event.CANCEL));

            showIcons();
            hidePorcentagem();
		}
		
		private function saveComplete(e:Event):void 
		{
			trace("PHOTO SAVED");
			dispatchEvent(new Event(Event.COMPLETE));

            hidePorcentagem();
		}
		






        /////////////////////
        ///// INTERFACE /////
        /////////////////////

        private function hideIcons():void
        {
            btFacebook.visible =
			btPhotoUpload.visible = false;
        }

        private function showIcons():void
        {
            btFacebook.visible =
			btPhotoUpload.visible = true;
        }

        private function hidePorcentagem():void
        {
			porcentagem.visible = false;
        }

        private function showPorcentagem():void
        {
            porcentagem.texto.text = '';
			porcentagem.visible = true;
        }


		


    }
}