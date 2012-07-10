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
	import alternativa.engine3d.core.events.Event3D;
	
	
	/**
	 * An Event3D subclass targeting an Object3D instance that is held by a
	 * MarkerPool object and is either newly found or newly lost by an
	 * AbstractTracker subclass instance.
	 * 
	 * @see AbstractTracker
	 * @see MarkerPool
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _8IldMKnjEeG8rNJMqBg6NQ
	 */
	public class MarkerEvent extends Event3D
	{
		/**
		 * A constant that defines the value of a MarkerEvent's type property
		 * when the marker is newly found.
		 */
		public static const FOUND:String = "found";
		
		/**
		 * A constant that defines the value of a MarkerEvent's type property
		 * when the marker is newly lost.
		 * @flowerModelElementId _8ImrUanjEeG8rNJMqBg6NQ
		 */
		public static const LOST:String = "lost";
		
		/**
		 * @flowerModelElementId _8ImrVKnjEeG8rNJMqBg6NQ
		 */
		private var markerPool_:MarkerPool;
		
		
		/**
		 * Creates a MarkerEvent object.
		 * 
		 * @param type Either MarkerEvent.FOUND or MarkerEvent.LOST.
		 * 
		 * @param markerPool The MarkerPool object that holds the target
		 * object.
		 * @flowerModelElementId _8InSYKnjEeG8rNJMqBg6NQ
		 */
		public function MarkerEvent(type:String, markerPool:MarkerPool)
		{
			super(type, false); // does not bubble
			
			markerPool_ = markerPool;
		}
		
		
		/**
		 * The MarkerPool object that holds the target object.
		 */
		public function get markerPool():MarkerPool
		{
			return markerPool_;
		}
	}
}