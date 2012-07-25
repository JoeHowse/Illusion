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


package nummist.illusion.graphics.materials
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.resources.TextureResource;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import nummist.illusion.core.MathUtils;
	
	
	use namespace alternativa3d;
	
	
	/**
	 * A TextureMaterial subclass that continually updates a diffuse map based
	 * on a DisplayObject instance.
	 * 
	 * @author Joseph Howse<br />David E. Jones
	 * 
	 * @flowerModelElementId _8BU-oKnjEeG8rNJMqBg6NQ
	 */
	public class DisplayObjectMaterial extends TextureMaterial
	{
		private var displayObject_:DisplayObject;
		private var width_:uint;
		private var height_:uint;
		private var bitmapData_:BitmapData;
		private var matrix_:Matrix = new Matrix();
		
		
		/**
		 * Creates a DisplayObjectMaterial instance with a diffuse map that is
		 * a real-time rendering of the specified DisplayObject at the
		 * specified resolution or higher. As long as the DisplayObjectMaterial
		 * instance is in a 3D secene, the diffuse map is continually redrawn
		 * and reloaded into the 3D graphics context.
		 * 
		 * @param displayObject The DisplayObject instance.
		 * 
		 * @param width The diffuse map's horizontal resolution. If not a power
		 * of 2, it is rounded up to the next power of 2.
		 * 
		 * @param height The diffuse map's vertical resolution. If not a power
		 * of 2, it is rounded up to the next power of 2.
		 * 
		 * @throws ArgumentError if displayObject is <code>null</code>.
		 * 
		 * @flowerModelElementId _8BZQE6njEeG8rNJMqBg6NQ
		 */
		public function DisplayObjectMaterial
		(
			displayObject:DisplayObject,
			width:uint=256,
			height:uint=256
		)
		:void
		{
			displayObject_ = displayObject;
			width_ = MathUtils.nextPowerOf2(width);
			height_ = MathUtils.nextPowerOf2(height);
			bitmapData_ = new BitmapData(width_, height_);
			
			super
			(
				new BitmapTextureResource(bitmapData_), // diffuseMap
				null, // opacityMap
				1 // alpha
			);
			
			if (!displayObject_)
			{
				throw new ArgumentError("displayObject must be non-null");
			}
		}
		
		
		/**
		 * Unloads the diffuse map from its current 3D graphics context, if
		 * any. If the MovieMaterial object is in a 3D secene, the diffuse map
		 * will still be reloaded automatically.
		 */
		public function unloadResources():void
		{
			diffuseMap.dispose();
		}
		
		
		/**
		 * @flowerModelElementId _8BevoanjEeG8rNJMqBg6NQ
		 */
		override alternativa3d function collectDraws
		(
			camera:Camera3D,
			surface:Surface,
			geometry:Geometry,
			lights:Vector.<Light3D>,
			lightsLength:int,
			objectRenderPriority:int = -1
		)
		:void
		{
			if (diffuseMap)
			{
				// Update the scaling matrix.
				matrix_.a = width_ / displayObject_.width;
				matrix_.d = height_ / displayObject_.height;
				
				// Redraw the display object to the diffuse map's underlying
				// bitmap data.
				bitmapData_.draw(displayObject_);
				
				// Load the updated diffuse map into the 3D graphics context.
				diffuseMap.upload(camera.context3D);
			}
			
			super.collectDraws
			(
				camera,
				surface,
				geometry,
				lights,
				lightsLength,
				objectRenderPriority
			);
		}
	}
}