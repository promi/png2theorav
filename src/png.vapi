/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * png2theorav - create theora movie from png files
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
 */

[CCode (cheader_filename = "png.h")]
namespace Png {

	[CCode (cname = "PNG_LIBPNG_VER_STRING")]
	const string LIBPNG_VER_STRING;

	[CCode (cname = "PNG_COLOR_MASK_COLOR")]
	const int COLOR_MASK_COLOR;

	[CCode (cname = "PNG_BACKGROUND_GAMMA_FILE")]
	const int BACKGROUND_GAMMA_FILE;

	[CCode (cname = "png_error_ptr", has_target = false, has_type_id = false)]
	public delegate void ErrorFn (Struc struc, 
	                              [CCode (array_length = false, 
	                                      array_null_terminated = true)] 
	                              uint8[] arr);
	[CCode (cname = "png_rw_ptr", has_target = false, has_type_id = false)]
	public delegate void RwFn (Struc struc, [CCode (array_length_type = "size_t")] uint8[] data);
	[CCode (cname = "png_struct", free_function = "")]
	[Compact]
	public class Struc {
		[CCode (cname = "png_create_read_struct")]
		public Struc ([CCode (array_length = false, 
		                      array_null_terminated = true)] 
		              uint8[] user_png_ver = LIBPNG_VER_STRING.data, 
		              void *error_ptr = null, ErrorFn error_fn = (ErrorFn) null, 
		              ErrorFn warn_fn = (ErrorFn) null);
		[CCode (cname = "png_get_io_ptr")]
		public void* get_io_ptr ();
		[CCode (cname = "png_set_read_fn")]
		public void set_read_fn (void *io_ptr, RwFn read_data_fn);
		[CCode (cname = "png_set_sig_bytes")]
		public void set_sig_bytes (int num_bytes);
		[CCode (cname = "png_read_info")]
		public void read_info (Info info);
		[CCode (cname = "png_get_IHDR")]
		public uint32 get_IHDR (Info info_ptr, out uint32 width, 
		                        out uint32 height, out int bit_depth, 
		                        out int color_type, 
		                        out int interlace_method, 
		                        out int compression_method, 
		                        out int filter_method);
		[CCode (cname = "png_set_expand")]
		public void set_expand ();
		[CCode (cname = "png_set_packing")]
		public void set_packing ();
		[CCode (cname = "png_set_strip_16")]
		public void set_strip_16 ();
		[CCode (cname = "png_set_gray_to_rgb")]
		public void set_gray_to_rgb ();
		[CCode (cname = "png_get_bKGD")]
		public uint32 get_bKGD (Info info_ptr, out Color16 background);
		[CCode (cname = "png_set_background")]
		public void set_background (Color16 background_color,
		                            int background_gamma_code,
		                            int need_expand,
		                            double background_gamma);
		[CCode (cname = "png_set_strip_alpha")]
		public void set_strip_alpha ();
		[CCode (cname = "png_malloc")]
		public void* malloc (uint32 size);
		[CCode (cname = "png_free")]
		public void free (void *ptr);
		[CCode (cname = "png_read_image")]
		public void read_image ([CCode (array_length = false)] uint8*[] image);
		[CCode (cname = "png_read_end")]
		public void read_end (Info info_ptr);
	}

	[CCode (cname = "png_info", free_function = "")]
	[Compact]
	public class Info {
		[CCode (cname = "png_create_info_struct")]
		public Info (Struc png_ptr);
	}

	[CCode (cname = "png_color_16", free_function = "")]
	[Compact]
	public class Color16 {
		
	}

	public int sig_cmp ([CCode (array_length = false, 
	                            array_null_terminated = true)] uint8[] sig, 
	                    size_t start, size_t num_to_check);

	public void destroy_read_struct (Struc** png_ptr_ptr, 
	                                 Info** info_ptr_ptr = null, 
	                                 Info** end_info_ptr_ptr = null);
}
