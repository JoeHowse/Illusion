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
	import flash.utils.ByteArray;
	
	import nummist.illusion.logic.ILogicalStatement;
	
	
	/**
	 * A producer of pixel data and projection data, as used by AbstractTracker
	 * subclasses and other IPixelFeedSubscriber implementations.
	 * 
	 * @see AbstractTracker
	 * @see IPixelFeedSubscriber
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _hyB_ENnZEeG6Ia5yiOlRVA
	 */
	public class AbstractPixelFeed
	{
		/**
		 * A condition that must be true in order for the pixel data to be
		 * updated. If the condition is <code>null</code> (the default), the
		 * pixel data is updated every frame.
		 */
		public var redrawCondition:ILogicalStatement;
		
		
		protected const subscribers_:Vector.<IPixelFeedSubscriber> =
			new Vector.<IPixelFeedSubscriber>();
		protected var diagonalFOV_:Number;
		protected var width_:uint;
		protected var height_:uint;
		protected var pixels_:ByteArray;
		
		/**
		 * Creates an AbstractPixelFeed object.
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
		public function AbstractPixelFeed
		( // 72 degrees
fov:Number=1.25663706143591729539, width:uint=320, height:uint=240
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
		
		/**
		 * A handle to the latest pixel data with its pointer rewound to index
		 * 0. The data is current at the time when subscribers receive a call
		 * to <code>onPixelDataUpdated</code>.
		 * 
		 * @see IPixelFeedSubscriber
		 */
		public function get pixels():ByteArray
		{
			// Rewind the file pointer.
			pixels_.position = 0;
			
			return pixels_;
		}
		
		
		/**
		 * Start notifying the specified object about updates to the pixel
		 * data.
		 * 
		 * @param subscriber The subscriber.
		 */
		public function addSubscriber(subscriber:IPixelFeedSubscriber):void
		{
			subscribers_.push(subscriber);
		}
		
		/**
		 * If the specified object is being notified about updates to the pixel
		 * data, stop notifying it.
		 * 
		 * @param subscriber The subscriber.
		 */
		public function removeSubscriber(subscriber:IPixelFeedSubscriber):void
		{
			var i:int = subscribers_.indexOf(subscriber);
			if (i != -1)
			{
				subscribers_.splice(i, 1);
			}
		}
		
		/**
		 * Stop notifying all objects about updates to the pixel data.
		 */
		public function removeAllSubscribers():void
		{
			subscribers_.splice(0, subscribers_.length);
		}
		
		
		/**
		 * Notify subscribers that the pixel data has been updated.
		 * 
		 * @flowerModelElementId _hyIFsNnZEeG6Ia5yiOlRVA
		 */
		protected function dispatchUpdateNotice():void
		{
			for each (var subscriber:IPixelFeedSubscriber in subscribers_)
			{
				subscriber.onPixelFeedUpdated(this);
			}
		}
	}
}