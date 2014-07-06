/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 18/06/11
 * Time: 15:52
 * To change this template use File | Settings | File Templates.
 */
package projeto.pages
{
    import projeto.game.Game;

    import seisd.display.Page;

    public class Jogo extends Page
    {


        public function Jogo()
        {
            addChild(new Game());
        }

    }
}
