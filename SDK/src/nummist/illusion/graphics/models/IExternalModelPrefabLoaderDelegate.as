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


package nummist.illusion.graphics.models
{
	import alternativa.engine3d.core.Object3D;
	
	
	/**
	 * A delegate providing certain callbacks to one or more
	 * ExternalModelPrefabLoader instances.
	 * 
	 * @see ExternalModelPrefabLoader
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8DdsoKnjEeG8rNJMqBg6NQ
	 */
	public interface IExternalModelPrefabLoaderDelegate
	{
		/**
		 * Handles the specified error type, which arose when the specified
		 * ExternalModelPrefabLoader object tried to load the specified file.
		 * 
		 * @flowerModelElementId _8De6wanjEeG8rNJMqBg6NQ
		 */
		function onLoadExternalModelPrefabError
		(
			loader:ExternalModelPrefabLoader,
			filename:String,
			errorEventType:String
		)
		:void;
		
		/**
		 * Handles the specified ExternalModelPrefab, which was loaded from the
		 * specified file by the specified ExternalModelPrefabLoader object.
		 * 
		 * @flowerModelElementId _8DgI46njEeG8rNJMqBg6NQ
		 */
		function onLoadExternalModelPrefabComplete
		(
			loader:ExternalModelPrefabLoader,
			filename:String,
			externalModelPrefab:ExternalModelPrefab
		)
		:void;
	}
}