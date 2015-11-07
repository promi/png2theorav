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

class Main {
	private Rand rand;
	private Options opts;

	public Main () {
		this.rand = new Rand ();
		this.opts = new Options ();
	}

	private Dir open_dir () throws VPng2TheoraError {
		try {
			return Dir.open (opts.input_directory, 0);
		}
		catch (Error e) {
			throw new VPng2TheoraError.
				ENUM_PNG_FILES ("could not open input dir " + 
					            opts.input_directory);
		}
	}

	private Gee.List<string> get_png_files () throws VPng2TheoraError {
#if DEBUG
		stdout.printf ("scanning %s with filter '%s'\n", 
		               Options.input_directory, Options.input_filter);
#endif
		var png_files = new Gee.ArrayList<string> ();
		var dir = open_dir ();
		string? name;
		while ((name = dir.read_name ()) != null) {
			int number = -1;
			((!)name).scanf (opts.input_filter, &number);
			if (name == opts.input_filter.printf (number))
				png_files.add ((!)name);
		}
		png_files.sort ();

		// This diversion silences an annoying C compiler warning
		Gee.AbstractCollection col = png_files;
		if (col.size == 0)
			throw new VPng2TheoraError.
				ENUM_PNG_FILES ("no input files found; run with -h for help.");
		return png_files;
	}

	public void run () throws VPng2TheoraError {
		TwoPassFile? twopass_file = null;
		// Options.twopass_filename = "";
		// Options.twopass = 0;
		if (opts.twopass_filename != "") {
			twopass_file = new TwoPassFile (opts.twopass_filename);
		}
		else if (opts.twopass == 3) {
			twopass_file = new TwoPassFile.tmp ();
		}

		var png_files = get_png_files ();
		var ogg_fp = new FileWriter (opts.option_output);
		var ogg_os = new StreamStateAdapter (opts.option_output,
		                                    rand.int_range (int.MIN, int.MAX));

		Ogg.Page og = Ogg.Page ();
		int from_pass = opts.twopass == 3 ? 1 : opts.twopass;
		int to_pass   = opts.twopass == 3 ? 2 : opts.twopass;
		for (int passno = from_pass; passno <= to_pass; passno++)
			main_loop (png_files, passno, opts, twopass_file, ogg_os, out og, 
			           ogg_fp);

		if (ogg_os.flush (ref og)) {
			ogg_fp.write_all (og.header, "header");
			ogg_fp.write_all (og.body, "body");
		}
		ogg_fp.flush ();
		stdout.printf ("\r   \ndone.\n\n");
	}

	public void parse_cmd_options (string[] args) throws Error {
		opts.parse (ref args);
	}

	public static int main (string[] args) {
		Intl.setlocale ();
		Main m = new Main ();
		try {
			m.parse_cmd_options (args);
			m.run ();
			return 0;
		}
		catch (Error e) {
			stderr.printf (@"$(e.message)\n");
			return 1;
		}
	}
}

