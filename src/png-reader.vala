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

public class PngReader : GLib.Object {

	private static void user_read_data (Png.Struc png_ptr, uint8[] data) {
		void* a = png_ptr.get_io_ptr ();
		try {
			((FileIOStream) a).input_stream.read (data);
		}
		catch (IOError e) {
			//
		}
	}

	public unowned uint8*[] row_pointers;
	public uint32 w = 0;
	public uint32 h = 0;

	public PngReader (string pathname) throws VPng2TheoraError {
		File file = File.new_for_path (pathname);
		FileIOStream fp;
		try {
			fp = file.open_readwrite ();
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				PNG_READ ("%s: error: %s".printf (pathname, e.message));
		}
		uint8[] header = new uint8[8];
		try {
			fp.input_stream.read (header);
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				PNG_READ ("%s: error: %s".printf (pathname, e.message));
		}
		if (Png.sig_cmp(header, 0, 8) != 0)
			throw new VPng2TheoraError.
				PNG_READ ("%s: error: %s".printf (pathname, "not a PNG"));
		png_ptr = new Png.Struc ();
		info_ptr = new Png.Info (png_ptr);
		end_ptr = new Png.Info (png_ptr);
		png_ptr.set_read_fn (fp, user_read_data);
		png_ptr.set_sig_bytes (8);
		png_ptr.read_info (info_ptr);
		int bit_depth;
		int color_type;
		int interlace_type;
		int compression_type;
		int filter_method;
		png_ptr.get_IHDR (info_ptr, out w, out h, out bit_depth, 
		                  out color_type, out interlace_type, 
		                  out compression_type, out filter_method);
		png_ptr.set_expand ();
		if (bit_depth < 8) 
			png_ptr.set_packing ();
		if (bit_depth == 16)
			png_ptr.set_strip_16 ();
		if ((color_type & Png.COLOR_MASK_COLOR) != 0)
			png_ptr.set_gray_to_rgb ();
		Png.Color16 bkgd;
		if (png_ptr.get_bKGD (info_ptr, out bkgd) != 0)
			png_ptr.set_background(bkgd, Png.BACKGROUND_GAMMA_FILE, 1, 1.0);
		// Note that color_type 2 and 3 can also have alpha, despite not setting the
		// PNG_COLOR_MASK_ALPHA bit.
		// We always strip it to prevent libpng from overrunning our buffer.
		png_ptr.set_strip_alpha ();
		row_data = (uint8[]) png_ptr.malloc (3 * h * w);
		row_pointers = (uint8*[]) png_ptr.malloc (h * (uint32) sizeof(uint8*));
		for (uint32 y = 0; y < h; y++)
			row_pointers[y] = (uint8[])((size_t)row_data + y * (3 * w));
		png_ptr.read_image (row_pointers);
		png_ptr.read_end (end_ptr);
	}

	~PngReader() {
		png_ptr.free (row_pointers);
		png_ptr.free (row_data);
		Png.destroy_read_struct (&png_ptr, &info_ptr, &end_ptr);
		Png.destroy_read_struct (&png_ptr, &info_ptr, null);
		Png.destroy_read_struct (&png_ptr, null, null);
	}

	private Png.Struc png_ptr;
	private Png.Info info_ptr;
	private Png.Info end_ptr;
	private unowned uint8[] row_data;
}
