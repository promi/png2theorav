/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * png2theorav - create theora movie from png files
 * Copyright (C) 2002-2009 Xiph.Org Foundation and contributors 
 *                         <http://www.xiph.org>
 * Copyright (C) 2015 Prometheus <prometheus@unterderbruecke.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.

 * This is a derived work, original license and copyright:

 ********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggTheora SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE Theora SOURCE CODE IS COPYRIGHT (C) 2002-2009,2009           *
 * by the Xiph.Org Foundation and contributors http://www.xiph.org/ *
 *                                                                  *
 ********************************************************************

  function: example encoder application; makes an Ogg Theora
            file from a sequence of png images
  last mod: $Id$
             based on code from Vegard Nossum

 ********************************************************************
 */

public class TwoPassFile : GLib.Object {

	private FileIOStream ios;
	private OutputStream os;
	private InputStream @is;

	public TwoPassFile (string filename) throws VPng2TheoraError {
		try {
			ios = File.parse_name (filename).
				replace_readwrite (null, false, FileCreateFlags.NONE);
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				OPEN_OUTPUT_FILE ("%s: error: couldn't open output file - %s".
					              printf (filename, e.message));
		}
		os = ios.output_stream;
		@is = ios.input_stream;
	}

	public TwoPassFile.tmp () throws VPng2TheoraError {
		try {
			File.new_tmp (null, out ios);
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				OPEN_OUTPUT_FILE ("error: couldn't create temp file");
		}
		os = ios.output_stream;
		@is = ios.input_stream;
	}

	public void seek_test () throws VPng2TheoraError {
		try {
			ios.seek (0, SeekType.SET);
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				GENERAL ("Unable to seek in two-pass data file.");
		}
	}

	public void write_all (uint8[] buffer) throws VPng2TheoraError {
		try {
			if (os.write (buffer) < buffer.length)
				throw new VPng2TheoraError.
					GENERAL ("Unable to write to two-pass data file.");
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				GENERAL ("Unable to write to two-pass data file.");
		}
	}

	public void flush () throws VPng2TheoraError {
		try {
			os.flush ();
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				GENERAL ("Unable to write to two-pass data file.");
		}
	}

	public void rewind () throws VPng2TheoraError {
		try {
			if (!ios.seek (SeekType.SET, 0))
				throw new VPng2TheoraError.
					GENERAL ("Unable to seek in two-pass data file.");
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				GENERAL ("Unable to seek in two-pass data file.");
		}
	}

	public void read_all (uint8[] buffer) throws VPng2TheoraError {
		try {
			if (@is.read (buffer) < buffer.length)
				throw new IOError.FAILED ("");
		}
		catch (IOError e) {
			throw new VPng2TheoraError.
				GENERAL ("Could not read frame data from two-pass data file!");
		}
	}
}

