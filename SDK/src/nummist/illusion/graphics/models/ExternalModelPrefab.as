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
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.resources.TextureResource;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.utils.Dictionary;
	
	import nummist.illusion.core.StringUtils;
	
	
	/**
	 * A factory and resource manager for a 3D model loaded from a .dae, .3ds,
	 * or .a3d file. There is support for meshes and various map types
	 * (diffuse, normal, specular, gloss, alpha). Maps may use either textures
	 * or uniform values. By type, omitted maps default to the following
	 * uniform values:
	 * <br /><br />
	 * diffuse: <code>0x808080</code> (50% gray)<br />
	 * normal: <code>0x8080ff</code> (up)<br />
	 * specular: <code>0xffffff</code> (white)<br />
	 * gloss: <code>0x808080</code> (50%)<br />
	 * opaque: <code>0xffffff</code> (opaque)
	 * <br /><br />
	 * Animations are unsupported.
	 * 
	 * @see AbstractPrefab
	 * @see ExternalModelPrefabLoader
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8CCwUKnjEeG8rNJMqBg6NQ
	 */
	public class ExternalModelPrefab
	{
		private static const KEY_DIFFUSE:String = "diffuse";
		private static const KEY_NORMAL:String = "bump";
		private static const KEY_SPECULAR:String = "specular";
		private static const KEY_GLOSS:String = "glossiness";
		private static const KEY_ALPHA:String = "transparent";
		
		private const model_:Object3D = new Object3D();
		private var scale_:Number = 1;
		private var externalTextures_:Vector.<ExternalTextureResource> =
			new Vector.<ExternalTextureResource>();
		private var bitmapTextures_:Vector.<BitmapTextureResource> =
			new Vector.<BitmapTextureResource>();
		private var geometries_:Vector.<Geometry> = new Vector.<Geometry>();
		private var texturesLoader_:TexturesLoader;
		
		
		/**
		 * Creates an ExternalModelPrefab object with the specified 3D graphics
		 * context, main file, and child Object3D instances.
		 * <br /><br />
		 * Do not invoke this constructor; instead, get ExternalModelPrefab
		 * instances by implementing IExternalModelPrefabLoader and creating
		 * one or more ExternalModelPrefab instances.
		 * 
		 * @param basePath The base path of the model's main file and textures.
		 * 
		 * @param filename The path to the model's main file, relative to
		 * basePath. Texture paths will be read from this file and interpreted
		 * relative to basePath.
		 * 
		 * @param objects The model's children, such as meshes.
		 * 
		 * @flowerModelElementId _8CQywqnjEeG8rNJMqBg6NQ
		 */
		public function ExternalModelPrefab
		(
			basePath:String,
			filename:String,
			objects:Vector.<Object3D>
		)
		{
			basePath = StringUtils.slashTerminate(basePath);
			var lowercaseFileExtension:String = StringUtils.lowercaseFileExtension(filename);
			
			if
			(
				lowercaseFileExtension != ExternalModelUtils.FORMAT_3DS &&
				lowercaseFileExtension != ExternalModelUtils.FORMAT_A3D &&
				lowercaseFileExtension != ExternalModelUtils.FORMAT_COLLADA
			)
			{
				throw ExternalModelUtils.newUnrecognizedFormatError(filename);
			}
			
			// Iterate over all the parsed nodes.
			for each (var object:Object3D in objects)
			{
				var mesh:Mesh = object as Mesh;
				if(!mesh)
				{
					// Skip the non-mesh node.
					continue;
				}
				
				// Add the mesh to the root node.
				model_.addChild(mesh);
				
				// Determine which geometries need to be loaded.
				for each(var resource:Resource in mesh.getResources(false, Geometry))
				{
					geometries_.push(resource as Geometry);
				}
				
				// Determine which textures need to be loaded.
				for (var j:int = 0; j < mesh.numSurfaces; j++)
				{
					var surface:Surface = mesh.getSurface(j);
					var material:ParserMaterial = surface.material as ParserMaterial;
					if (material)
					{
						surface.material = new StandardMaterial
						(
							textureResource(basePath, lowercaseFileExtension, material, KEY_DIFFUSE), // diffuseMap
							textureResource(basePath, lowercaseFileExtension, material, KEY_NORMAL), // normalMap
							textureResource(basePath, lowercaseFileExtension, material, KEY_SPECULAR), // specularMap
							textureResource(basePath, lowercaseFileExtension, material, KEY_GLOSS), // glossinessMap
							textureResource(basePath, lowercaseFileExtension, material, KEY_ALPHA) // opacityMap
						);
					}
				}
			}
		}
		
		
		/**
		 * The uniform scaling factor applied to new instances.
		 */
		public function get scale():Number
		{
			return scale_;
		}
		
		public function set scale(newScale:Number):void
		{
			scale_ = newScale;
			
			// Iterate over all the parsed nodes.
			for (var i:int = 0; i < model_.numChildren; i++)
			{
				var mesh:Mesh = model_.getChildAt(i) as Mesh;
				if(!mesh)
				{
					// Skip the non-mesh node.
					continue;
				}
				
				// Scale the mesh.
				mesh.scaleX = mesh.scaleY = mesh.scaleZ = newScale;
			}
		}
		
		
		/**
		 * Loads the model's geometry and textures into the specified 3D
		 * graphics context. If the resources are already loaded in another 3D
		 * graphics context, they are first unloaded. If the resources are
		 * already loaded in the specified 3D graphics context, no operation is
		 * performed.
		 * 
		 * @param context3D The 3D graphics context.
		 */
		public function loadResources(context3D:Context3D):void
		{
			if (texturesLoader_)
			{
				if (texturesLoader_.context == context3D)
				{
					// The resources are already loaded in this 3D graphics
					// context, so do nothing.
					return;
				}
				
				// The resources are already loaded in another 3D graphics
				// context, so unload them.
				disposeResources();
			}
			
			// Load the geometries into the 3D graphics context.
			for each (var geometry:Geometry in geometries_)
			{
				geometry.upload(context3D);
			}
			
			// Load the external textures into the 3D graphics context.
			texturesLoader_ = new TexturesLoader(context3D);
			texturesLoader_.loadResources(externalTextures_);
			
			// Load the bitmap textures into the 3D graphics context.
			for each (var bitmapTexture:BitmapTextureResource in bitmapTextures_)
			{
				bitmapTexture.upload(context3D);
			}
		}
		
		/**
		 * Unloads the model's geometry and textures from their current 3D
		 * graphics context, if any.
		 */
		public function disposeResources():void
		{
			if (!texturesLoader_)
			{
				return;
			}
			
			// Unload the geometries from the 3D graphics context.
			for each (var geometry:Geometry in geometries_)
			{
				geometry.dispose();
			}
			
			// Unload the external textures from the 3D graphics context.
			texturesLoader_.cleanAndDispose();
			texturesLoader_ = null;
			
			// Unload the bitmap textures from the 3D graphics context.
			for each (var bitmapTexture:BitmapTextureResource in bitmapTextures_)
			{
				bitmapTexture.dispose();
			}
		}
		
		/**
		 * Gets a new Object3D instance (with zero or more child meshes)
		 * representing the model. Geometry and texture resources are shared
		 * across all instances returned by this method.
		 */
		public function newObject3D():Object3D
		{
			return model_.clone();
		}
		
		
		
		private function textureResource
		(
			basePath:String,
			lowercaseFileExtension:String,
			material:ParserMaterial,
			textureKey:String
		)
		:TextureResource
		{
			// Attempt to look up an external texture by key.
			var externalTexture:ExternalTextureResource = material.textures[textureKey];
			
			if (externalTexture)
			{
				switch(lowercaseFileExtension)
				{
					case ExternalModelUtils.FORMAT_3DS:
					case ExternalModelUtils.FORMAT_A3D:
						// Set the absolute path to the external texture file.
						externalTexture.url = basePath + externalTexture.url;
						break;
					
					case ExternalModelUtils.FORMAT_COLLADA:
					default:
						// Do nothing, as the Collada parser already sets the
						// absolute path to the texture file.
						break;
				}
				
				for each (var otherExternalTexture:ExternalTextureResource in externalTextures_)
				{
					if (externalTexture.url == otherExternalTexture.url)
					{
						// An equivalent external texture is already in the
						// list of those needing to be loaded.
						
						return otherExternalTexture;
					}
				}
				
				// Add the external texture to the list of those needing to be
				// loaded.
				externalTextures_.push(externalTexture);
				
				return externalTexture;
			}
			
			// There is no external texture associated with the key.
			
			// Attempt to look up an externally specified color by key. Failing
			// that, look up a default color by key.
			var materialColor:* = material.colors[textureKey];
			var color:uint =
			(
				materialColor != null
				?
					materialColor
				:
					defaultColor(textureKey)
			);
			
			// Create a bitmap texture that is a solid color.
			var bitmapTexture:BitmapTextureResource =
				new BitmapTextureResource(new BitmapData(1, 1, false, color));
			
			for each (var otherBitmapTexture:BitmapTextureResource in bitmapTextures_)
			{
				if (bitmapTexture.data.compare(otherBitmapTexture.data) == 0)
				{
					// An equivalent bitmap texture is already in the list of
					// those needing to be loaded.
					
					return otherBitmapTexture;
				}
			}
			
			// Add the bitmap texture to the list of those needing to be
			// loaded.
			bitmapTextures_.push(bitmapTexture);
			
			return bitmapTexture;
		}
		
		
		/**
		 * @flowerModelElementId _8CXgdKnjEeG8rNJMqBg6NQ
		 */
		private function defaultColor(textureKey:String):uint
		{
			switch (textureKey)
			{
				case KEY_NORMAL: // up
					return 0x8080ff;
				
				case KEY_SPECULAR: // white
				case KEY_ALPHA: // opaque
					return 0xffffff;
				
				case KEY_DIFFUSE: // 50% gray
				case KEY_GLOSS: // 50%
				default:
					return 0x808080;
			}
		}
	}
}