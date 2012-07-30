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
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.Geometry;
	
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import nummist.illusion.core.ILoaderDelegate;
	import nummist.illusion.core.Loader;
	import nummist.illusion.core.StringUtils;
	
	
	/**
	 * A file loader for 3D models in .dae, .3ds, or .a3d format, to be parsed
	 * as ExternalModelPrefab objects. The loader supports multiple concurrent
	 * requests and uses the delegate pattern.
	 * 
	 * @see ExternalModelPrefab
	 * @see IExternalModelPrefabLoaderDelegate
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8CqbYKnjEeG8rNJMqBg6NQ
	 */
	public class ExternalModelPrefabLoader implements ILoaderDelegate
	{
		private var basePath_:String;
		private var delegate_:IExternalModelPrefabLoaderDelegate;
		private var loader_:Loader;
		
		
		/**
		 * Creates an ExternalModelPrefabLoader object with the specified
		 * delegate and base path.
		 * 
		 * @param delegate The delegate, which will handle loading errors and
		 * loaded data.
		 * 
		 * @param basePath The base path. Filenames for all load requests will
		 * be interpreted relative to it. If the base path is not already
		 * absolute and the delegate is a DisplayObject instance, the base path
		 * is interpreted relative to the loader URL of the delegate's root.
		 * 
		 * @flowerModelElementId _8CtesanjEeG8rNJMqBg6NQ
		 */
		public function ExternalModelPrefabLoader
		(
			delegate:IExternalModelPrefabLoaderDelegate,
			basePath:String
		)
		{
			var displayObject:DisplayObject = delegate as DisplayObject;
			if (displayObject)
			{
				basePath = StringUtils.absolutePath(basePath, displayObject);
			}
			
			delegate_ = delegate;
			basePath_ = StringUtils.slashTerminate(basePath);
			
			loader_ = new Loader(this, basePath_);
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
			// Get the number of pending loads from the underlying loader.
			return loader_.numLoadsPending;
		}
		
		
		/**
		 * Loads the specified file as an ExternalModelPrefab object.
		 * 
		 * @filename The filename.
		 */
		public function loadExternalModelPrefab(filename:String):void
		{
			// Load the model's raw data via the underlying loader.
			switch(StringUtils.lowercaseFileExtension(filename))
			{
				case ExternalModelUtils.FORMAT_COLLADA:
					// The Collada .dae format is plain text.
					loader_.loadText(filename);
					break;
				
				case ExternalModelUtils.FORMAT_3DS:
				case ExternalModelUtils.FORMAT_A3D:
					// The .3ds and .a3d formats are binary.
					loader_.loadBinary(filename);
					break;
				
				default:
					throw ExternalModelUtils.newUnrecognizedFormatError(filename);
					break;
			}
		}
		
		/**
		 * Loads the specified files as ExternalModelPrefab objects.
		 * 
		 * @param filenames The filenames as either multiple String objects or
		 * one Array object containing only String objects.
		 * 
		 * @throws ArgumentError if the arguments are not all String objects
		 * and the first argument is not an Array or Vector object containing
		 * only String objects.
		 */
		public function loadExternalModelPrefabs(... filenames):void
		{
			if (filenames.length == 0)
			{
				return;
			}
			
			if (filenames[0] is Vector.<String>)
			{
				// The filenames are specified in a vector.
				
				// Load the models.
				for each (filename in filenames[0])
				{
					loadExternalModelPrefab(filename);
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
			
			// Load the models.
			for each (var filename:String in filenames)
			{
				loadExternalModelPrefab(filename);
			}
		}
		
		/**
		 * Cancels all pending load requests. After calling this method, it is
		 * still safe to make subsequent load requests.
		 */
		public function close():void
		{
			// Close the underlying loader.
			loader_.close();
		}
		
		
		/**
		 * Part of the ILoaderDelegate implementation.
		 * <br /><br />
		 * Do not invoke this method; it is intended for use by an internal
		 * Loader object only.
		 * 
		 * @flowerModelElementId _8CxwIKnjEeG8rNJMqBg6NQ
		 */
		public function onLoadError(loader:Loader, filename:String, errorEventType:String):void
		{
			// Dispatch the filename and error type to the delegate.
			delegate_.onLoadExternalModelPrefabError(this, filename, errorEventType);
		}
		
		/**
		 * Part of the ILoaderDelegate implementation.
		 * <br /><br />
		 * Do not invoke this method; it is intended for use by an internal
		 * Loader object only.
		 * 
		 * @flowerModelElementId _8Cy-Q6njEeG8rNJMqBg6NQ
		 */
		public function onLoadComplete(loader:Loader, filename:String, data:*):void
		{
			// Parse the file.
			var objects:Vector.<Object3D>;
			switch(StringUtils.lowercaseFileExtension(filename))
			{
				case ExternalModelUtils.FORMAT_COLLADA:
					var parserCollada:ParserCollada = new ParserCollada();
					parserCollada.parse(XML(data), basePath_, true);
					objects = parserCollada.objects;
					break;
				
				case ExternalModelUtils.FORMAT_3DS:
					var parser3DS:Parser3DS = new Parser3DS();
					parser3DS.parse(data);
					objects = parser3DS.objects;
					break;
				
				case ExternalModelUtils.FORMAT_A3D:
					var parserA3D:ParserA3D = new ParserA3D();
					parserA3D.parse(data);
					objects = parserA3D.objects;
					break;
				
				default:
					throw ExternalModelUtils.newUnrecognizedFormatError(filename);
					break;
			}
			
			// Create the prefab.
			var externalModelPrefab:ExternalModelPrefab = new ExternalModelPrefab
			(
				basePath_,
				filename,
				objects
			);
			
			// Dispatch the filename and prefab to the delegate.
			delegate_.onLoadExternalModelPrefabComplete(this, filename, externalModelPrefab);
		}
	}
}