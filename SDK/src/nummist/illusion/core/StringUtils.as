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
	import flash.display.DisplayObject;
	
	
	/**
	 * Static utility functions for parsing strings, including file paths.
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8AtTkKnjEeG8rNJMqBg6NQ
	 */
	public class StringUtils
	{
		/**
		 * Finds the absolute path of the specified path. If the specified path
		 * is not already absolute, it is interpreted relative to the loader
		 * URL of the root of the specified DisplayObject instance.
		 * 
		 * @param path The path that may be relative.
		 * 
		 * @param displayObject The DisplayObject instance, whose root's loader
		 * URL is interpreted as being the base path.
		 * 
		 * @return An absolute path, or <code>null</code> if the specified path
		 * is <code>null</code>.
		 * 
		 * @throws ArgumentError if displayObject is null.
		 */
		public static function absolutePath
		(
			path:String,
			displayObject:DisplayObject
		)
		:String
		{
			if (!displayObject)
			{
				throw new ArgumentError("displayObject must be non-null");
			}
			
			if (!path)
			{
				return null;
			}
			
			// Replace backslashes with slashes.
			path.replace(/[]/g, "/");
			
			if (path.indexOf(":/") >= 0)
			{
				// The path is already absolute.
				
				return path;
			}
			
			// Remove any leading slash.
			if (path.indexOf("/") == 0)
			{
				path = path.substr(1);
			}
			
			// The path is not yet absolute.
			// Treat is as relative to the display object's loader URL.
			
			// Get the loader URL.
			var basePath:String = displayObject.root.loaderInfo.loaderURL;
			
			// Replace backslashes with slashes.
			basePath.replace(/[]/g, "/");
			
			// Cut off the query string.
			basePath = basePath.slice(0, basePath.indexOf("?"));
			
			// Cut off the filename but include the last slash.
			basePath = basePath.slice(0, basePath.lastIndexOf("/") + 1);
			
			return basePath + path;
		}
		
		/**
		 * Finds the slash-terminated version of the specified path.
		 * 
		 * @param path The path.
		 */
		public static function slashTerminate(path:String):String
		{
			if (!path || path == "")
			{
				return path;
			}
			
			// Ensure that the path is properly terminated.
			var pathTerminator:String = path.substr(-1);
			if
			(
				(pathTerminator != "/") &&
				(pathTerminator != "\\")
			)
			{
				path += "/"
			}
			
			return path;
		}
		
		/**
		 * Finds the lowercase file extension of the specified filename.
		 * 
		 * @param filename The filename.
		 */
		public static function lowercaseFileExtension(filename:String):String
		{
			if (!filename || filename == "")
			{
				return filename;
			}
			
			var lastIndexOfDot:int = filename.lastIndexOf(".");
			
			if (lastIndexOfDot == -1)
			{
				// There is no file extension.
				return "";
			}
			
			return filename.substr(lastIndexOfDot).toLowerCase();
		}
		
		/**
		 * Finds the trimmed version of the specified string. (Leading and
		 * trailing whitespace is stripped.)
		 * 
		 * @param string The string.
		 */
		public static function trim(string:String):String
		{
			if (!string)
			{
				return null;
			}
			
			// Remove leading and trailing whitespace.
			return string.replace(/^\s+|\s+$/gs, "");
		}
	}
}