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
	import flash.display.Bitmap;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import nummist.illusion.mixedreality.PixelFeed;
	

	internal class FlareUtils
	{
		private static var matrixRawVector:Vector.<Number> = new Vector.<Number>(16);
		
		
		internal static function rawCamConfig(pixelFeed:PixelFeed):ByteArray
		{
			var width:uint = pixelFeed.width;
			var height:uint = pixelFeed.height;
			var diagonalFOV:Number = pixelFeed.diagonalFOV;
			
			// Calculate the focal length based on the dimensions and FOV.
			var focalLength:Number =
				(Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2))) /
				(2 * Math.tan(0.5 * diagonalFOV));
			
			// Write and return the camera configuration as raw bytes.
			var rawCamConfig:ByteArray = new ByteArray();
			rawCamConfig.writeUTFBytes
			(
				"ARToolKitPlus_CamCal_Rev02\n" +
				width + " " + height + " " + // dimensions
				(0.5 * width) + " " + (0.5 * height) + " " + // center
				focalLength + " " + focalLength + " " +
				"0 0 0 0 0 0 0\n"
			);
			return rawCamConfig;
		}
		
		internal static function matrix(matrixRawBytes:ByteArray):Matrix3D
		{
			// Copy the raw bytes into the vector.
			
			matrixRawVector[ 0] = matrixRawBytes.readFloat();
			matrixRawVector[ 1] = matrixRawBytes.readFloat();
			matrixRawVector[ 2] = matrixRawBytes.readFloat();
			matrixRawVector[ 3] = matrixRawBytes.readFloat();
			
			matrixRawVector[ 4] = matrixRawBytes.readFloat();
			matrixRawVector[ 5] = matrixRawBytes.readFloat();
			matrixRawVector[ 6] = matrixRawBytes.readFloat();
			matrixRawVector[ 7] = matrixRawBytes.readFloat();
			
			matrixRawVector[ 8] = matrixRawBytes.readFloat();
			matrixRawVector[ 9] = matrixRawBytes.readFloat();
			matrixRawVector[10] = matrixRawBytes.readFloat();
			matrixRawVector[11] = matrixRawBytes.readFloat();
			
			matrixRawVector[12] = matrixRawBytes.readFloat();
			matrixRawVector[13] = matrixRawBytes.readFloat();
			matrixRawVector[14] = matrixRawBytes.readFloat();
			matrixRawVector[15] = matrixRawBytes.readFloat();
			
			// Copy the vector into the matrix and return the matrix.
			return new Matrix3D(matrixRawVector);
		}
		
		internal static function rawPGM(rawBitmap:ByteArray):ByteArray
		{
			if (!(rawBitmap is Bitmap))
			{
				throw new ArgumentError("rawBitmap must be castable to type Bitmap");
			}
			
			// Get the bitmap's pixels and their count.
			var bitmap:Bitmap = Bitmap(rawBitmap);
			var rect:Rectangle = new Rectangle(0, 0, bitmap.width, bitmap.height);
			var pixels:ByteArray = bitmap.bitmapData.getPixels(rect);
			var numPixels:uint = (pixels.length >> 2);
			
			// Create the container for the 8-bit binary .pgm data.
			var pgmData:ByteArray = new ByteArray();
			
			// Write the .pgm header.
			pgmData.writeUTFBytes("P5\n# flare*\n" + bitmap.width + " " + bitmap.height + "\n255\n");
			
			// Iterate over all the pixels, converting to grayscale, with the
			// green channel counted double.
			pixels.position = 0;
			var gray:uint;
			while (numPixels--)
			{
				// Skip the alpha channel.
				pixels.readUnsignedByte();
				
				// Calculate the gray channel.
				gray =
				(
					pixels.readUnsignedByte() +
					(pixels.readUnsignedByte() << 1) +
					pixels.readUnsignedByte()
				) >> 2;
				
				// Write the gray channel to the .pgm data.
				pgmData.writeByte(gray);
			}
			
			return pgmData;
		}
	}
}