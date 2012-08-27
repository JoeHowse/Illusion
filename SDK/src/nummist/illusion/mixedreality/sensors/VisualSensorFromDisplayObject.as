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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.utils.ByteArray;
	
	
	/**
	 * A producer of pixel data and projection data, as used by AbstractTracker
	 * subclasses, other ISensorSubscriber implementations, and
	 * ARViewportUsingStage.
	 * 
	 * @see AbstractTracker
	 * 
	 * @see ARViewportUsingStage
	 * 
	 * @see ISensorSubscriber
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8JkUoKnjEeG8rNJMqBg6NQ
	 */
	public class VisualSensorFromDisplayObject extends AbstractVisualSensor
	{
		private var source_:DisplayObject;
		private var bitmapData_:BitmapData;
		private var matrix_:Matrix = new Matrix();
		private var rect_:Rectangle;
		
		
		/**
		 * Creates a VisualSensorFromDisplayObject instance with the specified
		 * source, diagonal FOV (field of view), width, and height. Typically,
		 * the source will be a Video object with an attached Camera object. In
		 * this case, the specified FOV represents the FOV of the physical
		 * camera. If FOV is not specified, it defaults to 0.4 * pi (72
		 * degrees), which is a guestimated median for webcams. Width and
		 * height refer to an output resolution, as used by AbstractTracker
		 * subclasses that are instantiated with the
		 * VisualSensorFromDisplayObject instance. These dimensions may differ
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
		 * preserves transparency.
		 * 
		 * @throws ArgumentError if source is <code>null</code> or any
		 * numerical argument is non-positive.
		 * 
		 * @flowerModelElementId _8Jmw4qnjEeG8rNJMqBg6NQ
		 */
		public function VisualSensorFromDisplayObject
			(
				source:DisplayObject,
				fov:Number = 1.25663706143591729539, // 72 degrees
				width:uint = 320,
				height:uint = 240,
				transparent:Boolean = false
			)
		{
			super(fov, width, height);
			
			if (!source)
			{
				throw new ArgumentError("source must be non-null");
			}
			
			source_ = source;
			
			rect_ = new Rectangle(0, 0, width, height);
			
			bitmapData_ = new BitmapData(width, height, transparent);
			
			// Listen for frame updates. The listener has the next-to-lowest
			// possible priority value, such that other listeners' results tend
			// to be available without a frame lag. (The lowest possible
			// priority value is used by AR viewports.)
			source_.addEventListener
			(
				Event.EXIT_FRAME, // type
				onSourceExitFrame, // listener
				false, // useCapture
				int.MIN_VALUE + 1, // priority
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
		 * @flowerModelElementId _8JpNJKnjEeG8rNJMqBg6NQ
		 */
		private function onSourceExitFrame(event:Event):void
		{
			if (redrawCondition && !redrawCondition.toBoolean())
			{
				// Do not update the pixel data.
				return;
			}
			
			// Update the scaling matrix.
			matrix_.a = width / source_.width;
			matrix_.d = height / source_.height;
			
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
			data_ = bitmapData_.getPixels(rect_);
			
			// Notify subscribers that the pixels have changed.
			dispatchUpdateNotice();
		}
	}
}