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

public class RgbImage : GLib.Object {

	unowned uint8*[] png;
	
	public RgbImage ((unowned uint8*)[] png) {
		this.png = png;
	}

	public void to_yuv (Theora.PixelFmt chroma_format, Theora.ImgPlane[] ycbcr,
	                    uint w, uint h) {
		if (chroma_format == Theora.PixelFmt.@420) {
			to_yuv_420 (ycbcr, w, h);
		}
		else if (chroma_format == Theora.PixelFmt.@444) {
			to_yuv_444 (ycbcr, w, h);
		} 
		else if (chroma_format == Theora.PixelFmt.@422) {
			to_yuv_422 (ycbcr, w, h);
		}
		else {
			assert_not_reached ();
		}
	}

	private void to_yuv_420 (Theora.ImgPlane[] ycbcr, uint w, uint h) {
		uint x;
		uint y;

		uint x1;
		uint y1;

		ulong yuv_w;

		uchar *yuv_y;
		uchar *yuv_u;
		uchar *yuv_v;

		yuv_w = ycbcr[0].width;

		yuv_y = ycbcr[0].data;
		yuv_u = ycbcr[1].data;
		yuv_v = ycbcr[2].data;

		// This ignores gamma and RGB primary/whitepoint differences.
		// It also isn't terribly fast (though a decent compiler will
		// strength-reduce the division to a multiplication).

		for (y = 0; y < h; y += 2) {
			y1 = y + ((y + 1 < h) ? 1 : 0);
			for (x = 0; x < w; x += 2) {
				x1 = x + ((x + 1 < w) ? 1 : 0);
				uint8 r0 = png[y][3 * x + 0];
				uint8 g0 = png[y][3 * x + 1];
				uint8 b0 = png[y][3 * x + 2];
				uint8 r1 = png[y][3 * x1 + 0];
				uint8 g1 = png[y][3 * x1 + 1];
				uint8 b1 = png[y][3 * x1 + 2];
				uint8 r2 = png[y1][3 * x + 0];
				uint8 g2 = png[y1][3 * x + 1];
				uint8 b2 = png[y1][3 * x + 2];
				uint8 r3 = png[y1][3 * x1 + 0];
				uint8 g3 = png[y1][3 * x1 + 1];
				uint8 b3 = png[y1][3 * x1 + 2];

				yuv_y [x  + y * yuv_w]  = clamp ((65481 * r0 + 128553 * g0 + 24966 * b0 + 4207500) / 255000);
				yuv_y [x1 + y * yuv_w]  = clamp ((65481 * r1 + 128553 * g1 + 24966 * b1 + 4207500) / 255000);
				yuv_y [x  + y1 * yuv_w] = clamp ((65481 * r2 + 128553 * g2 + 24966 * b2 + 4207500) / 255000);
				yuv_y [x1 + y1 * yuv_w] = clamp ((65481 * r3 + 128553 * g3 + 24966 * b3 + 4207500) / 255000);

				yuv_u [(x >> 1) + (y >> 1) * ycbcr[1].stride] =
				  clamp( ((-33488 * r0 - 65744 * g0 + 99232 * b0 + 29032005) / 4 +
						  (-33488 * r1 - 65744 * g1 + 99232 * b1 + 29032005) / 4 +
						  (-33488 * r2 - 65744 * g2 + 99232 * b2 + 29032005) / 4 +
						  (-33488 * r3 - 65744 * g3 + 99232 * b3 + 29032005) / 4) / 225930);
				yuv_v[(x >> 1) + (y >> 1) * ycbcr[2].stride] =
				  clamp( ((157024 * r0 - 131488 * g0 - 25536 * b0+45940035) / 4 +
						  (157024 * r1 - 131488 * g1 - 25536 * b1+45940035) / 4 +
						  (157024 * r2 - 131488 * g2 - 25536 * b2+45940035) / 4 +
						  (157024 * r3 - 131488 * g3 - 25536 * b3+45940035) / 4) / 357510);
			}
		}
	}

	private void to_yuv_444 (Theora.ImgPlane[] ycbcr, uint w, uint h) {
		uint x;
		uint y;

		ulong yuv_w;

		uchar *yuv_y;
		uchar *yuv_u;
		uchar *yuv_v;

		yuv_w = ycbcr[0].width;

		yuv_y = ycbcr[0].data;
		yuv_u = ycbcr[1].data;
		yuv_v = ycbcr[2].data;

		// This ignores gamma and RGB primary/whitepoint differences.
		// It also isn't terribly fast (though a decent compiler will
		// strength-reduce the division to a multiplication).


		for(y = 0; y < h; y++) {
			for(x = 0; x < w; x++) {
				uint8  r = png[y][3 * x + 0];
				uint8  g = png[y][3 * x + 1];
				uint8  b = png[y][3 * x + 2];

				yuv_y[x + y * yuv_w] = clamp ((65481 * r + 128553 * g + 24966 * b + 4207500) / 255000);
				yuv_u[x + y * yuv_w] = clamp ((-33488 * r - 65744 * g + 99232 * b + 29032005) / 225930);
				yuv_v[x + y * yuv_w] = clamp ((157024 * r - 131488 * g - 25536 * b + 45940035) / 357510);
			}
		}
	}

	private void to_yuv_422 (Theora.ImgPlane[] ycbcr, uint w, uint h) {
		uint x;
		uint y;

		uint x1;

		ulong yuv_w;

		uchar *yuv_y;
		uchar *yuv_u;
		uchar *yuv_v;

		yuv_w = ycbcr[0].width;

		yuv_y = ycbcr[0].data;
		yuv_u = ycbcr[1].data;
		yuv_v = ycbcr[2].data;

		// This ignores gamma and RGB primary/whitepoint differences.
		// It also isn't terribly fast (though a decent compiler will
		// strength-reduce the division to a multiplication).

		for(y = 0; y < h; y += 1) {
			for(x = 0; x < w; x += 2) {
				x1=x+ ((x+1<w) ? 1 : 0);
				uint8  r0 = png[y][3 * x + 0];
				uint8  g0 = png[y][3 * x + 1];
				uint8  b0 = png[y][3 * x + 2];
				uint8  r1 = png[y][3 * x1 + 0];
				uint8  g1 = png[y][3 * x1 + 1];
				uint8  b1 = png[y][3 * x1 + 2];

				yuv_y[x  + y * yuv_w] = clamp ((65481*r0+128553*g0+24966*b0+4207500)/255000);
				yuv_y[x1 + y * yuv_w] = clamp ((65481*r1+128553*g1+24966*b1+4207500)/255000);

				yuv_u[(x >> 1) + y * ycbcr[1].stride] =
				  clamp ( ((-33488*r0-65744*g0+99232*b0+29032005)/2 +
						   (-33488*r1-65744*g1+99232*b1+29032005)/2)/225930);
				yuv_v[(x >> 1) + y * ycbcr[2].stride] =
				  clamp ( ((157024*r0-131488*g0-25536*b0+45940035)/2 +
						   (157024*r1-131488*g1-25536*b1+45940035)/2)/357510);
			}
		}
	}

	private uchar clamp (int d) {
		if(d < 0)
			return 0;

		if(d > 255)
			return 255;

		return (uchar) d;
	}

}

