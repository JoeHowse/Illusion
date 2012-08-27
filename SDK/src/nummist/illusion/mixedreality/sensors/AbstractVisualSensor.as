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


package nummist.illusion.mixedreality.sensors
{
	/**
	 * A producer of pixel data and projection data, as used by AbstractTracker
	 * subclasses and other ISensorSubscriber implementations.
	 * 
	 * @see AbstractTracker
	 * @see ISensorSubscriber
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _hyB_ENnZEeG6Ia5yiOlRVA
	 */
	public class AbstractVisualSensor extends AbstractSensor
	{
		protected var diagonalFOV_:Number;
		protected var width_:uint;
		protected var height_:uint;
		
		/**
		 * Creates an AbstractVisualSensor object.
		 * <br /><br />
		 * Do not invoke this constructor; it is intended for use by subclasses
		 * only.
		 * 
		 * @param fov The pixel data's diagonal field of view, in radians.
		 * 
		 * @param width The pixel data's horizontal resolution.
		 * 
		 * @param height The pixel data's vertical resolution.
		 * 
		 * @throws ArgumentError if any argument is non-positive.
		 * 
		 * @flowerModelElementId _hyEbUNnZEeG6Ia5yiOlRVA
		 */
		public function AbstractVisualSensor
		(
			fov:Number=1.25663706143591729539, // 72 degrees
			width:uint=320,
			height:uint=240
		)
		{
			if (fov <= 0)
			{
				throw new ArgumentError("fov must be positive");
			}
			
			if (width <= 0)
			{
				throw new ArgumentError("width must be positive");
			}
			
			if (height <= 0)
			{
				throw new ArgumentError("height must be positive");
			}
			
			diagonalFOV_ = fov;
			width_ = width;
			height_ = height;
		}
		
		
		/**
		 * The pixel data's diagonal field of view, in radians.
		 */
		public function get diagonalFOV():Number
		{
			return diagonalFOV_;
		}
		
		/**
		 * The pixel data's horizontal resolution.
		 */
		public function get width():uint
		{
			return width_;
		}
		
		/**
		 * The pixel data's vertical resolution.
		 */
		public function get height():uint
		{
			return height_;
		}
	}
}