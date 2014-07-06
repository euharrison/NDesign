/**
 * Created by IntelliJ IDEA.
 * User: Vamoss
 * Date: 24/06/11
 * Time: 22:14
 */
package seisd.utils
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;

    public class FileReferenceUtils extends EventDispatcher
    {
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const ON_INIT:String = 'onInit';
		public static const ON_PROGRESS:String = 'onProgress';
		public static const ON_UPLOAD_ERROR:String = 'onUploadError';
		public static const ON_IMAGE_UPLOADED:String = 'onImageUploaded';
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------
		
		private var m_fileName:String;
		private var m_uploadURL:URLRequest;
		private var m_downloadURL:URLRequest;
		private var m_download:FileReference;
        private var m_file:FileReference;		
		
		
		///Name of file uploaded/downloaded
		public var fileName:String;
		
		///Progress of uploading file
		public var progress:Number;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function FileReferenceUtils( uploadPHP:String, uploadPath:String ):void
		{
			m_uploadURL = new URLRequest( uploadPHP + '?path=' + uploadPath );			
			m_file = new FileReference();
			m_download = new FileReference();
            
			configureListeners( m_file, uploadSelectHandler );
			
			// simple listener for download complete;
			m_download.addEventListener( Event.SELECT, downloadCompleteHandler );
			
			super(this);
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		/**
		 * Select a photo, upload to sever and dispatch event ON_IMAGE_UPLOADED
		 * So, you can access the fileName property
		 */
		public function browse ():void
		{
			m_file.browse( getImageTypes() );
		}
		
		public function download ( inURL:String, inName:String ):void
		{
			m_downloadURL = new URLRequest( inURL )
			m_fileName = inName;
			
			fileName = m_fileName;
			
			m_download.download( m_downloadURL, m_fileName );
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		/**
		*	handlers for file upload ( complete set );	
		**/
		
		private function uploadSelectHandler ( e:Event ):void 
		{
            var file:FileReference = FileReference( e.target );
			
			m_fileName = file.name;
			
			fileName = m_fileName;
            
			file.upload( m_uploadURL );

			dispatchEvent( new Event( ON_INIT ) );
        }
		
		private function progressHandler ( e:ProgressEvent ):void 
		{
            var file:FileReference = FileReference( e.target );

			progress = normalize( e.bytesLoaded / e.bytesTotal );
			
			dispatchEvent( new Event( ON_PROGRESS ) );
        }
		
        private function uploadCompleteDataHandler ( e:DataEvent ):void 
		{
			dispatchEvent( new Event( ON_IMAGE_UPLOADED) );
        }
        
        private function ioErrorHandler ( e:IOErrorEvent ):void 
		{
			dispatchError( e );
        }       

		private function securityErrorHandler ( e:SecurityErrorEvent):void 
		{			
			dispatchError( e );
        }

		private function openHandler ( e:Event ):void {};
		
		private function cancelHandler ( e:Event ):void {};

        private function completeHandler ( e:Event ):void {};

		private function httpStatusHandler ( e:HTTPStatusEvent ):void {};
		
		/**
		*	handler for file download;
		**/
		private function downloadCompleteHandler ( e:Event ):void
		{
			trace( 'file download complete;' );
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
	
		private function dispatchError ( e:* ):void
		{
			trace( 'ERROR: ' + e );
		}	
		
		private function configureListeners ( inDispatcher:IEventDispatcher, inSelectHandler:Function ):void 
		{
            inDispatcher.addEventListener( Event.CANCEL, cancelHandler );
            inDispatcher.addEventListener( Event.COMPLETE, completeHandler );
            inDispatcher.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
            inDispatcher.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
            inDispatcher.addEventListener( Event.OPEN, openHandler );
            inDispatcher.addEventListener( ProgressEvent.PROGRESS, progressHandler );
            inDispatcher.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
            inDispatcher.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler );
			inDispatcher.addEventListener( Event.SELECT, inSelectHandler );
        }

		private function getImageTypes ():Array
		{
			return new Array( new FileFilter( "Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png" ) );
		}

		private function normalize ( inValue:Number ):Number
		{
			var v:Number = inValue;
			
			if ( v > 1 ) v = 1;
			if ( v < 0 ) v = 0;
			
			v = Number( v.toFixed( 3 ) );
			
			return v;
		}
	}
}