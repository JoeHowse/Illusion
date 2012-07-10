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


package nummist.illusion.graphics.lights
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.lights.DirectionalLight;
	
	import flash.geom.Vector3D;
	
	
	/**
	 * Static utility functions for creating lighting setups.
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _JtkjMLQLEeGR3Y9FTHwn1w
	 */
	public class LightingUtils
	{
		/**
		 * Creates an Object3D instance with three DirectionalLight instances
		 * as children. The lights are arranged in a conventional three-point
		 * lighting setup (key light, fill light, and rim light) with respect
		 * to a subject facing toward negative z.
		 * 
		 * @param keyLightOnRight <code>true</code> means that the x
		 * coordinates of the key light and rim light are positive, and the x
		 * coorinate of the fill light is negative. Conversely,
		 * <code>false</code> means that the x coordinates of the key light and
		 * rim light are negative, and the x coordinate of the fill light is
		 * positive.
		 */
		public static function newThreePointLighting
		(
			keyLightOnRight:Boolean = false
		)
		:Object3D
		{
			var keyLight:DirectionalLight = new DirectionalLight(0xffffff);
			var fillLight:DirectionalLight = new DirectionalLight(0xffffff);
			var rimLight:DirectionalLight = new DirectionalLight(0xffffff);
			
			keyLight.intensity = 0.8;
			fillLight.intensity = 0.2;
			rimLight.intensity = 0.8;
			
			var quarterPi:Number = 0.25 * Math.PI;
			var sixteenthPi:Number = 0.0625 * Math.PI;
			
			if (keyLightOnRight)
			{
				keyLight.rotationY = -quarterPi;
				keyLight.rotationZ = -sixteenthPi;
				
				fillLight.rotationY = quarterPi;
				
				rimLight.rotationY = -0.75 * Math.PI;
				rimLight.rotationZ = -sixteenthPi;
			}
			else
			{
				keyLight.rotationY = quarterPi;
				keyLight.rotationZ = sixteenthPi;
				
				fillLight.rotationY = -quarterPi;
				
				rimLight.rotationY = 0.75 * Math.PI;
				rimLight.rotationZ = sixteenthPi;
			}
			
			var lights:Object3D = new Object3D();
			lights.addChild(keyLight);
			lights.addChild(fillLight);
			lights.addChild(rimLight);
			
			return lights;
		}
	}
}