package
projeto.game.core{
    import projeto.game.*;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;

import projeto.Config;

public class Database extends EventDispatcher
    {
        public static const GET_CAMINHO_COMPLETE:String = "get_caminho_complete";
        public static const GET_CAMINHO_ERROR:String = "get_caminho_error";
        public static const SAVE_CAMINHO_COMPLETE:String = "save_caminho_complete";
        public static const SAVE_CAMINHO_ERROR:String = "save_caminho_error";

        private var loaderGet:URLLoader;
        private var loaderSave:URLLoader;

        private var userInfo:UserInfo;


        public function Database()
        {

        }

        /**
         * Get xml based on id and return the GET_CAMINHO_COMPLETE Event
         * @param id
         */
        public function getCaminho(id:String):void
        {
            var vars:URLVariables = new URLVariables();
            vars.id = id;

            var request:URLRequest = new URLRequest(Config.urlGet);
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.VARIABLES;
            request.data = vars;
            request.method = URLRequestMethod.GET;
            loader.addEventListener(Event.COMPLETE, getCaminhoComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, getCaminhoIOError);
            loader.load(request);
        }

        private function getCaminhoComplete(event:Event):void
        {
            loaderGet = URLLoader(event.target);
            if(loaderGet.data.err=="true"){
                dispatchEvent(new Event(Database.GET_CAMINHO_ERROR));
            } else{
                userInfo.nome             = loaderGet.data.nome;
                userInfo.cor_camisa       = loaderGet.data.cor_camisa;
                userInfo.cor_pele         = loaderGet.data.cor_pele;
                userInfo.cor_calca        = loaderGet.data.cor_calca;
                userInfo.imagem_cabeca    = loaderGet.data.imagem_cabeca;
                userInfo.tipo_cabeca      = loaderGet.data.tipo_cabeca;
                userInfo.tipo_carro       = loaderGet.data.tipo_carro;
                userInfo.caminho          = loaderGet.data.caminho;

                dispatchEvent(new Event(Database.GET_CAMINHO_COMPLETE));
            }
        }

        private function getCaminhoIOError(event:IOErrorEvent):void
        {
            dispatchEvent(new Event(Database.GET_CAMINHO_ERROR));
        }

        /**
         * Retorna o objeto userInfo após ter chamado o evento CAMINHO_COMPLETE
         * @return projeto.game.core.UserInfo
         */
        private function getUserInfo():UserInfo
        {
            return userInfo;
        }


        /**
         * Post vars to database and return the SAVE_CAMINHO_COMPLETE Event
         * @param vars
         */
        public function saveCaminho(userInfo:UserInfo):void
        {
            var vars:URLVariables = new URLVariables();
            vars.nome           = userInfo.nome;
            vars.cor_camisa     = userInfo.cor_camisa.toString(16); //converte uint para string
            vars.cor_pele       = userInfo.cor_pele.toString(16);
            vars.cor_calca      = userInfo.cor_calca.toString(16);
            vars.imagem_cabeca  = userInfo.imagem_cabeca;
            vars.tipo_cabeca    = userInfo.tipo_cabeca;
            vars.tipo_carro     = userInfo.tipo_carro;
            vars.caminho        = userInfo.caminho;

            var request:URLRequest = new URLRequest(Config.urlSave);
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.VARIABLES;
            request.data = vars;
            request.method = URLRequestMethod.POST;
            loader.addEventListener(Event.COMPLETE, saveCaminhoComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, saveCaminhoIOError);
            loader.load(request);
        }


        private function saveCaminhoComplete(event:Event):void
        {
            loaderSave = URLLoader(event.target);
            if(loaderSave.data.err=="true"){
                dispatchEvent(new Event(Database.SAVE_CAMINHO_ERROR));
            } else{
                dispatchEvent(new Event(Database.SAVE_CAMINHO_COMPLETE));
            }
        }

        private function saveCaminhoIOError(event:IOErrorEvent):void
        {
            dispatchEvent(new Event(Database.SAVE_CAMINHO_ERROR));
        }

        /**
         * Return the saved id
         */
        public function get id():int
        {
            if(!loaderSave){
                return 0;
            }else{
                return int(loaderSave.data.id);
            }
        }

        /**
         * Return the link to share
         */
        public function get shareLink():String
        {
            if(!loaderSave){
                return "";
            }else{
                return Config.urlAbsoluta + "?caminho=" + id;
            }
        }
	}
}