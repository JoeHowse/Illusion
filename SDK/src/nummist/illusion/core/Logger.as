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
	/**
	 * A logger with configurable verbosity.
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _7_8ekKnjEeG8rNJMqBg6NQ
	 */
	public class Logger
	{
		/**
		 * A shared instance.
		 */
		public static const mainLogger:Logger = new Logger();
		
		
		/**
		 * The maximum level of message that is logged.
		 */
		public var verbosity:uint = 0;
		
		
		/**
		 * Log the specified message with the specified tag and level, if the
		 * level is less than or equal to the verbosity.
		 * 
		 * @param tag The tag, such as the name of the class or library that is
		 * generating the message.
		 * 
		 * @param level The priority level, with 0 being the highest priority
		 * (always logged), 1 the next-to-highest, and so on.
		 * 
		 * @message The message.
		 */
		public function log(tag:String, level:uint, message:String):void
		{
			if (level <= verbosity)
			{
				trace(tag + ": [" + level + "] " + message);
			}
		}
	}
}