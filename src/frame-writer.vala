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

public class FrameWriter : GLib.Object {

	public FrameWriter () {

	}

	public static void run (Theora.ImgPlane [] ycbcr, bool last, int passno, 
	                        Theora.Encoder td, TwoPassFile? twopass_file,
	                        string option_output, FileWriter ogg_fp,
	                        StreamStateAdapter ogg_os) throws VPng2TheoraError {
		Ogg.Packet op = Ogg.Packet ();

		// Theora is a one-frame-in,one-frame-out system; submit a frame
		// for compression and pull out the packet
		// in two-pass mode's second pass, we need to submit first-pass data
		if (passno == 2) {
			int ret;
			for (;;) {
				int bytes;
				// Ask the encoder how many bytes it would like.
				bytes = td.ctl (Theora.EncodeCtl.@2PASS_IN, null, 0);
				if (bytes < 0)
					throw new VPng2TheoraError.GENERAL ("Error submitting pass data in second pass.");
				// If it's got enough, stop.
				if (bytes == 0)
					break;
				uint8[] buffer = new uint8[bytes];
				((!)twopass_file).read_all (buffer);
				// And pass them off.
				ret = td.ctl_arr_in (Theora.EncodeCtl.@2PASS_IN, buffer);
				if (ret < 0)
					throw new VPng2TheoraError.GENERAL ("Error submitting pass data in second pass.");
			}
		}

		if (td.ycbcr_in (ycbcr) != 0)
			throw new VPng2TheoraError.GENERAL ("%s: error: could not encode frame".printf (option_output));

		// in two-pass mode's first pass we need to extract and save the pass data
		if (passno == 1) {
			uint8[] buffer;
			int bytes = td.ctl_arr_out (Theora.EncodeCtl.@2PASS_OUT, out buffer);
			if (bytes < 0)
				throw new VPng2TheoraError.GENERAL ("Could not read two-pass data from encoder.");
			((!)twopass_file).write_all (buffer);
			((!)twopass_file).flush ();
		}

		int last_int = last ? 1 : 0;
		if (td.packetout (last_int, ref op) == 0)
			throw new VPng2TheoraError.GENERAL ("%s: error: could not read packets".printf (option_output));

		if (passno != 1) {
			ogg_os.packetin (ref op);
			Ogg.Page og = Ogg.Page ();
			while (ogg_os.pageout (ref og)) {
				ogg_fp.write_all (og.header, "header");
				ogg_fp.write_all (og.body, "body");
			}
		}
	}
}

