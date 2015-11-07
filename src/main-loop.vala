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

int ilog (uint _v) {
	int ret;
	for (ret = 0; _v != 0; ret++)
		_v >>= 1;
	return ret;
}

PngReader make_png_reader (string filename) throws VPng2TheoraError {
	try {
		return new PngReader (filename);
	}
	catch (Error e) {
		throw new VPng2TheoraError.
			PNG_READ ("could not read %s\n%s".printf (filename, e.message));
	}
}

void main_loop (Gee.List<string> png_files, int passno, 
                Options opts, TwoPassFile? twopass_file,
                StreamStateAdapter ogg_os, out Ogg.Page og,
                FileWriter ogg_fp) throws VPng2TheoraError {
	og = Ogg.Page ();
	string input_png;
	YCbCr ycbcr = new YCbCr ();

	input_png = Path.build_filename (opts.input_directory, png_files[0]);
	PngReader png_reader = make_png_reader (input_png);
	if (!ycbcr.read (png_reader, opts.chroma_format))
		throw new VPng2TheoraError.PNG_READ (@"could not read $input_png");
	if (passno != 2)
		stdout.printf ("%d frames, %ulx%ulo\n", png_files.size, 
		               png_reader.w, png_reader.h);

	// setup complete.  Raw processing loop
	switch (passno) {
		case 0:
		case 2:
			stderr.printf ("\rCompressing....                                          \n");
			break;
		case 1:
			stderr.printf ("\rScanning first pass....                                  \n");
			break;
	}

	stdout.printf ("%s\n", input_png);

	Theora.Info ti = Theora.Info ();
	ti.frame_width = ((png_reader.w + 15) >> 4) << 4;
	ti.frame_height = ((png_reader.h + 15) >> 4) << 4;
	ti.pic_width = png_reader.w;
	ti.pic_height = png_reader.h;
	ti.pic_x = 0;
	ti.pic_y = 0;
	ti.fps_numerator = opts.video_fps_numerator;
	ti.fps_denominator = opts.video_fps_denominator;
	ti.aspect_numerator = opts.video_aspect_numerator;
	ti.aspect_denominator = opts.video_aspect_denominator;
	ti.colorspace = Theora.Colorspace.UNSPECIFIED;
	ti.pixel_fmt = opts.chroma_format;
	ti.target_bitrate = opts.video_rate;
	ti.quality = opts.video_quality;
	ti.keyframe_granule_shift = ilog (opts.keyframe_frequency - 1);

	Theora.Encoder td = new Theora.Encoder (ref ti);
	// setting just the granule shift only allows power-of-two keyframe
	// spacing.  Set the actual requested spacing.
	if (td.ctl (Theora.EncodeCtl.SET_KEYFRAME_FREQUENCY_FORCE, 
	            &opts.keyframe_frequency, sizeof(uint32)) < 0) {
		stderr.printf ("Could not set keyframe interval to %lu.\n", 
		               opts.keyframe_frequency);
	}
	if (opts.vp3_compatible != 0) {
		Theora.ReturnCode ret = td.ctl (Theora.EncodeCtl.SET_VP3_COMPATIBLE, &opts.vp3_compatible, sizeof(int));
		if (ret < 0 || opts.vp3_compatible == 0) {
			stderr.printf ("Could not enable strict VP3 compatibility.\n");
			if (ret >= 0) {
				stderr.printf ("Ensure your source format is supported by VP3.\n");
				stderr.printf("(4:2:0 pixel format, width and height multiples of 16).\n");
			}
		}
	}
	if (opts.soft_target) {
		// reverse the rate control flags to favor a 'long time' strategy
		Theora.RateCtl arg = Theora.RateCtl.CAP_UNDERFLOW;
		Theora.ReturnCode ret = td.ctl (Theora.EncodeCtl.SET_RATE_FLAGS, &arg, sizeof (Theora.RateCtl));
		if (ret < 0)
			stderr.printf ("Could not set encoder flags for --soft-target\n");
		// Default buffer control is overridden on two-pass
		if (opts.twopass == 0 && opts.buf_delay < 0) {
			uint arg2;
			if ((opts.keyframe_frequency * 7 >> 1) > 5 * opts.video_fps_numerator / opts.video_fps_denominator)
				arg2 = opts.keyframe_frequency * 7 >> 1;
			else
				arg2 = 5 * opts.video_fps_numerator / opts.video_fps_denominator;
			ret = td.ctl (Theora.EncodeCtl.SET_RATE_BUFFER, &arg2, sizeof (uint));
			if (ret < 0)
				stderr.printf ("Could not set rate control buffer for --soft-target\n");
		}
	}
	// set up two-pass if needed 
	if (passno == 1) {
		uint8[] buffer;
		int bytes;
		bytes = td.ctl_arr_out (Theora.EncodeCtl.@2PASS_OUT, out buffer);
		if (bytes < 0)
			throw new VPng2TheoraError.GENERAL ("Could not set up the first pass of two-pass mode.\nDid you remember to specify an estimated bitrate?");
		buffer.length = bytes;
		// Perform a seek test to ensure we can overwrite this placeholder data at
		// the end; this is better than letting the user sit through a whole
		// encode only to find out their pass 1 file is useless at the end.
		((!)twopass_file).seek_test ();
		((!)twopass_file).write_all (buffer);
		((!)twopass_file).flush ();
	}
	if (passno == 2) {
		// Enable the second pass here.
		// We make this call just to set the encoder into 2-pass mode, because
		// by default enabling two-pass sets the buffer delay to the whole file
		// (because there's no way to explicitly request that behavior).
		//
		// If we waited until we were actually encoding, it would overwite our
		//  settings.
		if (td.ctl (Theora.EncodeCtl.@2PASS_IN, null, 0) < 0)
			throw new VPng2TheoraError.GENERAL ("Could not set up the second pass of two-pass mode.");
		if (opts.twopass == 3) {
			((!)twopass_file).rewind ();
		}
	}
	//Now we can set the buffer delay if the user requested a non-default one
	// (this has to be done after two-pass is enabled).
	if (passno != 1 && opts.buf_delay >= 0) {
		if (td.ctl (Theora.EncodeCtl.SET_RATE_BUFFER, &opts.buf_delay, sizeof(int)) < 0) {
			stderr.printf ("Warning: could not set desired buffer delay.\n");
		}
	}
	// write the bitstream header packets with proper page interleave
	Theora.Comments tc = Theora.Comments ();
	// first packet will get its own page automatically
	Ogg.Packet op = Ogg.Packet ();
	if (td.flushheader (ref tc, ref op) <= 0)
		throw new VPng2TheoraError.GENERAL ("Internal Theora library error.");
	// tc.clear ();
	if (passno != 1) {
		ogg_os.packetin (ref op);
		ogg_os.pageout (ref og);
		ogg_fp.write_all (og.header, "header");
		ogg_fp.write_all (og.body, "body");
	}
	// create the remaining theora headers
	for (;;) {
		Theora.ReturnCode ret = td.flushheader (ref tc, ref op);
		if (ret < 0)
			throw new VPng2TheoraError.GENERAL ("Internal Theora library error.");
		else if (ret == 0)
			break;
		if (passno != 1)
			ogg_os.packetin (ref op);
	}
	// Flush the rest of our headers. This ensures
	// the actual data in each stream will start
	// on a new page, as per spec.
	if (passno != 1) {
		while (ogg_os.flush (ref og)) {
			ogg_fp.write_all (og.header, "header");
			ogg_fp.write_all (og.body, "body");
		}
	}
	int i = 0;
	bool last = false;
	do {
		if (i >= png_files.size - 1)
			last = true;
		try {
			FrameWriter.run (ycbcr.ycbcr, last, passno, td, twopass_file, 
			                 opts.option_output, ogg_fp, ogg_os);
		}
		catch (VPng2TheoraError e) {
			throw new VPng2TheoraError.GENERAL ("%s\nEncoding error.".printf (e.message));
		}

		i++;
		if (!last) {
			input_png = "%s/%s".printf (opts.input_directory, png_files[i]);
			PngReader reader = new PngReader (input_png);
			if (!ycbcr.read (reader, opts.chroma_format))
				throw new VPng2TheoraError.GENERAL ("could not read %s".printf (input_png));
			stdout.printf ("%s\n", input_png);
		}
	} while (!last);

	if (passno == 1) {
		// need to read the final (summary) packet
		uint8[] buffer;
		int bytes = td.ctl_arr_out (Theora.EncodeCtl.@2PASS_OUT, out buffer);
		if (bytes < 0)
			throw new VPng2TheoraError.GENERAL ("Could not read two-pass summary data from encoder.");
		buffer.length = bytes;
		((!)twopass_file).rewind ();
		((!)twopass_file).write_all (buffer);
		((!)twopass_file).flush ();
	}
}
