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


package nummist.illusion.mixedreality.trackers
{
	import alternativa.engine3d.core.Object3D;
	
	import flash.display.Stage;
	import flash.utils.ByteArray;
	
	import nummist.illusion.mixedreality.sensors.AbstractVisualSensor;
	
	
	/**
	 * A tracker for debugging or profiling purposes. It treats each pixel's
	 * RGB values as signed bytes representing a marker's xyz coordinates, such TODO is signed bytes wrong term (encoding)?
	 * that each coordinate is in the range [-128, 127]. For instance, 0x808080
	 * (50% gray) is the origin and 0xff0000 (red) is (127, 0, 0).
	 * 
	 * @author Joseph Howse
	 */
	public class DebugTracker extends AbstractTracker
	{
		public function DebugTracker
		(
			delegate:ITrackerDelegate,
			sensor:AbstractVisualSensor,
			stage:Stage,
			scene3D:Object3D,
			autoStart:Boolean=true
		)
		{
			super(delegate, sensor, stage, scene3D, autoStart);
		}
		
		
		override public function start():void
		{
			super.start();
			
			var visualSensor:AbstractVisualSensor =
				sensor_ as AbstractVisualSensor;
			var numPixels:uint = visualSensor.width * visualSensor.height;
			
			// Unfix the number of marker pools.
			markerPools.fixed = false;
			
			// Create the marker pools.
			for (var i:uint = 0; i < numPixels; i++)
			{
				markerPools.push(new MarkerPool());
			}
			
			// Fix the number of marker pools.
			markerPools.fixed = true;
			
			// Notify the delegate that the marker pools have been created and
			// tracking has started.
			delegate_.onTrackerStarted(this, markerPools);
		}
		
		override public function stop():void
		{
			super.stop();
			
			// Release the marker pools.
			markerPools.fixed = false;
			markerPools.splice(0, markerPools.length);
			markerPools.fixed = true;
		}
		
		
		override protected function updateTrackedMarkers
		(
			markerPoolIterators:Vector.<MarkerPoolIterator>,
			pixels:ByteArray
		)
		:void
		{
			for (var i:uint = 0; i < markerPools.length; i++)
			{
				// Skip the alpha value.
				pixels.readUnsignedByte();
				
				// Interpret the RGB values as xyz coordinates.
				var x:int = pixels.readUnsignedByte() - 128;
				var y:int = pixels.readUnsignedByte() - 128;
				var z:int = pixels.readUnsignedByte() - 128;
				
				var marker:Object3D = markerPoolIterators[i].nextMarker();
				
				if (!marker)
				{
					continue;
				}
				
				marker.x = x;
				marker.y = y;
				marker.z = z;
				
				if (marker.parent != scene3D_)
				{
					// The marker is newly found.
					
					// Add the marker to the 3D scene.
					scene3D_.addChild(marker);
					
					// Notify the marker that it has been found.
					marker.dispatchEvent(new MarkerEvent
					(
						MarkerEvent.FOUND,
						markerPoolIterators[i].markerPool
					));
				}
			}
		}
	}
}