package seisd.navigation
{
	import com.greensock.TweenMax;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import org.cove.ape.Vector;
	import seisd.navigation.core.Navigation;
	import seisd.navigation.core.NavigationEvent;
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class Accordion extends Navigation
	{
		
		private var startPosition:Number;
		private var axis:String;
		private var direction:int;
		private var propsList:Vector.<ItemAccordionProps>;
		
		
		/**
		 * Cria uma Navegação como um acordeão, de abrir apenas um por vez e fechar os demais, tipo sanfona.
		 * Atenção ao addItemAccordion
		 * @param	axis 'x' para horizontal ou 'y' para vertical
		 * @param	direction 1 para crescer no sentido positivo e -1 para crescer no sentido negativo
		 */
		public function Accordion(axis:String = 'y', direction:int = 1, config:Object = null)
		{
			super(config);
			
			this.axis = axis;
			this.direction = direction;
			this.propsList = new Vector.<ItemAccordionProps>();
			
			addEventListener(NavigationEvent.ACTIVATED, organize);
			addEventListener(NavigationEvent.DEACTIVATED, organize);
		}
		
		/**
		 * Não utilize o addItem para trabalhar com o accordion, pois o accordion necessita de um botão.
		 * Utilize addItemAccordion()
		 * @param	item
		 */
		override public function addItem(item:*):void 
		{
			trace('Não utilize o addItem para trabalhar com o accordion, pois o accordion necessita de um botão. Utilize addItemAccordion()')
		}
		
		/**
		 * Função que substitui o addItem tradicional do Navigation
		 * Os itens devem ser montados assim: O item é o próprio container de um item com seu button dentro do container.
		 * Exemplo:
		 * - itemAsContainer
		 * └- button
		 * └- objetos que deseja esconder/mostrar
		 * @param	itemAsContainer
		 * @param	button
		 */
		public function addItemAccordion(itemAsContainer:DisplayObjectContainer, button:InteractiveObject):void
		{
			var item:DisplayObjectContainer = itemAsContainer;
			
			super.addItem(item);
			
			//propriedades
			var props:ItemAccordionProps = new ItemAccordionProps();
				props.item = item;
				props.button = button;
				props.openSize = (axis == 'y') ? item.height : item.width;
				props.closeSize = (axis == 'y') ? props.button.height : props.button.width;
			
			propsList.push(props);
			
			var contentMask = new Sprite();
				contentMask.graphics.beginFill(0);
				contentMask.graphics.drawRect(0, 0, item.width, item.height);
			
			(axis == 'y')
			? contentMask.height = props.closeSize
			: contentMask.width = props.closeSize
			
			item.mask = contentMask;
			item.addChild(contentMask)
			
			button.addEventListener(MouseEvent.CLICK, clickButton);
			if (button is Sprite) Sprite(button).buttonMode = true;
			
			// inicio
			if (!startPosition)
			{
				if (axis == 'x' && direction == 1) startPosition = item.x;
				if (axis == 'x' && direction == -1) startPosition = item.x + button.width;
				if (axis == 'y' && direction == 1) startPosition = item.y;
				if (axis == 'y' && direction == -1) startPosition = item.y + button.height;
			}
		}
		
		
		
		////////////////
		///// CORE /////
		////////////////
		
		/// @private Listener de click do botão
		private function clickButton(e:MouseEvent):void 
		{	
			for (var i:int = 0; i < propsList.length; i++) 
			{
				if (propsList[i].button == e.currentTarget) activate(propsList[i].item);
			}
		}
		
		/// @private Listener de qualquer evento da Navegeção. É quem reorganiza os itens
		private function organize(e:NavigationEvent):void 
		{
			var nextPosition:Number = startPosition;
			
			for (var i:int = 0; i < propsList.length; i++) 
			{
				var item:DisplayObjectContainer = propsList[i].item;
				var openSize:Number = propsList[i].openSize;
				var closeSize:Number = propsList[i].closeSize;
				
				if (direction == 1) 
				{
					(axis == 'y')
					? TweenMax.to(item, .5, { y:nextPosition, immediateRender:true } )
					: TweenMax.to(item, .5, { x:nextPosition, immediateRender:true } )
				}
				
				if (e.type == NavigationEvent.ACTIVATED && item == currentItem) 
				{
					(axis == 'y')
					? TweenMax.to(item.mask, .5, { height:openSize, immediateRender:true } )
					: TweenMax.to(item.mask, .5, { width:openSize, immediateRender:true } )
					
					nextPosition += (direction == 1) ? openSize : -openSize;
				}
				else
				{
					(axis == 'y')
					? TweenMax.to(item.mask, .5, { height:closeSize, immediateRender:true } )
					: TweenMax.to(item.mask, .5, { width:closeSize, immediateRender:true } )
					
					nextPosition += (direction == 1) ? closeSize : -closeSize;
				}
				
				if (direction == -1) 
				{
					(axis == 'y')
					? TweenMax.to(item, .5, { y:nextPosition, immediateRender:true } )
					: TweenMax.to(item, .5, { x:nextPosition, immediateRender:true } )
				}
			}
		}
		
		
		
		
	}
}


import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;

internal class ItemAccordionProps
{
	public var item:DisplayObjectContainer;
	public var button:InteractiveObject;
	public var openSize:Number;
	public var closeSize:Number;
}
