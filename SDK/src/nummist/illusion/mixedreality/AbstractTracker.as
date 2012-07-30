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
	import alternativa.engine3d.core.Object3D;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	
	/**
	 * A consumer of pixel data and projection data, as produced by an
	 * AbstractPixelFeed subclass instance, and a producer of MarkerPool
	 * objects that contain de-projected representations of particular
	 * features in the pixel data.
	 * <br /><br />
	 * To avoid memory leaks, invoke the <code>stop()</code> method once this
	 * object is no longer in use.
	 * 
	 * @see MarkerPool
	 * @see AbstractPixelFeed
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8FGrY6njEeG8rNJMqBg6NQ
	 */
	public class AbstractTracker implements IPixelFeedSubscriber
	{
		/**
		 * MarkerPool objects that each correspond to a particular marker ID
		 * being tracked in the pixel data. Wherever a physical occurence
		 * of the marker ID is identified, a virtual marker may be drawn from
		 * the MarkerPool object and placed in the 3D scene, provided that
		 * enough virtual markers are available.
		 * <br /><br />
		 * Regardless of the number of virtual markers available, instances of
		 * the following classes never track more than one physical marker per
		 * marker ID:
		 * <br /><br />
		 * FlareBarcodeTracker<br />
		 * FlareNaturalFeatureTracker
		 * 
		 * @see MarkerPool
		 * @see FlareBarcodeTracker
		 * @see FlareNaturalFeatureTracker
		 */
		public const markerPools:Vector.<MarkerPool> = new Vector.<MarkerPool>();
		
		
		protected var delegate_:ITrackerDelegate;
		protected var pixelFeed_:AbstractPixelFeed;
		protected var stage_:Stage;
		protected var scene3D_:Object3D;
		
		
		/**
		 * Creates an AbstractTracker object.
		 * <br /><br />
		 * Do not invoke this constructor; it is intended for use by subclasses
		 * only.
		 * 
		 * @param delegate A delegate that is provided the opportunity to
		 * populate the MarkerPool objects when they are created and when they
		 * are asked for more markers than they have.
		 * 
		 * @param pixelFeed The supplier of pixel data and projection data.
		 * 
		 * @param stage The stage.
		 * 
		 * @param scene3D The 3D node wherein markers are placed.
		 * 
		 * @param autoStart A value of <code>true</code> means this object will
		 * <code>start()</code> immediately.
		 * 
		 * @throws ArgumentError if any argument is <code>null</code>.
		 */
		public function AbstractTracker
		(
			delegate:ITrackerDelegate,
			pixelFeed:AbstractPixelFeed,
			stage:Stage,
			scene3D:Object3D,
			autoStart:Boolean = true
		)
		{
			if (!delegate)
			{
				throw new ArgumentError("delegate must be non-null");
			}
			
			if (!pixelFeed)
			{
				throw new ArgumentError("pixelFeed must be non-null");
			}
			
			if (!stage)
			{
				throw new ArgumentError("stage must be non-null");
			}
			
			if (!scene3D)
			{
				throw new ArgumentError("scene3D must be non-null");
			}
			
			delegate_ = delegate;
			pixelFeed_ = pixelFeed;
			stage_ = stage;
			scene3D_ = scene3D;
			
			// Fix the number of marker pools.
			markerPools.fixed = true;
			
			if (autoStart)
			{
				start();
			}
		}
		
		
		/**
		 * Start tracking features in the pixel data provided by the 
		 * AbstractPixelFeed subclass instance. Also start updating markers
		 * held by the MarkerPool objects.
		 */
		public function start():void
		{
			// Update the tracker each time the pixel feed is updated.
			pixelFeed_.addSubscriber(this);
		}
		
		/**
		 * Stop tracking features in the pixel data provided by the
		 * AbstractPixelFeed subclass instance. Also stop updating markers held
		 * by the MarkerPool objects.
		 * <br /><br />
		 * Anytime later, to restart tracking and marker updates, invoke
		 * <code>start()</code> again.
		 * <br /><br />
		 * Invoking <code>stop()</code> is necessary in order to ensure that
		 * the tracker is garbage-collectible.
		 */
		public function stop():void
		{
			// Stop updating the tracker each time the pixel feed is updated.
			pixelFeed_.removeSubscriber(this);
		}
		
		
		protected function updateTrackedMarkers
		(
			markerPoolIterators:Vector.<MarkerPoolIterator>,
			pixels:ByteArray
		)
		:void {}
		
		
		/**
		 * Part of the IPixelFeedSubscriber implementation.
		 * <br /><br />
		 * Do not invoke this method; it is intended solely for use by the
		 * AbstractPixelFeed subclass instance passed to this object's
		 * constructor.
		 */
		public function onPixelFeedUpdated(pixelFeed:AbstractPixelFeed):void
		{
			// Get iterators for the marker pools.
			var markerPoolIterators:Vector.<MarkerPoolIterator> = new Vector.<MarkerPoolIterator>();
			for each (var markerPool:MarkerPool in markerPools)
			{
				markerPoolIterators.push(markerPool.newIterator());
			}
			
			// Update the tracked markers.
			updateTrackedMarkers(markerPoolIterators, pixelFeed_.pixels);
			
			// Update the untracked markers.
			updateUntrackedMarkers(markerPoolIterators);
		}
		
		private function updateUntrackedMarkers(markerPoolIterators:Vector.<MarkerPoolIterator>):void
		{
			// Iterate over all untracked markers.
			for each (var markerPoolIterator:MarkerPoolIterator in markerPoolIterators)
			{
				var marker:Object3D = markerPoolIterator.nextMarker();
				while (marker)
				{
					if(marker.parent == scene3D_)
					{
						// The marker is newly lost.
						
						// Remove the marker from the 3D scene.
						scene3D_.removeChild(marker);
						
						// Notify the marker that it has been lost.
						marker.dispatchEvent(new MarkerEvent
						(
							MarkerEvent.LOST,
							markerPoolIterator.markerPool
						));
					}
					
					marker = markerPoolIterator.nextMarker();
				}
			}
		}
	}
}