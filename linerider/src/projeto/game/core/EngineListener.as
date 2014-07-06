/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 11/07/11
 * Time: 00:18
 * To change this template use File | Settings | File Templates.
 */
package projeto.game.core
{
    import Box2D.Collision.b2ContactPoint;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2ContactListener;

    import projeto.game.Game;

    public class EngineListener extends b2ContactListener
    {


	override public virtual function Add(point:b2ContactPoint):void
    {

        var b1:b2Body = point.shape1.GetBody();
        var b2:b2Body = point.shape2.GetBody();


        // bater no fim do mundo
        if (
            Game.engine.parede == b1 ||
            Game.engine.parede == b2
            )
        {
            Game.game.dieState();
            return;
        }


        // bater com a cabeca ou o tronco e quebrar
        for(var i:uint = 0; i < Game.personagem.bodyBrokeableList.length; i++)
        {
            if (
                (Game.personagem.bodyBrokeableList[i] == b1 && (b2.GetUserData() == Caminho.NORMAL || b2.GetUserData() == Caminho.ACELERADO)) ||
                (Game.personagem.bodyBrokeableList[i] == b2 && (b1.GetUserData() == Caminho.NORMAL || b1.GetUserData() == Caminho.ACELERADO))
                )
            {
                Game.game.dieState();
                return;
            }
        }


    }

    override public virtual function Persist(point:b2ContactPoint):void
    {
        var b1:b2Body = point.shape1.GetBody();
        var b2:b2Body = point.shape2.GetBody();

        //se for caminho acelerado
        if (
            b1.GetUserData() == Caminho.ACELERADO ||
            b2.GetUserData() == Caminho.ACELERADO
            )
        {
            if (Game.state != 'die') Game.personagem.bodyCarrinho.m_linearVelocity.Multiply(1.008);
        }
    }








    }
}
