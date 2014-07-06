package projeto.navigation
{
    import com.greensock.TweenMax;

    import com.greensock.easing.Cubic;

    import flash.display.DisplayObjectContainer;

    import projeto.game.Game;

    import seisd.display.Global;
    import seisd.navigation.core.NavigationEvent;
	import seisd.navigation.NavigationSingleton;
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class NavigationPages extends NavigationSingleton 
	{
		
		public var layerPages:DisplayObjectContainer;
		
		
		/**
		 * Navigation para páginas. Trabalha com singletons.
		 * @param	xmlConfig XML de configuração seguindo o modelo:
		 * <config>
		 * 		<page name="home" className="cliente.pages.ExamplePage" />
		 * 		<page name="catalogo" className="cliente.pages.ExamplePage" />
		 * 		<page name="contato" className="cliente.pages.ExamplePage" />
		 * </config>
		 * @param	layerPages Um container para as páginas que serão carregadas
		 * @param	config Object normal de configuração. Veja o Navigation para exemplos.
		 */
		public function NavigationPages(xmlConfig:XML, layerPages:DisplayObjectContainer, config:Object = null)
		{
			super(config);
			
			this.layerPages = layerPages;
			
			for (var i:int = 0; i < xmlConfig.page.length(); i++) 
			{
				addItem( { name:xmlConfig.page[i].@name, className: xmlConfig.page[i].@className } );
			}
			
			addEventListener(NavigationEvent.ACTIVATED, firstAddChild, false, 10);
			addEventListener(NavigationEvent.ACTIVATED, activated);
			addEventListener(NavigationEvent.DEACTIVATED, deactivated);
		}
		
		private function firstAddChild(e:NavigationEvent):void 
		{
			if (!currentItem.parent) 
			{
                currentItem.visible = false;
				layerPages.addChild(currentItem);
			}
		}

        private function activated(event:NavigationEvent):void
        {
            TweenMax.to(currentItem, 1, { autoAlpha:1 } );

            if (previousItem)
                TweenMax.fromTo(layerPages, 1, { y:-50 }, { y:0, ease:Cubic.easeOut, immediateRender:true } );
        }

        private function deactivated(event:NavigationEvent):void
        {
            delay = 1.1;
            TweenMax.to(currentItem, 1, { autoAlpha:0 } );
            TweenMax.to(layerPages, 1, { y:50, ease:Cubic.easeOut } );

            //anti-bug
            if (nextItem && nextItem.name == 'crieseupersonagem' && Game.game) nextItem = getItem('jogo');
        }
		
	}
	
}