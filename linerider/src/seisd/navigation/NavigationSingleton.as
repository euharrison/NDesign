package seisd.navigation
{
	import flash.utils.getDefinitionByName;
	import seisd.navigation.Navigation;
	import seisd.navigation.core.NavigationEvent;
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class NavigationSingleton extends Navigation 
	{
		
		/**
		 * Um navigation com singletons como itens que são criados a medida que são ativados. Veja documentação do Navigation para mais informações.
		 * Atenção em como adicionar itens, veja a documentação do addItem() do NavigationSingleton.
		 * @param	config
		 */
		public function NavigationSingleton(config:Object = null)
		{
			super(config);
			addEventListener(NavigationEvent.ACTIVATED, createSingleton, false, 999);
		}
		
		/**
		 * @param	item Modelo: {name:"catalogo-fotos", className:"cliente.pages.CatalogoFotos"}
		 */
		override public function addItem(item:*):void 
		{
			super.addItem(item);
		}
		
		private function createSingleton(e:NavigationEvent):void 
		{
			if(Object(currentItem).hasOwnProperty('className'))
			{
				var ClassReference:Class = getDefinitionByName(currentItem.className) as Class;
				
				if (!(currentItem is ClassReference)) 
				{
					var instance = new ClassReference();
					
					if (currentItem.name != undefined) instance.name = currentItem.name;
					
					var index:uint = getItemIndex(currentItem);
					itemList[index] = instance;
					currentItem = instance;
				}
			}
		}
	}
	
}