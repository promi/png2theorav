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

public class Options : GLib.Object {

	public string option_output = "";
	public int video_fps_numerator = 24;
	public int video_fps_denominator = 1;
	public int video_aspect_numerator = 0;
	public int video_aspect_denominator = 0;
	public int video_rate = -1;
	public int video_quality = -1;
	public uint32 keyframe_frequency = 0;
	public int buf_delay = -1;
	public int vp3_compatible = 0;
	public Theora.PixelFmt chroma_format = Theora.PixelFmt.@420;
	public bool soft_target = false;
	public int twopass = 0;
	public string input_directory = "";
	public string input_filter = "";
	public string twopass_filename = "";

	private string input_mask = "";
	private int video_quality_decimal = -1;
	private double video_rate_kb = -1;
	private bool singlepass = true;
	private bool twopass_ = false;
	private string firstpass_filename = "";
	private string secondpass_filename = "";
	private bool chroma_444 = false;
	private bool chroma_422 = false;
	private bool chroma_420 = true;

	public void parse (ref unowned string[] args) throws Error {
		var options = new OptionEntry[19];
		options[0] =
		{"output", 'o', 0, OptionArg.FILENAME, ref option_output, 
			"file name for encoded output (required);", "FILE" };
		options[1] =
		{"video-quality", 'v', 0, OptionArg.INT, ref video_quality_decimal,
			"Theora quality selector from 0 to 10 (0 yields smallest files " + 
			"but lowest video quality. 10 yields highest fidelity but " + 
			"large files)", "INT" };
		options[2] =
		{"video-rate-target", 'V', 0, OptionArg.DOUBLE, ref video_rate_kb,
			"bitrate target for Theora video (kB)", "DOUBLE"};
		options[3] =
		{"soft-target", 0, 0, OptionArg.NONE, ref soft_target,
			"Use a large reservoir and treat the rate as a soft target; " + 
			"rate control is less strict but resulting quality is usually " +
			"higher/smoother overall. Soft target also allows an optional " + 
			"-v setting to specify a minimum allowed quality.", null};
		options[4] =
		{"single-pass", 0, 0, OptionArg.NONE, ref singlepass,
			"Single pass (default).", null};
		options[5] =
		{"two-pass", 0, 0, OptionArg.NONE, ref twopass_,
			"Compress input using two-pass rate control. This option " +
			"performs both passes automatically.", null};
		options[6] =
		{"first-pass", 0, 0, OptionArg.FILENAME, ref firstpass_filename,
			"Perform first-pass of a two-pass rate controlled encoding, " +
			"saving pass data to FILE for a later second pass", "FILE"};
		options[7] =
		{"second-pass", 0, 0, OptionArg.FILENAME, ref secondpass_filename,
			"Perform second-pass of a two-pass rate controlled encoding, " +
			"reading first-pass data from FILE. The first pass data must " +
			"come from a first encoding pass using identical input video " + 
			"to work properly.", "FILE"};
		options[8] =
		{"keyframe-freq", 'k', 0, OptionArg.INT, ref keyframe_frequency,
			"Keyframe frequency", "INT"};
		options[9] =
		{"buf-delay", 'd', 0, OptionArg.INT, ref buf_delay,
			"Buffer delay (in frames). Longer delays allow smoother rate " + 
			"adaptation and provide better overall quality, but require " + 
			"more client side buffering and add latency. The default value " +
			"is the keyframe interval for one-pass encoding (or somewhat " + 
			"larger if --soft-target is used) and infinite for two-pass " +
			"encoding.", "INT"};
		options[10] =
		{"chroma-444", 0, 0, OptionArg.NONE, ref chroma_444, 
			"Use 4:4:4 chroma subsampling", null};
		options[11] =
		{"chroma-422", 0, 0, OptionArg.NONE, ref chroma_422, 
			"Use 4:2:2 chroma subsampling", null};
		options[12] =
		{"chroma-420", 0, 0, OptionArg.NONE, ref chroma_420, 
			"Use 4:2:0 chroma subsampling (default)", null};
		options[13] =
		{"aspect-numerator", 's', 0, OptionArg.INT, ref video_aspect_numerator, 
			"Aspect ratio numerator, default is 0", "INT"};
		options[14] =
		{"aspect-denominator", 'S', 0, OptionArg.INT, 
			ref video_aspect_denominator, 
			"Aspect ratio denominator, default is 0", "INT"};
		options[15] =
		{"framerate-numerator", 'f', 0, OptionArg.INT, ref video_fps_numerator, 
			"Frame rate numerator, default is 24", "INT"};
		options[16] =
		{"framerate-denominator", 'F', 0, OptionArg.INT, 
			ref video_fps_denominator, 
			"Frame rate denominator, default is 1. The frame rate numerator " +
			" divided by this determines the frame rate in units per tick", 
			"INT"};
		options[17] =
		{"vp3-compatible", 'c', 0, OptionArg.NONE, ref vp3_compatible,
			"", null};
		/*options[18] =	{ null };*/

		var opt_context = 
			new OptionContext ("INPUT - create theora movie from png files");
		opt_context.set_help_enabled (true);
		opt_context.add_main_entries (options, null);
		opt_context.set_summary ("The INPUT argument uses C printf format " +
		                         "to represent a list of files, i.e. " + 
		                         "file-%%06d.png to look for files " + 
		                         "file000001.png to file9999999.png");
		opt_context.parse (ref args);
		if (video_quality_decimal != -1) {
			video_quality = (int) Math.lrint (video_quality_decimal * 6.3);
			if (video_quality < 0 || video_quality > 63) {
				throw new VPng2TheoraError.
					GENERAL ("Illegal video quality (choose 0 through 10)");
			}
			video_rate = 0;
		}
		if (video_rate_kb != -1) {
			video_rate = (int) Math.lrint (video_rate_kb * 1000);
			video_quality = 0;
		}
		if (singlepass) {
			twopass = 0;
		}
		if (twopass_) {
			twopass = 3;
		}
		if (firstpass_filename != "") {
			twopass = 1;
			twopass_filename = firstpass_filename;
		}
		if (secondpass_filename != "") {
			twopass = 2;
			twopass_filename = secondpass_filename;
		}
		if (chroma_444) {
			chroma_format = Theora.PixelFmt.@444;
		}
		if (chroma_422) {
			chroma_format = Theora.PixelFmt.@422;
		}
		if (chroma_420) {
			chroma_format = Theora.PixelFmt.@420;
		}
		if (keyframe_frequency < 0 || keyframe_frequency > 2147483647) {
			throw new VPng2TheoraError.
				CMD_LINE ("Illegal keyframe frequency\n");
		}
		if (buf_delay == 0 || buf_delay < -1) {
			throw new VPng2TheoraError.
				CMD_LINE ("Illegal buffer delay\n");
		}
		// TODO: Switches are double in original tool
		/*
		 case 's':
		   video_aspect_numerator=rint(atof(optarg));
		   break;
		 case 'S':
		   video_aspect_denominator=rint(atof(optarg));
		   break;
		 case 'f':
		   video_fps_numerator=rint(atof(optarg));
		   break;
		 case 'F':
		   video_fps_denominator=rint(atof(optarg));
		   break;
		  break;
		*/
		input_mask = args[1];
		if (soft_target) {
			if (video_rate <= 0)
				throw new VPng2TheoraError.
					CMD_LINE ("Soft rate target (--soft-target) requested " + 
					          "without a bitrate (-V).");
			if (video_quality == -1)
				video_quality = 0;
		}
		else {
			if (video_rate > 0)
				video_quality = 0;
			if (video_quality == -1)
				video_quality = 48;
		}

		if (keyframe_frequency <= 0) {
			// Use a default keyframe frequency of 64 for 1-pass (streaming) mode, and
			//   256 for two-pass mode.
			keyframe_frequency = twopass != 0 ? 256 : 64;
		}

		if (input_mask == "")
			throw new VPng2TheoraError.
				CMD_LINE ("no input files specified; run with -h for help.");

		File _f = File.new_for_path (input_mask);
		input_directory = (!)((!)_f.get_parent ()).get_path ();
		input_filter = (!)_f.get_basename ();
	}

}

