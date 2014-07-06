package seisd.form
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import seisd.form.core.FormItem;
	import seisd.form.core.FormItemType;
	import seisd.form.core.FormularioEvent;
	
	
	
	
	/// @eventType	seisd.form.core.FormularioEvent.ERROR_VALIDATION
	[Event(name = "errorValidation", type = "seisd.form.core.FormularioEvent")] 
	
	/// @eventType	seisd.form.core.FormularioEvent.SEND_INIT
	[Event(name = "sendInit", type = "seisd.form.core.FormularioEvent")] 
	
	/// @eventType	seisd.form.core.FormularioEvent.SEND_ERROR
	[Event(name = "sendError", type = "seisd.form.core.FormularioEvent")] 
	
	/// @eventType	seisd.form.core.FormularioEvent.SEND_SUCCESS
	[Event(name = "sendSuccess", type = "seisd.form.core.FormularioEvent")] 
	
	
	
	/**
	 * ...
	 * @author Harrison
	 */
	public class Form extends EventDispatcher
	{
		
		/// Lista de FormItem para manipular os textfields
		public var itemList:Vector.<FormItem>;
		
		/// Textfields que o usuário preencheu errado
		public var invalidatedList:Vector.<FormItem>;
		
		/// Informação que será enviada.
		/// Para personalizar, utilize dataToSend.minhaVariavel = 'Qualquer informação' e receba no php $_POST['minhaVariavel']
		public var varsToSend:URLVariables;
		
		/// Verifica se o formulário está sendo enviado e ainda não deu resposta
		public var sending:Boolean;
		
		/// Boolean para ficar dando trace nas mudança
		public var verbose:Boolean;
		
		/// Botão de enviar
		private var _submitButton:InteractiveObject;
		
		/// Url de destino ao enviar.
		private var urlPHP:String;
		
		
		
		
		
		/**
		 * Cria um formulário e permite as funções mais comuns
		 * @param	urlPHP Url de destino ao enviar.
		 * Atenção aos textfield.name pois serão os valores recebidos pelo $_POST do php. Ex: textfield.name = 'mensagem' resultará em $_POST['mensagem']
		 * O php deve retornar "success=mail()" para ele poder validar a resposta do servidor. Caso contrário, sempre interpretará como enviado com sucesso.
		 */
		public function Form(urlPHP:String)
		{
			this.urlPHP = urlPHP;
			
			itemList = new Vector.<FormItem>();
			varsToSend = new URLVariables();
			
			addEventListener(FormularioEvent.ERROR_VALIDATION, errorValidation);
			addEventListener(FormularioEvent.SEND_INIT, sendInit);
			addEventListener(FormularioEvent.SEND_ERROR, sendError);
			addEventListener(FormularioEvent.SEND_SUCCESS, sendSuccess);
		}
		
		/**
		 * Adiciona um textfield ao form no formato de FormItem
		 * O texto padrão será pego pelo textfield.text. A quantidade de caracteres será pego pelo textfield.maxChars
		 * @param	field Textfield em questão.
		 * @param	type Tipo do campo, consulte a classe FormItemType para detalhes. O valor null permite a inserção de qualquer caracter
		 * @param	required Obrigatoriedade do campo ao enviar
		 */
		public function add(field:TextField, type:String = null, required:Boolean = true):void
		{
			itemList.push(new FormItem(field, type, required));
			
			field.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			field.addEventListener(FocusEvent.FOCUS_OUT, focusOut);
		}
		
		/**
		 * Habilita o tabindex dos fields
		 * @param	includeSubmitButton
		 */
		public function enableTabIndex(includeSubmitButton:Boolean = false):void 
		{
			for (var i:int = 0; i < itemList.length; i++) 
			{
				changeTabIndex(itemList[i].field, i);
			}
			if (includeSubmitButton) changeTabIndex(submitButton, itemList.length);
		}
		
		/**
		 * Desabilita o tabindex dos fields
		 */
		public function disableTabIndex():void 
		{
			for (var i:int = 0; i < itemList.length; i++) 
			{
				changeTabIndex(itemList[i].field, -1);
			}
			changeTabIndex(submitButton, -1);
		}
		
		/**
		 * Limpa todos os fields do form
		 */
		public function reset():void
		{
			for (var i:int = 0; i < itemList.length; i++) 
			{
				itemList[i].field.text = itemList[i].defaultText;
			}
		}
		
		
		
		
		
		
		
		
		
		
		//////////////////////////////////
		///// HANDLERS PARA OVERRIDE /////
		//////////////////////////////////
		
		/// Sobreponha. Handler quando houver erro de validação
		public function errorValidation(e:FormularioEvent):void { }
		
		/// Sobreponha. Handler quando iniciar o envio
		public function sendInit(e:FormularioEvent):void { }
		
		/// Sobreponha. Handler quando houver erro no envio
		public function sendError(e:FormularioEvent):void { }
		
		/// Sobreponha. Handler quando houver sucesso no envio
		public function sendSuccess(e:FormularioEvent):void { }
		
		
		
		
		
		
		
		
		
		//////////////////
		///// ENVIAR /////
		//////////////////
		
		/**
		 * Envia o formulário
		 * @param	e
		 */
		public function send(e:Event = null):void 
		{
			if (!sending) 
			{	
				if (!validate())
				{
					for (var j:int = 0; j < invalidatedList.length; j++) 
						if (verbose) trace('(FORM) Erro de validação em ' + invalidatedList[j].defaultText + ' (' + invalidatedList[j].field.name + ')');
						
					dispatchEvent(new FormularioEvent(FormularioEvent.ERROR_VALIDATION, invalidatedList));
				}
				else
				{
					//php vars
					for (var i:int = 0; i < itemList.length; i++) 
					{
						varsToSend[itemList[i].field.name] = itemList[i].field.text;
					}
					
					//php
					var urlMail:URLRequest = new URLRequest(urlPHP);
						urlMail.data = varsToSend;
						urlMail.method = URLRequestMethod.POST;
					
					//send
					var sendmail:URLLoader = new URLLoader();
						sendmail.addEventListener(IOErrorEvent.IO_ERROR, error);
						sendmail.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
						sendmail.addEventListener(Event.COMPLETE, success);
						sendmail.load(urlMail);	
					
					sending = true;
					
					if (verbose) trace('(FORM) Enviando...');
					dispatchEvent(new FormularioEvent(FormularioEvent.SEND_INIT));
				}
			}
		}
		
		private function error(e:ErrorEvent):void 
		{
			sending = false;
			
			if (verbose) trace('(FORM) Erro de envio: [' + e.type + '] ' + e);
			dispatchEvent(new FormularioEvent(FormularioEvent.SEND_ERROR, null, e));
		}
		
		private function success(e:Event):void 
		{
			sending = false;
			
			if (verbose) trace('(FORM) Sucesso ao enviar');
			
			var returned:URLVariables = new URLVariables(e.target.data);
			if (returned.success || !returned.hasOwnProperty('success')) 
			{
				dispatchEvent(new FormularioEvent(FormularioEvent.SEND_SUCCESS));
			}
			else
			{
				error(new ErrorEvent(ErrorEvent.ERROR, false, false, 'Erro na resposta da função mail() do php: ' + urlPHP));
			}
		}
		
		
		
		
		
		
		
		
		
		
		//////////////////////
		///// VALIDAÇÕES /////
		//////////////////////
		
		private function validate():Boolean 
		{
			invalidatedList = new Vector.<FormItem>();
			
			for (var i:int = 0; i < itemList.length; i++) 
			{
				if (!validateItem(itemList[i]))
				{
					invalidatedList.push(itemList[i]);
				}
			}
			
			return Boolean(invalidatedList.length == 0);
		}
		
		private function validateItem(item:FormItem):Boolean 
		{
			var ok:Boolean = true;
			
			if (item.required) 
			{
				ok = Boolean(item.field.text != item.defaultText && item.field.text != '')
				
				if (ok)
				{
					//expansível
					switch (item.type) 
					{
						case FormItemType.MAIL:
							var mailRegExp:RegExp = /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$/;
							ok = mailRegExp.test(item.field.text);
						break;
					}
				}
			}
			
			return ok;
		}
		
		
		
		
		
		
		
		////////////////////
		///// PRIVADOS /////
		////////////////////
		
		private function changeTabIndex(object:InteractiveObject, value:int):void
		{
			object.tabIndex = value;
			object.tabEnabled = Boolean(value != -1);
		}
		
		private function focusIn(e:FocusEvent):void 
		{
			var fieldFocused:TextField = e.currentTarget as TextField;
			for (var i:int = 0; i < itemList.length; i++) 
			{
				if (fieldFocused == itemList[i].field && fieldFocused.text == itemList[i].defaultText) 
				{
					fieldFocused.text = '';
				}
			}
		}
		
		private function focusOut(e:FocusEvent):void 
		{
			var fieldFocused:TextField = e.currentTarget as TextField;
			for (var i:int = 0; i < itemList.length; i++) 
			{
				if (fieldFocused == itemList[i].field && fieldFocused.text == '') 
				{
					fieldFocused.text = itemList[i].defaultText;
				}
			}
		}
		
		
		
		
		
		///////////////////////////
		///// GETTER E SETTER /////
		///////////////////////////
		
		/// Botão de enviar
		public function get submitButton():InteractiveObject { return _submitButton; }
		public function set submitButton(value:InteractiveObject):void 
		{
			if (value) 
			{	
				_submitButton = value;
				_submitButton.addEventListener(MouseEvent.CLICK, send);
				
				if (_submitButton is Sprite) 
				{
					Sprite(_submitButton).buttonMode = true;
					Sprite(_submitButton).mouseChildren = false;
				}
			}
		}
		
		
	}
	
}






