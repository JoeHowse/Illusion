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
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	
	
	/**
	 * A producer of pixel data and projection data, as used by AbstractTracker
	 * subclasses, other ISensorSubscriber implementations, and
	 * ARViewportUsingStageVideo.
	 * 
	 * @see AbstractTracker
	 * 
	 * @see ARViewportUsingStageVideo
	 * 
	 * @see ISensorSubscriber
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _hyhuUNnZEeG6Ia5yiOlRVA
	 */
	public class VisualSensorFromCamera extends AbstractVisualSensor
	{
		private var source_:Camera;
		private var intermediateBitmapData_:BitmapData;
		private var finalBitmapData_:BitmapData;
		private var matrix_:Matrix = new Matrix();
		private var rect_:Rectangle;
		
		
		/**
		 * Creates a VisualSensorFromCamera instance with the specified source,
		 * diagonal FOV (field of view), width, and height. The source is a
		 * Camera object, typically attached to a Video or StageVideo object.
		 * The specified FOV represents the FOV of the physical camera. If FOV
		 * is not specified, it defaults to 0.4 * pi (72 degrees), which is a
		 * guestimated median for webcams. Width and height refer to an output
		 * resolution, as used by AbstractTracker subclasses that are
		 * instantiated with the VisualSensorFromCamera object. These
		 * dimensions may differ from the width and height of the Camera
		 * object, yet the aspect ratios should match. If not specified, width
		 * and height default to 320x240.
		 * 
		 * @param source The camera whose pixel data is to be captured.
		 * 
		 * @param fov The pixel data's diagonal field of view, in radians.
		 * 
		 * @param width The pixel data's horizontal resolution.
		 * 
		 * @param height The pixel data's vertical resolution.
		 * 
		 * @throws ArgumentError if source is <code>null</code> or any
		 * numerical argument is non-positive.
		 */
		public function VisualSensorFromCamera
		(
			source:Camera,
			fov:Number = 1.25663706143591729539, // 72 degrees
			width:uint = 320,
			height:uint = 240
		)
		{
			super(fov, width, height);
			
			if (!source)
			{
				throw new ArgumentError("source must be non-null");
			}
			
			source_ = source;
			
			// Create the bitmap data that has the same pixel dimensions as the
			// camera feed.
			intermediateBitmapData_ = new BitmapData
			(
				source_.width,
				source_.height,
				false // transparent
			);
			
			// Create the bitmap data and rectangle that have the same pixel
			// dimensions as the outbound feed.
			finalBitmapData_ = new BitmapData
			(
				width,
				height,
				false // transparent
			);
			rect_ = new Rectangle(0, 0, width, height);
			
			// Listen for frame updates. The listener has the next-to-lowest
			// possible priority value, such that other listeners' results tend
			// to be available without a frame lag. (The lowest possible
			// priority value is used by AR viewports.)
			source_.addEventListener
			(
				Event.VIDEO_FRAME, // type
				onSourceVideoFrame, // listener
				false, // useCapture
				int.MIN_VALUE + 1, // priority
				true // useWeakReference
			);
		}
		
		
		/**
		 * The camera whose pixel data is being captured.
		 */
		public function get source():Camera
		{
			return source_;
		}
		
		
		private function onSourceVideoFrame(event:Event):void
		{
			if (redrawCondition && !redrawCondition.toBoolean())
			{
				// Do not update the pixel data.
				return;
			}
			
			if
			(
				intermediateBitmapData_.width != source_.width ||
				intermediateBitmapData_.height != source_.height
			)
			{
				// The source resolution has changed.
				
				// Resize the unscaled drawing.
				intermediateBitmapData_ = new BitmapData
				(
					source_.width,
					source_.height,
					false // transparent
				);
			}
			
			// Update the scaling matrix.
			matrix_.a = width / source_.width;
			matrix_.d = height / source_.height;
			
			// Draw the camera frame without scaling.
			source_.drawToBitmapData(intermediateBitmapData_);
			
			// Redraw the camera frame with scaling.
			finalBitmapData_.drawWithQuality
			(
				intermediateBitmapData_, // source
				matrix_, // matrix
				null, // colorTransform
				null, // blendMode
				null, // clipRect
				false, // smoothing
				StageQuality.LOW // quality
			);
			
			// Expose the scaled drawing's pixels.
			data_ = finalBitmapData_.getPixels(rect_);
			
			// Notify subscribers that the pixels have changed.
			dispatchUpdateNotice();
		}
	}
}