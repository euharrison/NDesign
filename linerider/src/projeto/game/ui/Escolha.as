/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 17/07/11
 * Time: 23:53
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.text.TextField;
	import flash.text.TextFormat;

    public class Escolha extends Sprite
    {

        public static const RAIO:Number = 33;


        public var value:String
        public var label:TextField;
        public var hit:MovieClip;

        public function Escolha()
        {
        }

        public function setLabel(text:String):void
        {
            if (label)
            {
                label.autoSize = 'center';
                label.htmlText = text;

                if (text.indexOf('-') != -1 || text.indexOf(' ') != -1)
                {
                    label.htmlText = label.text.replace(' ', '<br />');
                    label.htmlText = label.text.replace('-', '-<br />');
                    label.y -= 7;
                }
				
				if (text.length < 4) 
				{
					label.scaleX = 
					label.scaleY = 1.7;
					
					label.x = -label.width / 2;
					label.y = (-label.height / 2) + 2;//2 de ajuste visual
				}
				
				
            }
        }

    }
}
