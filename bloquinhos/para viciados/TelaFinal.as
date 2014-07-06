package 
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	
	
	public class  TelaFinal extends MovieClip
	{
		protected var minutos:String;
		protected var segundos:String;
		protected var textoInputDefault:String;
		
		public function TelaFinal(p_minutos:String, p_segundos:String)
		{
			
			minutos = p_minutos;
			segundos = p_segundos;
			
			
			addEventListener(Event.ADDED_TO_STAGE, _init)
			
			textoInputDefault = email_txt.text;
		}
		
		protected function _init(p_e:Event):void
		{
			tempo_gasto_txt.text = 'EM APENAS ' + minutos + ' MINUTOS E ' + segundos + ' SEGUNDOS.';
			
			email_txt.addEventListener(MouseEvent.CLICK, _onClickInput);
			enviar_bt.addEventListener(MouseEvent.CLICK, _onClickButton);
			download_bt.addEventListener(MouseEvent.CLICK, _onClickDownload);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		}
		
		protected function _enviarEmail():void
		{
			if (email_txt.text == 'E-mail cadastrado com sucesso.')
			{
			}
			else if (email_txt.text == '' || email_txt.text == textoInputDefault || email_txt.text == 'Antes de enviar, digite o e-mail.')
			{
				email_txt.text = 'Antes de enviar, digite o e-mail.';
			}
			else
			{
				var variaveis:URLVariables = new URLVariables();
					variaveis.email = email_txt.text;
					variaveis.minutos = minutos;
					variaveis.segundos = segundos;
				var php:URLRequest = new URLRequest('cadastrar.php');
					php.data = variaveis;
				
				sendToURL(php);
				
				email_txt.text = 'E-mail cadastrado com sucesso.';
				
			}
			
		}
		
		protected function _onClickInput(p_e:MouseEvent):void
		{
			email_txt.text = '';
		}
		
		protected function _onClickButton(p_e:MouseEvent):void
		{
			_enviarEmail();
		}
		
		protected function _onKeyDown(p_e:KeyboardEvent):void
		{
			if (p_e.keyCode == 13)
			{
				_enviarEmail();
			}
		}
		
		
		
		
		private function _onClickDownload(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest('premio_para_viciados_em_N021.zip'));
		}
		
		
		
		
	}
	
}