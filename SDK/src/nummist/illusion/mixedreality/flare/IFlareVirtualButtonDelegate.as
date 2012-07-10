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


package nummist.illusion.mixedreality.flare
{
	/**
	 * A delegate providing a callback to a FlareNaturalFeatureTracker object
	 * for the sake of handling virtual button events.
	 * 
	 * @see FlareNaturalFeatureTracker
	 * @flowerModelElementId _8HG2gKnjEeG8rNJMqBg6NQ
	 */
	public interface IFlareVirtualButtonDelegate
	{
		/**
		 * Handles a virtual button "press" (occlusion) or "release"
		 * (de-occlusion) event, whichever is specified. Uniquely, the button
		 * has the specified ID numbers and belongs to the specified
		 * FlareNaturalFeatureTracker object.
		 * 
		 * @param tracker The FlareNaturalFeatureTracker object.
		 * 
		 * @param markerID The MarkerPool object's index, as defined by the
		 * FlareNaturalFeatureTracker object.
		 * 
		 * @param buttonID The button index, relative to other buttons
		 * associated with the same FlareNaturalFeatureTracker object and
		 * MarkerPool object.
		 * 
		 * @param press A value of <code>true</code> means the button has been
		 * pressed. False means it has been released.
		 * @flowerModelElementId _8HHdkanjEeG8rNJMqBg6NQ
		 */
		 function onVirtualButtonEvent
		(tracker:FlareNaturalFeatureTracker, markerID:uint, buttonID:uint, press:Boolean
		)
		:void;
	}
}