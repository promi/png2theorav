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

[CCode (cheader_filename = "ogg/ogg.h")]
namespace Ogg {

	[CCode (cname = "ogg_iovec_t", destroy_function = "", has_type_id = false)]
	public struct Iovec {
		[CCode (array_length_cname = "iov_len", array_length_type = "size_t")]
		uint8[] iov_base;
	}

	[CCode (cname = "oggpack_buffer", destroy_function = "", 
	        has_type_id = false)]
	public struct PackBuffer {
		long endbyte;
		int endbit;

		uchar *buffer;
		void *ptr;
		long storage;
		/* Ogg BITSTREAM PRIMITIVES: bitstream ************************/
		[CCode (cname = "oggpack_writeinit")]
		public void writeinit ();
		[CCode (cname = "oggpack_writecheck")]
		public int writecheck ();
		[CCode (cname = "oggpack_writetrunc")]
		public void writetrunc (long bits);
		[CCode (cname = "oggpack_writealign")]
		public void writealign ();
		[CCode (cname = "oggpack_writecopy")]
		public void writecopy (uint8[] source, long bits);
		[CCode (cname = "oggpack_reset")]
		public void reset ();
		[CCode (cname = "oggpack_writeclear")]
		public void writeclear ();
		[CCode (cname = "oggpack_readinit")]
		public void readinit (uint8[] buf, int bytes);
		[CCode (cname = "oggpack_write")]
		public void write (ulong value, int bits);
		[CCode (cname = "oggpack_look")]
		public long look (int bits);
		[CCode (cname = "oggpack_look1")]
		public long look1 ();
		[CCode (cname = "oggpack_adv")]
		public void adv (int bits);
		[CCode (cname = "oggpack_adv1")]
		public void adv1 ();
		[CCode (cname = "oggpack_read")]
		public long read (int bits);
		[CCode (cname = "oggpack_read1")]
		public long read1 ();
		[CCode (cname = "oggpack_bytes")]
		public long bytes ();
		[CCode (cname = "oggpack_bits")]
		public long bits ();
		[CCode (cname = "oggpack_get_buffer")]
		public uint8[] get_buffer ();

		[CCode (cname = "oggpackB_writeinit")]
		public void B_writeinit ();
		[CCode (cname = "oggpackB_writecheck")]
		public int B_writecheck ();
		[CCode (cname = "oggpackB_writetrunc")]
		public void B_writetrunc (long bits);
		[CCode (cname = "oggpackB_writealign")]
		public void B_writealign ();
		[CCode (cname = "oggpackB_writecopy")]
		public void B_writecopy (uint8[] source, long bits);
		[CCode (cname = "oggpackB_reset")]
		public void B_reset ();
		[CCode (cname = "oggpackB_writeclear")]
		public void B_writeclear ();
		[CCode (cname = "oggpackB_readinit")]
		public void B_readinit (uint8[] buf, int bytes);
		[CCode (cname = "oggpackB_write")]
		public void B_write (ulong value, int bits);
		[CCode (cname = "oggpackB_look")]
		public long B_look (int bits);
		[CCode (cname = "oggpackB_look1")]
		public long B_look1 ();
		[CCode (cname = "oggpackB_adv")]
		public void B_adv (int bits);
		[CCode (cname = "oggpackB_adv1")]
		public void B_adv1 ();
		[CCode (cname = "oggpackB_read")]
		public long B_read (int bits);
		[CCode (cname = "oggpackB_read1")]
		public long B_read1 ();
		[CCode (cname = "oggpackB_bytes")]
		public long B_bytes ();
		[CCode (cname = "oggpackB_bits")]
		public long B_bits ();
		[CCode (cname = "oggpackB_get_buffer")]
		public uint8[] B_get_buffer ();
	}

	/* ogg_page is used to encapsulate the data in one Ogg bitstream page *****/
	[CCode (cname = "ogg_page", destroy_function = "", has_type_id = false)]
	public struct Page {
		[CCode (array_length_cname = "header_len", array_length_type = "long")]
		public uint8[] header;
		[CCode (array_length_cname = "body_len", array_length_type = "long")]
		public uint8[] body;
		/* Ogg BITSTREAM PRIMITIVES: general ***************************/
		[CCode (cname = "ogg_page_checksum_set")]
		public void checksum_set ();
		[CCode (cname = "ogg_page_version")]
		public int version ();
		[CCode (cname = "ogg_page_continued")]
		public int continued ();
		[CCode (cname = "ogg_page_bos")]
		public int bos ();
		[CCode (cname = "ogg_page_eos")]
		public int eos ();
		[CCode (cname = "ogg_page_granulepos")]
		public int64 granulepos ();
		[CCode (cname = "ogg_page_serialno")]
		public int serialno ();
		[CCode (cname = "ogg_page_pageno(")]
		public long pageno ();
		[CCode (cname = "ogg_page_packets")]
		public int packets ();
	}

	/* ogg_stream_state contains the current encode/decode state of a logical
	   Ogg bitstream **********************************************************/
	[CCode (cname = "ogg_stream_state", destroy_function = "ogg_stream_clear", 
	        has_type_id = false)]
	public struct StreamState {
		uchar *body_data;    /* bytes from packet bodies */
		long body_storage;    /* storage elements allocated */
		long body_fill;       /* elements stored; fill mark */
		long body_returned;   /* elements of fill returned */


		int *lacing_vals;    /* The values that will go to the segment table */
		int64 *granule_vals; /* granulepos values for headers. Not compact
				                    this way, but it is simple coupled to the
				                    lacing fifo */
		long lacing_storage;
		long lacing_fill;
		long lacing_packet;
		long lacing_returned;

		uint8 header[282]; /* working space for header encode */
		int header_fill;

		int e_o_s;          /* set when we have buffered the last packet in the
				                 logical bitstream */
		int b_o_s;          /* set after we've written the initial page
				                 of a logical bitstream */
		long serialno;
		long pageno;
		int64 packetno;  /* sequence number for decode; the framing
				                 knows where there's a hole in the data,
				                 but we need coupling so that the codec
				                 (which is in a separate abstraction
				                 layer) also knows about the gap */
		int64 granulepos;
		/* Ogg BITSTREAM PRIMITIVES: encoding **************************/
		[CCode (cname = "ogg_stream_packetin")]
		public int packetin (ref Packet op);
		[CCode (cname = "ogg_stream_iovecin")]
		public int iovecin (ref Iovec iov, int count, long e_o_s, int64 granulepos);
		[CCode (cname = "ogg_stream_pageout")]
		public int pageout (ref Page og);
		[CCode (cname = "ogg_stream_pageout_fill")]
		public int pageout_fill (ref Page og, int nfill);
		[CCode (cname = "ogg_stream_flush")]
		public int flush (ref Page og);
		[CCode (cname = "ogg_stream_flush_fill")]
		public int flush_fill (ref Page og, int nfill);
		/* Ogg BITSTREAM PRIMITIVES: decoding **************************/
		[CCode (cname = "ogg_stream_pagein")]
		public int pagein (ref Page og);
		[CCode (cname = "ogg_stream_packetout")]
		public int packetout (ref Packet op);
		[CCode (cname = "ogg_stream_packetpeek")]
		public int packetpeek (ref Packet op);
		/* Ogg BITSTREAM PRIMITIVES: general ***************************/
		[CCode (cname = "ogg_stream_init")]
		public int init (int serialno);
		[CCode (cname = "ogg_stream_reset")]
		public int reset ();
		[CCode (cname = "ogg_stream_reset_serialno")]
		public int reset_serialno (int serialno);
		[CCode (cname = "ogg_stream_check")]
		public int check ();
		[CCode (cname = "ogg_stream_eos")]
		public int eos ();
	}

	/* ogg_packet is used to encapsulate the data and metadata belonging
	   to a single raw Ogg/Vorbis packet *************************************/
	// destroy_function = "ogg_packet_clear"
	[CCode (cname = "ogg_packet", destroy_function = "", has_type_id = false)]
	public struct Packet {
		[CCode (array_length_cname = "bytes", array_length_type = "long")]
		uint8[] packet;
		long b_o_s;
		long e_o_s;
		int64 granulepos;
		/* sequence number for decode; the framing knows where there's a hole
		   in the data, but we need coupling so that the codec which is in a 
		   separate abstraction layer) also knows about the gap */
		int64 packetno;
	}

	[CCode (cname = "ogg_sync_state", destroy_function = "ogg_sync_clear", 
	        has_type_id = false)]
	public struct SyncState {
		uchar *data;
		int storage;
		int fill;
		int returned;

		int unsynced;
		int headerbytes;
		int bodybytes;

		/* Ogg BITSTREAM PRIMITIVES: decoding **************************/
		[CCode (cname = "ogg_sync_init")]
		public SyncState ();
		[CCode (cname = "ogg_sync_reset")]
		public int reset ();
		[CCode (cname = "ogg_sync_check")]
		public int check ();

		[CCode (cname = "ogg_sync_buffer")]
		public uint8[] buffer (long size);
		[CCode (cname = "ogg_sync_wrote")]
		public int wrote (long bytes);
		[CCode (cname = "ogg_sync_pageseek")]
		public long pageseek (ref Page og);
		[CCode (cname = "ogg_sync_pageout")]
		public int pageout (ref Page og);
	}

}
