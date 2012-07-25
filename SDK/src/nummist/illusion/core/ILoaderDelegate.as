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


package nummist.illusion.core
{
	import flash.utils.ByteArray;
	
	
	/**
	 * A delegate providing certain callbacks to one or more Loader instances.
	 * 
	 * @see Loader
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _71nd4KnjEeG8rNJMqBg6NQ
	 */
	public interface ILoaderDelegate
	{
		/**
		 * Handles the specified error type, which arose when the specified
		 * Loader object tried to load the specified file.
		 * 
		 * @flowerModelElementId _73iJcKnjEeG8rNJMqBg6NQ
		 */
		 function onLoadError(loader:Loader, filename:String, errorEventType:String):void;
		
		/**
		 * Handles the specified data, which was loaded from the specified file
		 * by the specified Loader object.
		 * 
		 * @flowerModelElementId _74hn86njEeG8rNJMqBg6NQ
		 */
		 function onLoadComplete(loader:Loader, filename:String, data:*):void;
	}
}