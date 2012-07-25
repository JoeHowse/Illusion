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
	
	
	/**
	 * A container for a mutable Vector.<Object3D> instance whose elements are
	 * placed in a 3D scene by an AbstractTracker subclass instance.
	 * 
	 * @see AbstractTracker
	 * @see ITrackerDelegate
	 * @see MarkerEvent
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8IzfoKnjEeG8rNJMqBg6NQ
	 */
	public class MarkerPool
	{
		/**
		 * A Vector.<Object3D> instance whose elements are used by an
		 * AbstractTracker subclass instance to represent tracked occurences of
		 * a particular marker ID. For example, if tracking identifies two
		 * physical markers that match the particular marker ID, two elements
		 * may be drawn as virtual markers. It is safe to add, remove, and
		 * modify elements; doing so is the intended means of controlling the
		 * maximum number of virtual markers in the 3D scene and their
		 * behavior. An element dispatches a MarkerEvent object on being found
		 * or lost by an AbstractTracker subclass instance.
		 * <br /><br />
		 * Regardless of the number of elements available as virtual markers,
		 * instances of the following classes never track more than one
		 * physical marker per marker ID:
		 * <br /><br />
		 * FlareBarcodeTracker<br />
		 * FlareNaturalFeatureTracker
		 * 
		 * @see FlareBarcodeTracker
		 * @see FlareNaturalFeatureTracker
		 * 
		 * @flowerModelElementId _8I0GsanjEeG8rNJMqBg6NQ
		 */
		public const markers:Vector.<Object3D> = new Vector.<Object3D>();
		
		
		/**
		 * Creates a MarkerPool object with an empty Vector.<Object3D>
		 * instance. Do not invoke this constructor; instead, get MarkerPool
		 * instances by implementing ITrackerDelegate and creating one or
		 * more AbstractTracker subclass instances.
		 */
		public function MarkerPool() {}
		
		
		
		internal function newIterator():MarkerPoolIterator
		{
			return new MarkerPoolIterator(this);
		}
	}
}