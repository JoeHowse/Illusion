/*

Copyright (c) 2012 Joseph Howse

This software is provided 'as-is', without any express or implied warranty. In
no event will the author be held liable for any damages arising from the use
of this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
that you wrote the original software. If you use this software in a product,
an acknowledgment in the product documentation would be appreciated but is
not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

Joseph Howse
josephhowse@nummist.com

*/


package nummist.illusion.core
{
	/**
	 * Static utility functions for crunching numbers.
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8AYjcKnjEeG8rNJMqBg6NQ
	 */
	public class MathUtils
	{
		/**
		 * Finds the smallest power-of-2 integer that is greater than or equal
		 * to the specified number.
		 * 
		 * @param n The number.
		 */
		public static function nextPowerOf2(n:Number):uint
		{
			var powerOf2:uint = 1;
			while (powerOf2 < n)
			{
				powerOf2 *= 2;
			}
			return powerOf2;
		}
		
		/**
		 * A value of <code>true</code> means the specified number is a
		 * power-of-2 integer.
		 * 
		 * @param n The number.
		 */
		public static function isPowerOf2(n:uint):Boolean
		{
			return (n == nextPowerOf2(n));
		}
		
		/**
		 * Converts the specified angle from degrees to radians.
		 * 
		 * @param degrees The angle in degrees.
		 */
		public static function toRadians(degrees:Number):Number
		{
			return degrees * 0.01745329251994329577;
		}
		
		/**
		 * Converts the specified angle from radians to degrees.
		 * 
		 * @param radians The angle in radians.
		 */
		public static function toDegrees(radians:Number):Number
		{
			return radians * 57.2957795130823208768;
		}
	}
}