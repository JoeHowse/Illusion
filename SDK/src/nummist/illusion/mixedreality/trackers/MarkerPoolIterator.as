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
	
	import flash.events.Event;
	
	
	/**
	 * An iterator over the Object3D instances that are held by a MarkerPool
	 * object.
	 * 
	 * @see AbstractTracker
	 * @see MarkerPool
	 * 
	 * @author Joseph Howse
	 */
	public class MarkerPoolIterator
	{
		private var i_:uint = 0;
		private var markerPool_:MarkerPool;
		
		
		/**
		 * Constructs a MarkerPoolIterator object for the specified MarkerPool
		 * object.
		 * 
		 * @param markerPool - the MarkerPool object.
		 */
		public function MarkerPoolIterator(markerPool:MarkerPool)
		{
			markerPool_ = markerPool;
		}
		
		/**
		 * The next Object3D instance held by the MarkerPool object, or
		 * <code>null</code> if the iterator is at the end.
		 */
		public function nextMarker():Object3D
		{
			var markers:Vector.<Object3D> = markerPool_.markers;
			
			var result:Object3D = null;
			if (i_ < markers.length)
			{
				result = markers[i_];
				i_++;
			}
			return result;
		}
		
		/**
		 * The MarkerPool object.
		 */
		public function get markerPool():MarkerPool
		{
			return markerPool_;
		}
		
		/**
		 * Makes the MarkerPool object release the last Object3D instance (if
		 * any) that was returned by <code>nextMarker</code>.
		 */
		public function removeCurrentMarker():void
		{
			if (i_ > 0)
			{
				i_--;
				markerPool_.markers.splice(i_, 1);
			}
		}
	}
}