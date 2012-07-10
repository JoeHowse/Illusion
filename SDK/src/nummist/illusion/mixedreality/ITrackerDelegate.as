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
	/**
	 * A delegate providing certain callbacks to one or more AbstractTracker
	 * subclass instances.
	 * 
	 * @see AbstractTracker
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _8IU-gKnjEeG8rNJMqBg6NQ
	 */
	public interface ITrackerDelegate
	{
		/**
		 * Performs any configuration of the specified AbstractTracker subclass
		 * instance, which has been newly started, and the specified MarkerPool
		 * objects, which have have been newly created by the AbstractTracker
		 * subclass instance. Typical behavior is to add one or more Object3D
		 * instances to each MarkerPool object's markers.
		 * 
		 * @param tracker The AbstractTracker subclass instance.
		 * 
		 * @param markerPools The MarkerPool objects.
		 * @flowerModelElementId _8IU-gqnjEeG8rNJMqBg6NQ
		 */
		 function onTrackerStarted
		(tracker:AbstractTracker, markerPools:Vector.<MarkerPool>
		)
		:void;
		
		/**
		 * Performs any update of the specified MarkerPool object, which is not
		 * supplying enough markers to meet the demands of the specified
		 * AbstractTracker subclass instance. Typical behavior is to either do
		 * nothing or add one or more Object3D instances to the MarkerPool
		 * object's markers.
		 * 
		 * @param tracker The AbstractTracker subclass instnace.
		 * 
		 * @param markerPoolIndex The MarkerPool object's index, as defined by the
		 * AbstractTracker subclass instance.
		 * 
		 * @param markerPool The MarkerPool object.
		 * @flowerModelElementId _8IVllKnjEeG8rNJMqBg6NQ
		 */
		 function onMarkerPoolHasExcessDemand
		(tracker:AbstractTracker, markerPoolIndex:uint, markerPool:MarkerPool
		)
		:void;
	}
}