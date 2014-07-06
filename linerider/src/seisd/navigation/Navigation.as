package seisd.navigation
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import seisd.navigation.core.NavigationEvent;
	import seisd.utils.ArrayUtils;
	
	
	/// @eventType	seisd.navigation.core.NavigationEvent.DEACTIVATED
	[Event(name = "deactivated", type = "seisd.navigation.core.NavigationEvent")] 
	
	/// @eventType	seisd.navigation.core.NavigationEvent.ACTIVATED
	[Event(name = "activated", type = "seisd.navigation.core.NavigationEvent")] 
	
	/// @eventType	seisd.navigation.core.NavigationEvent.ERROR_404
	[Event(name = "error404", type = "seisd.navigation.core.NavigationEvent")] 
	
	
	/**
	 * ...
	 * 
	 * TODO
	 * activateRandom
	 * history
	 * parent
	 * 
	 * 
	 * @author Harrison
	 */
	public class Navigation extends EventDispatcher
	{
		
		/// Retorna a lista de itens envolvidos com esta navegação
        public var itemList:Array = [];
		
		/// Retorna o item ativo
        public var currentItem:*;
		
		/// Retorna o próximo item a ser ativo quando se trabalha com delay
		public var nextItem:*;
		
		//Retorna o item ativado anteriormente ao currentItem;
		public var previousItem:*;
		
		/// Tempo (em segundos) de espera padrão entre o evento NavigationEvent.DEACTIVATED e o NavigationEvent.ACTIVATED
		public var delay:Number = 0;
		
		/// Boolean para ficar dando trace nas mudança
		public var verbose:Boolean;
		
		/// @private Boolean para impedir que haja novas ativações. Só há novas ativações se esta variável for false.
		private var _lock:Boolean;
		
		/// @private Variáveis que resolvem o SWFAddress
		private var swfaddressPrefix:String;
		private var internalChange:Boolean;
		private var autoResolve404:Boolean;
		
		
		/**
		 * Cria uma navegação, ou qualquer lista de itens que possuem apenas um item ativo por vez.
		 * @param	config Default: {delay:0, swfaddressPrefix:null, autoResolve404:false}
		 */
		public function Navigation(config:Object = null)
        {
			config = config || {}
			this.delay = (config.delay != undefined) ? config.delay : 0;
			this.autoResolve404 = (config.autoResolve404 != undefined) ? config.autoResolve404 : false;
			
			if (config.swfaddressPrefix != undefined)
			{
				this.swfaddressPrefix = config.swfaddressPrefix;
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, changeSWFAddress);
				
				if (autoResolve404) addEventListener(NavigationEvent.ERROR_404, resolve404);
			}
			
			addEventListener(NavigationEvent.ACTIVATED, propagateEvent);
			addEventListener(NavigationEvent.DEACTIVATED, propagateEvent);
        }
		
		/**
		 * Adiciona um item à navegação
		 * @param	eventDispatcher Um EventDispatcher para poder disparar os eventos de NavigationEvent.DEACTIVATED e NavigationEvent.ACTIVATED
		 */
		public function addItem(item:*):void
        {
			if (verbose) trace('(NAVIGATION) ADD: ' + ((item.name) ? item.name + ' ' : '') + item);
			itemList.push(item);
		}
		
		/**
		 * Impede que haja novas ativações. Usa-a com sabedoria. Não afeta quem já estiver no delay da ativação.
		 */
		public function lock():void
		{
			_lock = true;
		}
		
		/**
		 * Libera a navegação para novas ativações após ser chamada a função lock()
		 */
		public function unlock():void
		{
			_lock = false;
		}
		
		
		
		
		
		
		
		
		
		
		/////////////////////
		///// ATIVAÇÕES /////
		/////////////////////
		
		/**
		 * Ativa um item
		 * @param	nameOrItem O name (string) do item ou o próprio item
		 * @return Retorna true se houve a ativação
		 */
		public function activate(nameOrItem:*):Boolean
        {
			if (nameOrItem is String) 
			{
				return changeTo(getItem(nameOrItem));
			}
			else
			{
				return changeTo(nameOrItem);
			}
        }
		
		/**
		 * Desativa o item ativo, se houver.
		 * @return Retorna true se havia um item ativo e desativou
		 */
		public function deactivate():Boolean
		{
			return changeTo(null);
		}
		
		/**
		 * Ativa o primeiro item que foi adicionado na navegação
		 * @return true se houve a ativação
		 */
		public function activateFirst():Boolean
		{
			return changeTo(itemList[0]);
		}
		
		/**
		 * Ativa o próximo item da itemList. Se não houver nenhum ativado, ativa o primeiro
		 * @param	looping true para ir do último ao primeiro item fechando o clico de itens, bom para galerias de fotos
		 * @return Retorna true se houve a ativação, false se o item a ser ativado é o que já está ativado ou não existe
		 */
		public function activateNext(looping:Boolean = true):Boolean
		{	
			if (currentItem)
			{
				var next:uint = itemList.indexOf(currentItem) + 1;
				if (next > itemList.length - 1) 
				{
					if (looping) 
					{
						return changeTo(itemList[0]);
					}
					else
					{
						return false;
					}
				}
				else
				{
					return changeTo(itemList[next]);
				}
			}
			else
			{
				return changeTo(itemList[0]);
			}
		}
		
		/**
		 * Ativa o item anterior da itemList. Se não houver nenhum ativado, ativa o último se o looping for true
		 * @param	looping true para ir do último ao primeiro item fechando o ciclo de itens, bom para galerias de fotos
		 * @return Retorna true se houve a ativação, false se o item a ser ativado é o que já está ativado ou não existe
		 */
		public function activatePrevious(looping:Boolean = true):Boolean
		{
			if (currentItem)
			{
				if (currentItem == itemList[0])
				{
					if (looping) 
					{
						return changeTo(itemList[itemList.length - 1]);	
					}
					else
					{
						return false;
					}
				}
				else
				{
					var previous:uint = itemList.indexOf(currentItem) - 1;
					return changeTo(itemList[previous]);
				}
			}
			else
			{
				if (looping) 
				{
					return changeTo(itemList[itemList.length - 1]);
				}
				else
				{
					return false;
				}
			}
		}
		
		/**
		 * Ativa um item aleatório da itemList diferente do atual.
		 * @return true se houve a ativação
		 */
		public function activateRandom():Boolean 
		{
			var randomIndex:uint = Math.floor(Math.random() * itemList.length);
			
			if(currentIndex) 
			{
				while (randomIndex == currentItem) 
				{
					randomIndex = Math.floor(Math.random() * itemList.length);
				}
			}
			
			return changeTo(itemList[randomIndex]);
		}
		
		
		
		
		
		
		
		
		//////////////////////////
		///// ATIVAÇÕES CORE /////
		//////////////////////////
		
		/// @private Função chave da navegação. Troca um item respeitando os critérios da navegação. 
		private function changeTo(item:*):Boolean
		{
			if (_lock) return false;
			
			if (item == null) 
			{
				deactivateItem(currentItem);
				currentItem = null;
				return true;
			}
			else if (hasItem(item) && item != currentItem)
			{
				if (nextItem) 
				{
					if (verbose) trace('(NAVIGATION) NEXT: ' + ((item.name) ? item.name + ' ' : '') + item);
					nextItem = item;
				}
				else
				{
					if (currentItem) 
					{
						nextItem = item;
						deactivateItem(currentItem);
						
						if (delay) 
						{
							var timerToNext = new Timer(delay * 1000, 1);
								timerToNext.addEventListener(TimerEvent.TIMER_COMPLETE, activateWaitingItem);
								timerToNext.start();
						}
						else
						{
							activateItem(item);
						}
					}
					else
					{
						activateItem(item);
					}
				}
				
				return true;
			}
			else
			{
				return false;
			}
			
		}
		
		/// @private Desativa um item.
		private function deactivateItem(item:*):Boolean
		{
			if (hasItem(item))
			{
				if (verbose) trace('(NAVIGATION) DEACTIVATED: ' + ((item.name) ? item.name + ' ' : '') + item);
				
				if (swfaddressPrefix) setSWFAddress(swfaddressPrefix);
				dispatchEvent(new NavigationEvent(NavigationEvent.DEACTIVATED, this));
				
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/// @private Função de resposta após passar o delay da troca de item
		private function activateWaitingItem(e:TimerEvent):void 
		{
			activateItem(nextItem);
		}
		
		/// @private Ativa um item.
		private function activateItem(item:*):Boolean
		{
			if (hasItem(item))
			{
				if (verbose) trace('(NAVIGATION) ACTIVATED: ' + ((item.name) ? item.name + ' ' : '') + item);
				
				nextItem = null;
				previousItem = currentItem;
				currentItem = item;
				
				if (swfaddressPrefix) setSWFAddress(swfaddressPrefix + item.name);
				dispatchEvent(new NavigationEvent(NavigationEvent.ACTIVATED, this));
				
				return true;
			}
			else
			{
				return false;
			}
		}
		
		
		
		
		
		
		
		
		
		///////////////////////////////
		///// OUTRAS FUNÇÕES CORE /////
		///////////////////////////////
		
		/// @private Propaga o evento da navegação para o item em questão criando o flow da navegação.
		private function propagateEvent(e:NavigationEvent):void 
		{
			currentItem.dispatchEvent(e);
		}
		
		/// @private Função de troca do valor da URL do navegador sem disparar novos eventos.
		private function setSWFAddress(value:String):void 
		{
			internalChange = true
			SWFAddress.setValue(value);
			internalChange = false;
		}
		
		/// @private Listener do SWFAddress
		private function changeSWFAddress(e:SWFAddressEvent):void 
		{
			if (!internalChange) 
			{
				var possiblePrefix:String = SWFAddress.getValue().slice(1, swfaddressPrefix.length + 1);
				if (swfaddressPrefix == possiblePrefix)
				{
					var sufix:String = SWFAddress.getValue().slice(possiblePrefix.length + 1);
					if (sufix == '' && currentItem) 
					{
						if (verbose) trace('(NAVIGATION) SWFAddress: desativar');
						deactivate();
					}
					else if (sufix != currentItem.name) 
					{
						if (verbose) trace('(NAVIGATION) SWFAddress: ativar');
						activate(sufix);
					}
					else
					{
						if (verbose) trace('(NAVIGATION) SWFAddress: error 404');
						dispatchEvent(new NavigationEvent(NavigationEvent.ERROR_404, this));
					}
				}
			}
		}
		
		/// @private Função padrão para tratar erro 404. Ela retorna a URL do navegador para o item atual
		private function resolve404(e:NavigationEvent):void 
		{
			setSWFAddress(currentItem.name);
		}
		
		
		
		
		
		
		
		
		
		/////////////////
		///// ÚTEIS /////
		/////////////////
		
		/// Verifica se existe o item
		public function hasItem(item:*):Boolean
		{
			return ArrayUtils.has(item, itemList);
		}
		
		/// Retorna um item da itemList baseado no name dele ou null se o item não existir na itemList
		public function getItem(name:String):*
		{
			for each (var item in itemList) 
			{
				if (item.name && item.name == name) return item;
			}
			return null;
		}
		
		/// Retorna o index do item ou null se ele não existir
		public function getItemIndex(item:*):uint
		{
			return (hasItem(item)) ? itemList.indexOf(item) : null;
		}
		
		/// Retorna o index do currentItem
		public function get currentIndex():uint
		{
			return getItemIndex(currentItem);
		}
		
		
		
	}
	
}