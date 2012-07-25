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
	 * A delegate providing a callback to a FlareBarcodeTracker object for the
	 * sake of handling messages decoded from data matrix barcodes when the
	 * barcode is newly found.
	 * 
	 * @flowerModelElementId _8GvqIKnjEeG8rNJMqBg6NQ
	 */
	public interface IFlareDataMatrixDelegate
	{
		/**
		 * Handles a message decoded from a data matrix barcode by the specifed
		 * FlareBarcodeTracker object when the barcode is newly found.
		 * 
		 * @param tracker The FlareBarcodeTracker object.
		 * 
		 * @param markerID The MarkerPool object's index, as defined by the
		 * FlareNaturalFeatureTracker object.
		 * 
		 * @param message The message as plain text.
		 * 
		 * @flowerModelElementId _8GwRManjEeG8rNJMqBg6NQ
		 */
		function onDataMatrixMessage
		(
			tracker:FlareBarcodeTracker,
			markerID:uint,
			message:String
		)
		:void;
	}
}