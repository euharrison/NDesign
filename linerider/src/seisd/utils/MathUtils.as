/**
 * Created by IntelliJ IDEA.
 * User: harrison
 * Date: 05/07/11
 * Time: 23:43
 * To change this template use File | Settings | File Templates.
 */
package seisd.utils
{
    public class MathUtils
    {

        public static function between(value:Number, minValue:Number, maxValue:Number):Number
        {
            return Math.min(maxValue, Math.max(minValue, value));
        }

    }
}
