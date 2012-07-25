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
	 * A consumer of pixel data and projection data, as produced by a PixelFeed
	 * object, and a producer of MarkerPool objects that contain de-projected
	 * representations of particular features in the pixel data.
	 * 
	 * @see MarkerPool
	 * @see PixelFeed
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8FGrY6njEeG8rNJMqBg6NQ
	 */
	public class AbstractTracker
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
		
		/**
		 * A value of <code>true</code> means this object will
		 * <code>start()</code> immediately if the PixelFeed object's source is
		 * onstage, and automatically whenever the PixelFeed object's source is
		 * added to the stage. Regardless, this object will <code>stop()</code>
		 * whenever the PixelFeed object's source is removed from the stage.
		 */
		public var autoStart:Boolean;
		
		protected var delegate_:ITrackerDelegate;
		protected var pixelFeed_:PixelFeed;
		protected var scene3D_:Object3D;
		
		
		/**
		 * Creates an AbstractTracker object. Do not invoke this constructor;
		 * it is intended for use by subclasses only.
		 * 
		 * @param delegate A delegate that is provided the opportunity to
		 * populate the MarkerPool objects when they are created and when they
		 * are asked for more markers than they have.
		 * 
		 * @param pixelFeed The supplier of bitmap and projection data.
		 * 
		 * @param scene3D The 3D node wherein markers are placed.
		 * 
		 * @param autoStart A value of <code>true</code> means this object will
		 * <code>start()</code> immediately if the PixelFeed object's source is
		 * onstage, and automatically whenever the PixelFeed object's source is
		 * added to the stage. Regardless, this object will <code>stop()</code>
		 * whenever the PixelFeed object's source is removed from the stage.
		 * 
		 * @throws ArgumentError if any argument is null.
		 */
		public function AbstractTracker
		(
			delegate:ITrackerDelegate,
			pixelFeed:PixelFeed,
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
			
			if (!scene3D)
			{
				throw new ArgumentError("scene3D must be non-null");
			}
			
			delegate_ = delegate;
			pixelFeed_ = pixelFeed;
			scene3D_ = scene3D;
			this.autoStart = autoStart;
			
			// Fix the number of marker pools.
			markerPools.fixed = true;
			
			// Get the source and stage from the pixel feed.
			var source:DisplayObject = pixelFeed_.source;
			var stage:Stage = source.stage;
			
			// Once the source is onstage, evaluate whether to start the
			// tracker.
			if (stage)
			{
				onSourceAddedToStage();
			}
			else
			{
				source.addEventListener
				(
					Event.ADDED_TO_STAGE, // type
					onSourceAddedToStage, // listener
					false, // useCapture
					0, // priority
					true // useWeakReference
				);
			}
		}
		
		
		/**
		 * Start tracking features in the pixel data provided by the PixelFeed
		 * object, and updating markers held by the MarkerPool objects.
		 */
		public function start():void
		{
			// Update the tracker each time the source enters the frame.
			pixelFeed_.source.addEventListener
			(
				Event.EXIT_FRAME, // type
				onSourceExitFrame, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		/**
		 * Stop tracking features in the pixel data provided by the PixelFeed
		 * object, and updating markers held by the MarkerPool objects.
		 */
		public function stop():void
		{
			pixelFeed_.source.removeEventListener(Event.EXIT_FRAME, onSourceExitFrame);
		}
		
		
		protected function get stage():Stage
		{
			return pixelFeed_.source.stage;
		}
		
		protected function updateTrackedMarkers
		(
			markerPoolIterators:Vector.<MarkerPoolIterator>,
			pixels:ByteArray
		)
		:void {}
		
		
		private function onSourceAddedToStage(event:Event = null):void
		{
			var source:DisplayObject = pixelFeed_.source;
			if (source.hasEventListener(Event.ADDED_TO_STAGE))
			{
				source.removeEventListener(Event.ADDED_TO_STAGE, onSourceAddedToStage);
			}
			
			if (autoStart)
			{
				// Start the tracker.
				start();
			}
			
			// Stop the tracker once the source is offstage.
			source.addEventListener
			(
				Event.REMOVED_FROM_STAGE, // type
				onSourceRemovedFromStage, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		private function onSourceExitFrame(event:Event):void
		{
			if (!pixelFeed_.didRedraw)
			{
				// There is nothing new to see.
				
				// No-op.
				return;
			}
			
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
		
		private function onSourceRemovedFromStage(event:Event):void
		{
			var source:DisplayObject = pixelFeed_.source;
			source.removeEventListener(Event.REMOVED_FROM_STAGE, onSourceRemovedFromStage);
			
			// Stop the tracker.
			stop();
			
			// Once the source is onstage again, evaluate whether to restart
			// the tracker.
			source.addEventListener
			(
				Event.ADDED_TO_STAGE, // type
				onSourceAddedToStage, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
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