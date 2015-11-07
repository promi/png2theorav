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

public class YCbCr : GLib.Object {

	public Theora.ImgPlane[] ycbcr = new Theora.ImgPlane[3];
	 
	public YCbCr () {
		ycbcr[0].data = null;
		ycbcr[1].data = null;
		ycbcr[2].data = null;
	}

	~YCbCr () {
		free (ycbcr[0].data);
		ycbcr[0].data = null;
		free (ycbcr[1].data);
		ycbcr[1].data = null;
		free (ycbcr[2].data);
		ycbcr[2].data = null;
	}

	public bool read (PngReader pr, Theora.PixelFmt chroma_format) {
		// Must hold: yuv_w >= w 
		int yuv_w = ((int) pr.w + 15) & ~15;
		// Must hold: yuv_h >= h 
		int yuv_h = ((int) pr.h + 15) & ~15;
		// Do we need to allocate a buffer
		if (ycbcr[0].data == null) {
			ycbcr[0].width = yuv_w;
			ycbcr[0].height = yuv_h;
			ycbcr[0].stride = yuv_w;
			ycbcr[1].width = (chroma_format == Theora.PixelFmt.@444) ? yuv_w : (yuv_w >> 1);
			ycbcr[1].stride = ycbcr[1].width;
			ycbcr[1].height = (chroma_format == Theora.PixelFmt.@420) ? (yuv_h >> 1) : yuv_h;
			ycbcr[2].width = ycbcr[1].width;
			ycbcr[2].stride = ycbcr[1].stride;
			ycbcr[2].height = ycbcr[1].height;

			ycbcr[0].data = malloc(ycbcr[0].stride * ycbcr[0].height);
			ycbcr[1].data = malloc(ycbcr[1].stride * ycbcr[1].height);
			ycbcr[2].data = malloc(ycbcr[2].stride * ycbcr[2].height);
		}
		else {
			if ((ycbcr[0].width != yuv_w) || (ycbcr[0].height != yuv_h)) {
				stderr.printf("Input size %lux%lu does not match %dx%d\n", 
			                  yuv_w, yuv_h, ycbcr[0].width, ycbcr[0].height);
				return false;
			}
		}
		var rgb_image = new RgbImage (pr.row_pointers);  
		rgb_image.to_yuv (chroma_format, ycbcr, pr.w, pr.h);
		return true;
	}
}

