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


package nummist.illusion.mixedreality
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	
	/**
	 * A producer of bitmap and projection data, as used by AbstractTracker
	 * subclasses and ARViewport.
	 * 
	 * @see AbstractTracker
	 * 
	 * @see ARViewport
	 * @flowerModelElementId _8JkUoKnjEeG8rNJMqBg6NQ
	 */
	public class PixelFeed
	{
		private var source_:DisplayObject;
		private var diagonalFOV_:Number;
		private var width_:uint;
		private var height_:uint;
		private var pixels_:ByteArray;
		private var bitmapData_:BitmapData;
		private var matrix_:Matrix = new Matrix();
		private var rect_:Rectangle;
		
		
		/**
		 * Creates a PixelFeed object with a specified source, diagonal FOV
		 * (field of view), width, and height. Typically, the source will be a
		 * Video object with an attached Camera object. In this case, the
		 * specified FOV represents the FOV of the physical camera. If FOV is
		 * not specified, it defaults to 0.4 * pi (72 degrees), which is a
		 * guestimated median for webcams. Width and height refer to an output
		 * resolution, as used by AbstractTracker subclasses that are
		 * instantiated with the PixelFeed object. These dimensions may differ
		 * from the width and height of the Camera object, Video object, or
		 * other source, yet the aspect ratios should match. If not specified,
		 * width and height default to 320x240.
		 * <br /><br />
		 * In general, the source may be any DisplayObject instance (not
		 * necessarily a Video object). It is recommended that the source and
		 * FOV should bear some relationship to a real or simulated camera in
		 * 3D space.
		 * 
		 * @param source The object to be drawn to bitmap each frame.
		 * 
		 * @param fov The bitmap's diagonal field of view, in radians.
		 * 
		 * @param width The bitmap's horizontal pixel resolution.
		 * 
		 * @param height The bitmap's vertical pixel resolution.
		 * 
		 * @throws ArgumentError if source is null or any other argument is
		 * non-positive.
		 * @flowerModelElementId _8Jmw4qnjEeG8rNJMqBg6NQ
		 */
		public function PixelFeed
		(
			source:DisplayObject,
			fov:Number=1.25663706143591729539, // 72 degrees
			width:uint=320,
			height:uint=240
		)
		{
			if (!source)
			{
				throw new ArgumentError("source must be non-null");
			}
			
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
			
			source_ = source;
			diagonalFOV_ = fov;
			width_ = width;
			height_ = height;
			
			bitmapData_ = new BitmapData(width, height);
			rect_ = new Rectangle(0, 0, width, height);
			
			source.addEventListener
			(
				Event.ENTER_FRAME, // type
				onSourceEnterFrame, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		
		/**
		 * The object to be drawn to bitmap each frame.
		 */
		public function get source():DisplayObject
		{
			return source_;
		}
		
		/**
		 * The bitmap's diagonal field of view, in radians.
		 */
		public function get diagonalFOV():Number
		{
			return diagonalFOV_;
		}
		
		/**
		 * The bitmap's horizontal pixel resolution.
		 */
		public function get width():uint
		{
			return width_;
		}
		
		/**
		 * The bitmap's vertical pixel resolution.
		 */
		public function get height():uint
		{
			return height_;
		}
		
		/**
		 * Pixel data of the latest source frame that has been drawn to bitmap.
		 */
		public function get pixels():ByteArray
		{
			// Rewind the file pointer.
			pixels_.position = 0;
			
			return pixels_;
		}
		
		
		/**
		 * @flowerModelElementId _8JpNJKnjEeG8rNJMqBg6NQ
		 */
		private function onSourceEnterFrame(event:Event):void
		{
			// Update the scaling matrix.
			matrix_.a = width / source.width;
			matrix_.d = height / source.height;
			
			// Draw the display object.
			bitmapData_.draw(source_, matrix_);
			
			// Expose the drawing's pixels.
			pixels_ = bitmapData_.getPixels(rect_);
		}
	}
}