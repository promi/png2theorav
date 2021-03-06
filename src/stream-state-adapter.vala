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

public class StreamStateAdapter : GLib.Object {

	private Ogg.StreamState oss = Ogg.StreamState ();
	private string name;

	public StreamStateAdapter (string name, 
	                           int serialno) throws VPng2TheoraError {
		this.name = name;
		if (oss.init (serialno) == 0)
			return;
		throw new VPng2TheoraError.OGG_STREAM_STATE (@"$name: error: couldn't create ogg stream state");
	}

	public bool flush (ref Ogg.Page og) {
		return oss.flush (ref og) != 0;
	}

	public void packetin (ref Ogg.Packet op) throws VPng2TheoraError {
		int rc = oss.packetin (ref op);
		switch (rc) {
			case -1: throw new VPng2TheoraError.OGG_STREAM_STATE ("internal ogg library error");
			case 0: break;
			default: throw new VPng2TheoraError.OGG_STREAM_STATE ("unknown ogg library error");
		}
	}

	public bool pageout (ref Ogg.Page og) {
		return oss.pageout (ref og) != 0;
	}
}

