/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 06/07/11
 * Time: 00:05
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.ui
{
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

import projeto.game.Game;

import seisd.display.Global;

public class ContadorFases extends Sprite
    {


        private var xml:XML;
        private var list:Array;



        public function ContadorFases()
        {
			xml = Game.levels.xml;
            list = [];

            createContadores();
            updateContadores();

            x = 20;
        }

        private function createContadores():void
        {
			for (var i:int = 0; i < xml.level.length(); i++)
            {
                var contador:MovieClip = new UmContador(); //library
                addChild(contador);

                list.push(contador);
            }
        }

        public function updateContadores():void
        {
			for (var i:int=0; i < list.length;i++)
            {
                var contador:MovieClip = list[i];
                    contador.y = 23 * i;

                if(i > Game.levels.currentLevel) contador.gotoAndStop('porvir')
                if(i < Game.levels.currentLevel) contador.gotoAndStop('concluido')

                if(i == Game.levels.currentLevel)
                {
                    contador.gotoAndStop('atual');
                    contador.texto.text = DialogBox.fillZero(Game.levels.currentLevel+1);
                }
            }
        }


    }
}
