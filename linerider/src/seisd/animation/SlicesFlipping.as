package seisd.animation
{
	import com.greensock.easing.Linear;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	
	/// @eventType	flash.events.Event.COMPLETE
	[Event(name = "complete", type = "flash.events.Event")] 
	
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class SlicesFlipping extends EventDispatcher
	{
		
		private var container:Sprite;
		private var timer:Timer;
		private var slicesToFlip:Array;
		private var nextIndex:uint;
		private var timeToFlip:Number;
		private var flipping:Boolean;
		
		
		/**
		 * Uma transição de diversos bitmaps que será fatiado em uma grid e flipado cada slice (quadrado)
		 * @param	container Um container para receber os slices
		 * @param	dataList Um array de BitmapData
		 * @param	rows A quantidade de linhas que deseja que o bitmap seja fatiado
		 * @param	cols A quantidade de colunas que deseja que o bitmap seja fatiado
		 */
		public function SlicesFlipping(container:Sprite, dataList:Array, rows:uint, cols:uint)
		{
			this.container = container;
			
			//variaveis comum das fatias (otimização)
			var sprite:Sprite;
			var bitmap:Bitmap;
			var slicedData:BitmapData;
			var totalCount:uint = 0;
			
			var boxWidth:Number = dataList[0].width / cols;
			var boxHeight:Number = dataList[0].height / rows;
			var halfBoxWidth:Number = boxWidth / 2;
			var halfBoxHeight:Number = boxHeight / 2;
			
			var perspectiveBase:PerspectiveProjection = new PerspectiveProjection();
				perspectiveBase.fieldOfView = 100;
			
			//loop para gerar as fatias
			for (var i:int = 0; i < rows; i++) 
			{
				for (var j:int = 0; j < cols; j++) 
				{
					//sprite container
					sprite = new Sprite();
					sprite.name = String(totalCount);
					sprite.x = (j * boxWidth) + halfBoxWidth;
					sprite.y = (i * boxHeight) + halfBoxHeight;
					container.addChild(sprite);
					
					perspectiveBase.projectionCenter = new Point(sprite.x, sprite.y)	
					sprite.transform.perspectiveProjection = perspectiveBase;
					
					//bitmaps
					for (var k:int = 0; k < dataList.length; k++) 
					{
						slicedData = new BitmapData(boxWidth, boxHeight);
						slicedData.copyPixels(dataList[k], new Rectangle((j * boxWidth), (i * boxHeight), boxWidth, boxHeight), new Point());
						
						bitmap = new Bitmap(slicedData, PixelSnapping.NEVER, true);
						bitmap.alpha = 0;
						bitmap.x = -halfBoxWidth;
						bitmap.y = -halfBoxHeight;
						sprite.addChild(bitmap);
					}
					
					totalCount++;
				}
			}
		}
		
		/**
		 * Executa uma transição com todas as slices
		 * @param	nextIndex O próximo índice, refere-se a ordenação do array de BitmapData na hora da criação do SlicesFlipping
		 * @param	delayBetweenEachFlip Tempo entre cada o flip de cada slice
		 * @param	timeToFlip Tempo para executar o Tween de flip
		 */
		public function flipAll(nextIndex:uint, delayBetweenEachFlip:Number = .5, timeToFlip:Number = .5):void
		{
			var arraySlices:Array = []
			for (var i:int = 0; i < container.numChildren; i++) 
			{
				arraySlices.push(i);
			}
			
			flipArray(arraySlices, nextIndex, delayBetweenEachFlip, timeToFlip);
		}
		
		/**
		 * O mesmo que o flipAll porém poderá controlar quais slices serão flipados
		 * @param	slicesToFlip Um array de ID de slices, o ID é definido na seguinte maneira: linha1_coluna1 -> ID = 0, linha1_coluna2 -> ID = 1, linha1_coluna3 -> ID = 2 ...
		 * @param	nextIndex
		 * @param	delayBetweenEachFlip
		 * @param	timeToFlip
		 */
		public function flipArray(slicesToFlip:Array, nextIndex:uint, delayBetweenEachFlip:Number = .5, timeToFlip:Number = .5):void
		{
			if (!flipping) 
			{
				flipping = true;
				
				this.slicesToFlip = slicesToFlip;
				this.nextIndex = nextIndex;
				this.timeToFlip = timeToFlip;
				
				timer = new Timer(delayBetweenEachFlip * 1000, slicesToFlip.length);
				timer.addEventListener(TimerEvent.TIMER, flipInOrder);
				timer.start();
			}
		}
		
		/**
		 * Dá stop no timer que libera o flip de cada slice. Os que estão em movimento continuarão em movimento.
		 * Libera para novos flips
		 */
		public function stopFlip():void
		{
			timer.stop();
			flipping = false;
		}
		
		private function flipInOrder(e:TimerEvent):void 
		{
			flip(slicesToFlip[(timer.currentCount - 1) % slicesToFlip.length]);
		}
		
		private function flip(sliceID:uint):void 
		{
			var slice:DisplayObject = container.getChildByName(String(sliceID));
			container.addChild(slice);
			
			var timeline:TimelineMax = new TimelineMax( { onComplete:completeFlip, onCompleteParams:[sliceID] } );
				timeline.append(new TweenMax(slice, timeToFlip / 2, { rotationY: -90, ease:Linear.easeIn, onComplete:nextFace, onCompleteParams:[slice] } ));
				timeline.append(new TweenMax(slice, timeToFlip / 2, { rotationY: 0, ease:Linear.easeOut, startAt: { rotationY:90 }} ));
			timeline.play();
		}
		
		private function nextFace(slice:Sprite):void 
		{
			for (var i:int = 0; i < slice.numChildren; i++) 
			{
				slice.getChildAt(i).alpha = 0;
			}
			
			slice.getChildAt(nextIndex).alpha = 1;
		}
		
		private function completeFlip(sliceID:uint):void 
		{
			if (sliceID == slicesToFlip[slicesToFlip.length - 1]) 
			{
				flipping = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
	}
	
}