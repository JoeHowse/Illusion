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
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	
	/**
	 * A file loader that supports multiple concurrent requests and uses the
	 * delegate pattern.
	 * 
	 * @see ILoaderDelegate
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _79vfIKnjEeG8rNJMqBg6NQ
	 */
	public class Loader
	{
		private var delegate_:ILoaderDelegate;
		private var basePath_:String;
		private var filenamesForLoaders_:Dictionary = new Dictionary();
		private var numLoadsPending_:uint;
		
		
		/**
		 * Creates a Loader object with the specified delegate and base path.
		 * 
		 * @param delegate The delegate, which will handle loading errors and
		 * loaded data.
		 * 
		 * @param basePath The base path. Filenames for all load requests will
		 * be interpreted relative to it. If the base path is not already
		 * absolute and the delegate is a DisplayObject instance, the base path
		 * is interpreted relative to the loader URL of the delegate's root.
		 */
		public function Loader(delegate:ILoaderDelegate, basePath:String)
		{
			var displayObject:DisplayObject = delegate as DisplayObject;
			if (displayObject)
			{
				basePath = StringUtils.absolutePath(basePath, displayObject);
			}
			
			delegate_ = delegate;
			basePath_ = StringUtils.slashTerminate(basePath);
		}
		
		
		/**
		 * The base path. Filenames for all load requests are interpreted
		 * relative to it.
		 */
		public function get basePath():String
		{
			return basePath_;
		}
		
		/**
		 * The number of requested loads that have not yet succeeded or failed.
		 */
		public function get numLoadsPending():uint
		{
			return numLoadsPending_;
		}
		
		/**
		 * Loads the specified file as binary data. On receiving the file's
		 * data, the delegate should cast the data to an appropriate type, such
		 * as ByteArray or Bitmap.
		 * 
		 * @filename The filename.
		 */
		public function loadBinary(filename:String):void
		{
			// Update the count of loads in progress.
			numLoadsPending_++;
			
			// Create the binary loader.
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			// Remember the filename.
			filenamesForLoaders_[loader] = filename;
			
			// Listen for load events.
			addLoadEventListeners(loader);
			
			// Load the binary.
			loader.load(new URLRequest(basePath_ + filename));
		}
		
		/**
		 * Loads the specified files as binary data. On receiving each file's
		 * data, the delegate should cast the data to an appropriate type, such
		 * as ByteArray or Bitmap.
		 * 
		 * @param filenames The filenames as either multiple String objects or
		 * one Array object containing only String objects.
		 * 
		 * @throws ArgumentError if the arguments are not all String objects
		 * and the first argument is not an Array or Vector object containing
		 * only String objects.
		 */
		public function loadBinaries(... filenames):void
		{
			if (filenames.length == 0)
			{
				return;
			}
			
			var filename:String;
			
			if (filenames[0] is Vector.<String>)
			{
				// The filenames are specified in a vector.
				
				// Load the binaries.
				for each (filename in filenames[0])
				{
					loadBinary(filename);
				}
				return;
			}
			
			if (filenames[0] is Array)
			{
				filenames = filenames[0];
			}
			
			for each (var object:Object in filenames)
			{
				if (!(object is String))
				{
					throw new ArgumentError("filenames must contain only elements of type String");	
				}
			}
			
			// The filenames are specified in an array.
			
			// Load the binaries.
			for each (filename in filenames)
			{
				loadBinary(filename);
			}
		}
		
		/**
		 * Loads the specified file as plain text data. On receiving the file's
		 * data, the delegate should cast the data to an appropriate type, such
		 * as String or XML.
		 * 
		 * @filename The filename.
		 */
		public function loadText(filename:String):void
		{
			// Update the count of loads in progress.
			numLoadsPending_++;
			
			// Create the text loader.
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			// Remember the filename.
			filenamesForLoaders_[loader] = filename;
			
			// Listen for load events.
			addLoadEventListeners(loader);
			
			// Load the text.
			loader.load(new URLRequest(basePath_ + filename));
		}
		
		/**
		 * Loads the specified files as plain text data. On receiving each
		 * file's data, the delegate should cast the data to an appropriate
		 * type, such as String or XML.
		 * 
		 * @param filenames The filenames as either multiple String objects or
		 * one Array object containing only String objects.
		 * 
		 * @throws ArgumentError if the arguments are not all String objects
		 * and the first argument is not an Array or Vector object containing
		 * only String objects.
		 */
		public function loadTexts(... filenames):void
		{
			if (filenames.length == 0)
			{
				return;
			}
			
			var filename:String;
			
			if (filenames[0] is Vector.<String>)
			{
				// The filenames are specified in a vector.
				
				// Load the texts.
				for each (filename in filenames[0])
				{
					loadText(filename);
				}
				return;
			}
			
			if (filenames[0] is Array)
			{
				filenames = filenames[0];
			}
			
			for each (var object:Object in filenames)
			{
				if (!(object is String))
				{
					throw new ArgumentError("filenames must contain only elements of type String");	
				}
			}
			
			// The filenames are specified in an array.
			
			// Load the texts.
			for each (filename in filenames)
			{
				loadText(filename);
			}
		}
		
		/**
		 * Cancels all pending load requests. After calling this method, it is
		 * still safe to make subsequent load requests.
		 */
		public function close():void
		{
			// Update the count of loads in progress.
			numLoadsPending_ = 0;
			
			// Close all loaders and stop listening for load events.
			for (var loader:* in filenamesForLoaders_)
			{
				(loader as URLLoader).close();
				removeLoadEventListeners(loader);
			}
			
			// Release all loaders and forget all filenames.
			filenamesForLoaders_ = new Dictionary();
		}
		
		
		/**
		 * @flowerModelElementId _-rpLILTsEeGzqYJyQYfHMA
		 */
		private function addLoadEventListeners(loader:URLLoader):void
		{
			// Even though the loaders are keys in a dictionary that is
			// supposed to hold strong references to keys, they seem to need
			// strong references from event listeners too. Otherwise, they
			// sometimes get garbage-collected prematurely.
			// 
			// This issue was encountered on Flash 11.2, Mac OS 10.7.
			
			// Listen for load errors.
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			// Listen for load completion.
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		/**
		 * @flowerModelElementId _-sJhcLTsEeGzqYJyQYfHMA
		 */
		private function removeLoadEventListeners(loader:URLLoader):void
		{
			// Stop listening for load errors.
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			// Stop listening for load completion.
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		/**
		 * @flowerModelElementId _-sgGwLTsEeGzqYJyQYfHMA
		 */
		private function onLoadError(event:Event):void
		{
			// Update the count of loads in progress.
			numLoadsPending_--;
			
			// Get the loader.
			var loader:URLLoader = event.target as URLLoader;
			
			// Stop listening for load events.
			removeLoadEventListeners(loader);
			
			// Dispatch the filename and error type to the delegate.
			delegate_.onLoadError
			(
				this,
				filenamesForLoaders_[loader] as String,
				event.type
			);
			
			// Release the loader and forget the filename.
			delete filenamesForLoaders_[loader];
		}
		
		/**
		 * @flowerModelElementId _-s3TILTsEeGzqYJyQYfHMA
		 */
		private function onLoadComplete(event:Event):void
		{
			// Update the count of loads in progress.
			numLoadsPending_--;
			
			// Get the loader.
			var loader:URLLoader = event.target as URLLoader;
			
			// Stop listening for load events.
			removeLoadEventListeners(loader);
			
			// Dispatch the filename and data to the delegate.
			delegate_.onLoadComplete
			(
				this,
				filenamesForLoaders_[loader] as String,
				loader.data
			);
			
			// Release the loader and forget the filename.
			delete filenamesForLoaders_[loader];
		}
	}
}