/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 19/06/11
 * Time: 00:03
 * To change this template use File | Settings | File Templates.
 */
package projeto
{
    public class Config
    {


        public static const urlAbsoluta:String = 'http://www.ndesign.org.br/2011/jogos/aondevocepensaquevai/';
		
		//Database
        public static const urlGet:String = "php/get_caminho.php?id=";
        public static const urlSave:String = "php/save_caminho.php";
		
		//Photo Editor
		public static const uploadScript:String = "php/image.php";
		public static const urlPhotoOriginais:String = "upload/originais/";
		public static const urlPhotoTratada:String = "upload/tratadas/";
		public static const uploadPathOriginais:String = "../upload/originais/";
		public static const uploadPathTratadas:String = "../upload/tratadas/";
		public static const photoSize:int = 140;

        //social media
        public static const facebookTitle:String = 'Aonde você pensa que vai?';
        public static const facebookMessage:String = 'O último jogo do NRio, jogue e descubra!';
        public static const facebookImage:String = 'http://ndesign.org.br/2011/jogos/aondevocepensaquevai/images/facebook_icon.jpg';
        public static const twitterMessage:String = 'Aonde você pensa que vai? O último jogo do NRio, jogue e descubra!';


    }
}
