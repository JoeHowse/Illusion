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
	import nummist.illusion.core.MathUtils;
	
	/**
	 * A set of barcode feature definitions used in constructing a
	 * FlareBarcodeTracker object.
	 * 
	 * @see FlareBarcodeTracker
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _8D38UKnjEeG8rNJMqBg6NQ
	 */
	public class FlareBarcodeFeatureSet
	{
		/**
		 * The filenames for the images that will be tracked as template
		 * markers. The filenames' base path is specified when constructing a
		 * FlareBarcodeTracker object.
		 * <br /><br />
		 * Each file should be either a pattern file in ARToolKit format or an
		 * image in .pgm format. You can use
		 * <a href="http://flash.tarotaro.org/blog/2009/07/12/mgo2/">Tarotaro's
		 * Online Generator</a> to generate new template markers. When
		 * generating a .pgm file, make sure that it contains only the marker's
		 * interior without its border.
		 */
		public const templateFilenames:Vector.<String> = new Vector.<String>();
		
		
		
		private var numSimpleIDs_:uint = 0;
		
		private var simpleIDMillimeters_:Number = 80;
		
		private var simpleIDBorderRatio_:Number = 0.125;
		
		
		private var numBCHs_:uint = 0;
		
		private var bchMillimeters_:Number = 80;
		
		private var bchBorderRatio_:Number = 0.125;
		
		
		private var templateBorderRatio_:Number = 0.25;
		
		private var templatePatternSize_:uint = 16;
		
		
		private var numFrames_:uint = 0;
		
		private var frameMillimeters_:Number = 100;
		
		private var frameBorderRatio_:Number = 0.04545;
		
		
		private var numDataMatrices_:uint = 0;
		
		private var dataMatrixBorderRatio_:Number = 0.035;
		
		
		/**
		 * The number of simple ID markers. They are taken from the start of
		 * flare*tracker's sequence of predefined simple ID markers. The
		 * initial value is 0.
		 * 
		 * @throws ArgumentError if set to a value greater than 512.
		 */
		public function get numSimpleIDs():uint
		{
			return numSimpleIDs_;
		}
		
		public function set numSimpleIDs(newNumSimpleIDs:uint):void
		{
			if (newNumSimpleIDs > 512)
			{
				throw new ArgumentError("numSimpleIDs must be in the range [0, 512]");
			}
			
			numSimpleIDs_ = newNumSimpleIDs;
		}
		
		/**
		 * The width in millimeters of a simple ID marker, including the
		 * border. The initial value is 80.
		 * 
		 * @throws ArgumentError if set to a non-positive value.
		 */
		public function get simpleIDMillimeters():Number
		{
			return simpleIDMillimeters_;
		}
		
		public function set simpleIDMillimeters(newSimpleIDMillimeters:Number):void
		{
			if (newSimpleIDMillimeters <= 0)
			{
				throw new ArgumentError("simpleIDMillimeters must be positive");
			}
			
			simpleIDMillimeters_ = newSimpleIDMillimeters;
		}
		
		/**
		 * The width of a simple ID marker's border, in proportion to
		 * <code>simpleIDMillimeters</code>. The initial value is 0.125.
		 * 
		 * @throws ArgumentError if set to a negative value.
		 */
		public function get simpleIDBorderRatio():Number
		{
			return simpleIDBorderRatio_;
		}
		
		public function set simpleIDBorderRatio(newSimpleIDBorderRatio:Number):void
		{
			if (newSimpleIDBorderRatio <= 0)
			{
				throw new ArgumentError("simpleIDBorderRatio must be non-negative");
			}
			
			simpleIDBorderRatio_ = newSimpleIDBorderRatio;
		}
		
		
		/**
		 * The number of BCH markers. They are taken from the start of
		 * flare*tracker's sequence of predefined BCH markers. The initial
		 * value is 0.
		 * 
		 * @throws ArgumentError if set to a value greater than 4096.
		 */
		public function get numBCHs():uint
		{
			return numBCHs_;
		}
		
		public function set numBCHs(newNumBCHs:uint):void
		{
			if (newNumBCHs > 4096)
			{
				throw new ArgumentError("numBCHs must be in the range [0, 4096]");
			}
			
			numBCHs_ = newNumBCHs;
		}
		
		/**
		 * The width in millimeters of a BCH marker, including the border. The
		 * initial value is 80.
		 * 
		 * @throws ArgumentError if set to a non-positive value.
		 */
		public function get bchMillimeters():Number
		{
			return bchMillimeters_;
		}
		
		public function set bchMillimeters(newBCHMillimeters:Number):void
		{
			if (newBCHMillimeters <= 0)
			{
				throw new ArgumentError("bchMillimeters must be positive");
			}
			
			bchMillimeters_ = newBCHMillimeters;
		}
		
		/**
		 * The width of a BCH marker's border, in proportion to
		 * <code>bchMillimeters</code>. The initial value is 0.125.
		 * 
		 * @throws ArgumentError if set to a negative value.
		 */
		public function get bchBorderRatio():Number
		{
			return bchBorderRatio_;
		}
		
		public function set bchBorderRatio(newBCHBorderRatio:Number):void
		{
			if (newBCHBorderRatio <= 0)
			{
				throw new ArgumentError("bchBorderRatio must be non-negative");
			}
			
			bchBorderRatio_ = newBCHBorderRatio;
		}
		
		
		/**
		 * The width of a template marker's border, in proportion to the total
		 * width of the marker and its border. The initial value is 0.25.
		 * 
		 * @throws ArgumentError if set to a negative value.
		 */
		public function get templateBorderRatio():Number
		{
			return templateBorderRatio_;
		}
		
		public function set templateBorderRatio(newTemplateBorderRatio:Number):void
		{
			if (newTemplateBorderRatio <= 0)
			{
				throw new ArgumentError("templateBorderRatio must be non-negative");
			}
			
			dataMatrixBorderRatio_ = newTemplateBorderRatio;
		}
		
		/**
		 * The horizontal and vertical resolution of a template marker. The
		 * initial value is 16.
		 * 
		 * throws ArgumentError if set to a value that is not a power-of-2
		 * integer in the range [4, 64].
		 */
		public function get templatePatternSize():uint
		{
			return templatePatternSize_;
		}
		
		public function set templatePatternSize(newTemplatePatternSize:uint):void
		{
			if
			(
				newTemplatePatternSize < 4 ||
				newTemplatePatternSize > 64 ||
				!(MathUtils.isPowerOf2(newTemplatePatternSize))
			)
			{
				throw new ArgumentError("templatePatternSize must be a power-of-2 integer in the range [4, 64]");
			}
			
			templatePatternSize_ = newTemplatePatternSize;
		}
		
		
		/**
		 * The number of frame markers. They are taken from the start of
		 * flare*tracker's sequence of predefined frame markers. The initial
		 * value is 0.
		 * 
		 * @throws ArgumentError if set to a value greater than 512.
		 */
		public function get numFrames():uint
		{
			return numFrames_;
		}
		
		public function set numFrames(newNumFrames:uint):void
		{
			if (newNumFrames > 512)
			{
				throw new ArgumentError("numSimpleIDs must be in the range [0, 512]");
			}
			
			numFrames_ = newNumFrames;
		}
		
		/**
		 * The width in millimeters of a frame marker, including the border.
		 * The initial value is 100.
		 * 
		 * @throws ArgumentError if set to a non-positive value.
		 */
		public function get frameMillimeters():Number
		{
			return frameMillimeters_;
		}
		
		public function set frameMillimeters(newFrameMillimeters:Number):void
		{
			if (newFrameMillimeters <= 0)
			{
				throw new ArgumentError("frameMillimeters must be positive");
			}
			
			frameMillimeters_ = newFrameMillimeters;
		}
		
		/**
		 * The width of a frame marker's border, in proportion to
		 * <code>frameMillimeters</code>. The initial value is 0.04545.
		 * 
		 * @throws ArgumentError if set to a negative value.
		 */
		public function get frameBorderRatio():Number
		{
			return frameBorderRatio_;
		}
		
		public function set frameBorderRatio(newFrameBorderRatio:Number):void
		{
			if (newFrameBorderRatio <= 0)
			{
				throw new ArgumentError("frameBorderRatio must be non-negative");
			}
			
			frameBorderRatio_ = newFrameBorderRatio;
		}
		
		
		/**
		 * The number of data matrix markers. The initial value is 0.
		 */
		public function get numDataMatrices():uint
		{
			return numDataMatrices_;
		}
		
		public function set numDataMatrices(newNumDataMatrices:uint):void
		{
			numDataMatrices_ = newNumDataMatrices;
		}
		
		
		/**
		 * The width of a data matrix marker's border, in proportion to the
		 * total width of the marker and its border. The initial value is
		 * 0.035.
		 * 
		 * @throws ArgumentError if set to a negative value.
		 */
		public function get dataMatrixBorderRatio():Number
		{
			return dataMatrixBorderRatio_;
		}
		
		public function set dataMatrixBorderRatio(newDataMatrixBorderRatio:Number):void
		{
			if (newDataMatrixBorderRatio <= 0)
			{
				throw new ArgumentError("dataMatrixBorderRatio must be non-negative");
			}
			
			dataMatrixBorderRatio_ = newDataMatrixBorderRatio;
		}
	}
}