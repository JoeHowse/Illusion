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
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.logging.Log;
	
	import nummist.illusion.logic.ILogicalStatement;
	
	
	/**
	 * A producer of pixel data and projection data, as used by AbstractTracker
	 * subclasses and ARViewport.
	 * 
	 * @see AbstractTracker
	 * 
	 * @see ARViewport
	 * 
	 * @flowerModelElementId _8JkUoKnjEeG8rNJMqBg6NQ
	 */
	public class PixelFeed
	{
		/**
		 * A condition that must be true in order for the pixel data to be
		 * updated. If the condition is <code>null</code> (the default), the
		 * pixel data is updated every frame.
		 */
		public var redrawCondition:ILogicalStatement;
		
		
		private var source_:DisplayObject;
		private var diagonalFOV_:Number;
		private var width_:uint;
		private var height_:uint;
		private var didRedraw_:Boolean;
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
		 * @param source The object whose pixel data is to be captured.
		 * 
		 * @param fov The pixel data's diagonal field of view, in radians.
		 * 
		 * @param width The pixel data's horizontal resolution.
		 * 
		 * @param height The pixel data's vertical resolution.
		 * 
		 * @param transparent A value of <code>true</code> means the pixel data
		 * shall preserve transparency.
		 * 
		 * @throws ArgumentError if source is <code>null</code> or fov, width,
		 * or height is non-positive.
		 * 
		 * @flowerModelElementId _8Jmw4qnjEeG8rNJMqBg6NQ
		 */
		public function PixelFeed
		(
			source:DisplayObject,
			fov:Number = 1.25663706143591729539, // 72 degrees
			width:uint = 320,
			height:uint = 240,
			transparent:Boolean = false
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
			
			bitmapData_ = new BitmapData(width, height, transparent);
			rect_ = new Rectangle(0, 0, width, height);
			
			source.addEventListener
			(
				Event.EXIT_FRAME, // type
				onSourceExitFrame, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		
		/**
		 * The object whose pixel data is being captured.
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
		 * A value of <code>true</code> means the pixel data was updated at the
		 * most recent opportunity (either the current or previous frame).
		 */
		public function get didRedraw():Boolean
		{
			return didRedraw_;
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
		private function onSourceExitFrame(event:Event):void
		{
			if (redrawCondition && !redrawCondition.toBoolean())
			{
				// Unset the redraw flag and pass.
				didRedraw_ = false;
				return;
			}
			// Set the redraw flag.
			didRedraw_ = true;
			
			// Update the scaling matrix.
			matrix_.a = width / source.width;
			matrix_.d = height / source.height;
			
			// Draw the display object.
			bitmapData_.drawWithQuality
			(
				source_, // source
				matrix_, // matrix
				null, // colorTransform
				null, // blendMode
				null, // clipRect
				false, // smoothing
				StageQuality.LOW // quality
			);
			
			// Expose the drawing's pixels.
			pixels_ = bitmapData_.getPixels(rect_);
		}
	}
}