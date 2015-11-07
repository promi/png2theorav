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

[CCode (cheader_filename = "theora/theoradec.h,theora/theoraenc.h")]
namespace Theora {

	[CCode (cname="int", cprefix="TH_")]
	public enum ReturnCode {
		OK = 0,
		/**\name Return codes*/
		/**An invalid pointer was provided.*/
		EFAULT,
		/**An invalid argument was provided.*/
		EINVAL,
		/**The contents of the header were incomplete, invalid, or unexpected.*/
		EBADHEADER,
		/**The header does not belong to a Theora stream.*/
		ENOTFORMAT,
		/**The bitstream version is too high.*/
		EVERSION,
		/**The specified function is not implemented.*/
		EIMPL,
		/**There were errors in the video data packet.*/
		EBADPACKET,
		/**The decoded packet represented a dropped frame.
		   The player can continue to display the current frame, as the contents of the
			decoded frame buffer have not changed.*/
		DUPFRAME
	}

	/**The currently defined color space tags.
	 * See <a href="http://www.theora.org/doc/Theora.pdf">the Theora
	 *  specification</a>, Chapter 4, for exact details on the meaning
	 *  of each of these color spaces.*/
	[CCode (cname="th_colorspace", cprefix="TH_CS_")]
	public enum Colorspace {
		/**The color space was not specified at the encoder.
		   It may be conveyed by an external means.*/
		UNSPECIFIED,
		/**A color space designed for NTSC content.*/
		ITU_REC_470M,
		/**A color space designed for PAL/SECAM content.*/
		ITU_REC_470BG,
		/**The total number of currently defined color spaces.*/
		NSPACES
	}

	/**The currently defined pixel format tags.
	 * See <a href="http://www.theora.org/doc/Theora.pdf">the Theora
	 *  specification</a>, Section 4.4, for details on the precise sample
	 *  locations.*/
	[CCode (cname="th_pixel_fmt", cprefix="TH_PF_")]
	public enum PixelFmt {
		/**Chroma decimation by 2 in both the X and Y directions (4:2:0).
		   The Cb and Cr chroma planes are half the width and half the
		   height of the luma plane.*/
		@420,
		/**Currently reserved.*/
		RSVD,
		/**Chroma decimation by 2 in the X direction (4:2:2).
		   The Cb and Cr chroma planes are half the width of the luma plane, but full
		   height.*/
		@422,
		/**No chroma decimation (4:4:4).
		   The Cb and Cr chroma planes are full width and full height.*/
		@444,
		/**The total number of currently defined pixel formats.*/
		NFORMATS
	}

	/**A buffer for a single color plane in an uncompressed image.
	 * This contains the image data in a left-to-right, top-down format.
	 * Each row of pixels is stored contiguously in memory, but successive
	 *  rows need not be.
	 * Use \a stride to compute the offset of the next row.
	 * The encoder accepts both positive \a stride values (top-down in memory)
	 *  and negative (bottom-up in memory).
	 * The decoder currently always generates images with positive strides.*/
	[CCode (cname = "th_img_plane")]
	public struct ImgPlane {
		/**The width of this plane.*/
		int width;
		/**The height of this plane.*/
		int height;
		/**The offset in bytes between successive rows.*/
		int stride;
		/**A pointer to the beginning of the first row.*/
		uchar *data;
	}

	/**A complete image buffer for an uncompressed frame.
	 * The chroma planes may be decimated by a factor of two in either
	 *  direction, as indicated by th_info#pixel_fmt.
	 * The width and height of the Y' plane must be multiples of 16.
	 * They may need to be cropped for display, using the rectangle
	 *  specified by th_info#pic_x, th_info#pic_y, th_info#pic_width,
	 *  and th_info#pic_height.
	 * All samples are 8 bits.
	 * \note The term YUV often used to describe a colorspace is ambiguous.
	 * The exact parameters of the RGB to YUV conversion process aside, in
	 *  many contexts the U and V channels actually have opposite meanings.
	 * To avoid this confusion, we are explicit: the name of the color
	 *  channels are Y'CbCr, and they appear in that order, always.
	 * The prime symbol denotes that the Y channel is non-linear.
	 * Cb and Cr stand for "Chroma blue" and "Chroma red", respectively.*/
	// typedef th_img_plane th_ycbcr_buffer[3];

	/**Theora bitstream information.
	 * This contains the basic playback parameters for a stream, and corresponds to 
	 *  the initial 'info' header packet.
	 * To initialize an encoder, the application fills in this structure and
	 *  passes it to th_encode_alloc().
	 * A default encoding mode is chosen based on the values of the #quality and
	 *  #target_bitrate fields.
	 * On decode, it is filled in by th_decode_headerin(), and then passed to
	 *  th_decode_alloc().
	 *
	 * Encoded Theora frames must be a multiple of 16 in size;
	 *  this is what the #frame_width and #frame_height members represent.
	 * To handle arbitrary picture sizes, a crop rectangle is specified in the
	 *  #pic_x, #pic_y, #pic_width and #pic_height members.
	 *
	 * All frame buffers contain pointers to the full, padded frame.
	 * However, the current encoder <em>will not</em> reference pixels outside of
	 *  the cropped picture region, and the application does not need to fill them
	 *  in.
	 * The decoder <em>will</em> allocate storage for a full frame, but the
	 *  application <em>should not</em> rely on the padding containing sensible
	 *  data.
	 *
	 * It is also generally recommended that the offsets and sizes should still be
	 *  multiples of 2 to avoid chroma sampling shifts when chroma is sub-sampled.
	 * See <a href="http://www.theora.org/doc/Theora.pdf">the Theora
	 *  specification</a>, Section 4.4, for more details.
	 *
	 * Frame rate, in frames per second, is stored as a rational fraction, as is
	 *  the pixel aspect ratio.
	 * Note that this refers to the aspect ratio of the individual pixels, not of
	 *  the overall frame itself.
	 * The frame aspect ratio can be computed from pixel aspect ratio using the
	 *  image dimensions.*/

	[CCode (cname="th_info", destroy_function = "th_info_clear", has_type_id = false)]
	public struct Info {
		/**\name Theora version
		 * Bitstream version information.*/
		public uint8 version_major;
		public uint8 version_minor;
		public uint8 version_subminor;
		/**The encoded frame width.
		 * This must be a multiple of 16, and less than 1048576.*/
		public uint32 frame_width;
		/**The encoded frame height.
		 * This must be a multiple of 16, and less than 1048576.*/
		public uint32 frame_height;
		/**The displayed picture width.
		 * This must be no larger than width.*/
		public uint32 pic_width;
		/**The displayed picture height.
		 * This must be no larger than height.*/
		public uint32 pic_height;
		/**The X offset of the displayed picture.
		 * This must be no larger than #frame_width-#pic_width or 255, whichever is
		 *  smaller.*/
		public uint32 pic_x;
		/**The Y offset of the displayed picture.
		 * This must be no larger than #frame_height-#pic_height, and
		 *  #frame_height-#pic_height-#pic_y must be no larger than 255.
		 * This slightly funny restriction is due to the fact that the offset is
		 *  specified from the top of the image for consistency with the standard
		 *  graphics left-handed coordinate system used throughout this API, while
		 *  it is stored in the encoded stream as an offset from the bottom.*/
		public uint32 pic_y;
		/**\name Frame rate
		 * The frame rate, as a fraction.
		 * If either is 0, the frame rate is undefined.*/
		public uint32 fps_numerator;
		public uint32 fps_denominator;
		/**\name Aspect ratio
		 * The aspect ratio of the pixels.
		 * If either value is zero, the aspect ratio is undefined.
		 * If not specified by any external means, 1:1 should be assumed.
		 * The aspect ratio of the full picture can be computed as
		 * \code
		 *  aspect_numerator*pic_width/(aspect_denominator*pic_height).
		 * \endcode */
		public uint32 aspect_numerator;
		public uint32 aspect_denominator;
		/**The color space.*/
		public Colorspace colorspace;
		/**The pixel format.*/
		public PixelFmt pixel_fmt;
		/**The target bit-rate in bits per second.
		 If initializing an encoder with this struct, set this field to a non-zero
		  value to activate CBR encoding by default.*/
		int target_bitrate;
		/**The target quality level.
		 Valid values range from 0 to 63, inclusive, with higher values giving
		  higher quality.
		 If initializing an encoder with this struct, and #target_bitrate is set
		  to zero, VBR encoding at this quality will be activated by default.*/
		/*Currently this is set so that a qi of 0 corresponds to distortions of 24
		 times the JND, and each increase by 16 halves that value.
		This gives us fine discrimination at low qualities, yet effective rate
		 control at high qualities.
		The qi value 63 is special, however.
		For this, the highest quality, we use one half of a JND for our threshold.
		Due to the lower bounds placed on allowable quantizers in Theora, we will
		 not actually be able to achieve quality this good, but this should
		 provide as close to visually lossless quality as Theora is capable of.
		We could lift the quantizer restrictions without breaking VP3.1
		 compatibility, but this would result in quantized coefficients that are
		 too large for the current bitstream to be able to store.
		We'd have to redesign the token syntax to store these large coefficients,
		 which would make transcoding complex.*/
		int quality;
		/**The amount to shift to extract the last keyframe number from the granule
		 *  position.
		 * This can be at most 31.
		 * th_info_init() will set this to a default value (currently <tt>6</tt>,
		 *  which is good for streaming applications), but you can set it to 0 to
		 *  make every frame a keyframe.
		 * The maximum distance between key frames is
		 *  <tt>1<<#keyframe_granule_shift</tt>.
		 * The keyframe frequency can be more finely controlled with
		 *  #TH_ENCCTL_SET_KEYFRAME_FREQUENCY_FORCE, which can also be adjusted
		 *  during encoding (for example, to force the next frame to be a keyframe),
		 *  but it cannot be set larger than the amount permitted by this field after
		 *  the headers have been output.*/
		int keyframe_granule_shift;
		[CCode (cname = "th_info_init")]
		public Info ();
		/**Decodes the header packets of a Theora stream.
		 * This should be called on the initial packets of the stream, in succession,
		 *  until it returns <tt>0</tt>, indicating that all headers have been
		 *  processed, or an error is encountered.
		 * At least three header packets are required, and additional optional header
		 *  packets may follow.
		 * This can be used on the first packet of any logical stream to determine if
		 *  that stream is a Theora stream.
		 * \param _info  A #th_info structure to fill in.
		 *               This must have been previously initialized with
		 *                th_info_init().
		 *               The application may immediately begin using the contents of
		 *                this structure after the first header is decoded, though it
		 *                must continue to be passed in on all subsequent calls.
		 * \param _tc    A #th_comment structure to fill in.
		 *               The application may immediately begin using the contents of
		 *                this structure after the second header is decoded, though it
		 *                must continue to be passed in on all subsequent calls.
		 * \param _setup Returns a pointer to additional, private setup information
		 *                needed by the decoder.
		 *               The contents of this pointer must be initialized to
		 *                <tt>NULL</tt> on the first call, and the returned value must
		 *                continue to be passed in on all subsequent calls.
		 * \param _op    An <tt>ogg_packet</tt> structure which contains one of the
		 *                initial packets of an Ogg logical stream.
		 * \return A positive value indicates that a Theora header was successfully
		 *          processed.
		 * \retval 0             The first video data packet was encountered after all
		 *                        required header packets were parsed.
		 *                       The packet just passed in on this call should be saved
		 *                        and fed to th_decode_packetin() to begin decoding
		 *                        video data.
		 * \retval TH_EFAULT     One of \a _info, \a _tc, or \a _setup was
		 *                        <tt>NULL</tt>.
		 * \retval TH_EBADHEADER \a _op was <tt>NULL</tt>, the packet was not the next
		 *                        header packet in the expected sequence, or the format
		 *                        of the header data was invalid.
		 * \retval TH_EVERSION   The packet data was a Theora info header, but for a
		 *                        bitstream version not decodable with this version of
		 *                        <tt>libtheoradec</tt>.
		 * \retval TH_ENOTFORMAT The packet was not a Theora header.
		 */
		[CCode (cname = "th_decode_headerin")]
		public int headerin (ref Comments tc, SetupInfo *setup, ref Ogg.Packet op);
	}

	/**The comment information.
	 *
	 * This structure holds the in-stream metadata corresponding to
	 *  the 'comment' header packet.
	 * The comment header is meant to be used much like someone jotting a quick
	 *  note on the label of a video.
	 * It should be a short, to the point text note that can be more than a couple
	 *  words, but not more than a short paragraph.
	 *
	 * The metadata is stored as a series of (tag, value) pairs, in
	 *  length-encoded string vectors.
	 * The first occurrence of the '=' character delimits the tag and value.
	 * A particular tag may occur more than once, and order is significant.
	 * The character set encoding for the strings is always UTF-8, but the tag
	 *  names are limited to ASCII, and treated as case-insensitive.
	 * See <a href="http://www.theora.org/doc/Theora.pdf">the Theora
	 *  specification</a>, Section 6.3.3 for details.
	 *
	 * In filling in this structure, th_decode_headerin() will null-terminate
	 *  the user_comment strings for safety.
	 * However, the bitstream format itself treats them as 8-bit clean vectors,
	 *  possibly containing null characters, and so the length array should be
	 *  treated as their authoritative length.
	 */
	[CCode (cname = "th_comment", destroy_function = "th_comment_clear", 
	        has_type_id = false)]
	public struct Comments {
		/**The array of comment string vectors.*/
		uint8[][] user_comments;
		/**An array of the corresponding length of each vector, in bytes.*/
		int[] comment_lengths;
		/**The total number of comment strings.*/
		int comments;
		/**The null-terminated vendor string.
		 This identifies the software used to encode the stream.*/
		uint8[] vendor;
		/**Initialize a #th_comment structure.
		 * This should be called on a freshly allocated #th_comment structure
		 *  before attempting to use it.
		 * \param _tc The #th_comment struct to initialize.*/
		[CCode (cname = "th_comment_init")]
		public Comments ();
		/**Add a comment to an initialized #th_comment structure.
		 * \note Neither th_comment_add() nor th_comment_add_tag() support
		 *  comments containing null values, although the bitstream format does
		 *  support them.
		 * To add such comments you will need to manipulate the #th_comment
		 *  structure directly.
		 * \param _tc      The #th_comment struct to add the comment to.
		 * \param _comment Must be a null-terminated UTF-8 string containing the
		 *                  comment in "TAG=the value" form.*/
		[CCode (cname = "th_comment_add")]
		public void add ([CCode (array_null_terminated = true)] uint8[] comment);
		/**Add a comment to an initialized #th_comment structure.
		 * \note Neither th_comment_add() nor th_comment_add_tag() support
		 *  comments containing null values, although the bitstream format does
		 *  support them.
		 * To add such comments you will need to manipulate the #th_comment
		 *  structure directly.
		 * \param _tc  The #th_comment struct to add the comment to.
		 * \param _tag A null-terminated string containing the tag  associated with
		 *              the comment.
		 * \param _val The corresponding value as a null-terminated string.*/
		[CCode (cname = "th_comment_add_tag")]
		public void add_tag([CCode (array_null_terminated = true)] uint8[] tag, 
		                    [CCode (array_null_terminated = true)] uint8[] val);
		/**Look up a comment value by its tag.
		 * \param _tc    An initialized #th_comment structure.
		 * \param _tag   The tag to look up.
		 * \param _count The instance of the tag.
		 *               The same tag can appear multiple times, each with a distinct
		 *                value, so an index is required to retrieve them all.
		 *               The order in which these values appear is significant and
		 *                should be preserved.
		 *               Use th_comment_query_count() to get the legal range for
		 *                the \a _count parameter.
		 * \return A pointer to the queried tag's value.
		 *         This points directly to data in the #th_comment structure.
		 *         It should not be modified or freed by the application, and
		 *          modifications to the structure may invalidate the pointer.
		 * \retval NULL If no matching tag is found.*/
		[CCode (cname = "th_comment_query")]
		public uint8[] query ([CCode (array_null_terminated = true)] uint8[] tag, 
		                      int count);
		/**Look up the number of instances of a tag.
		 * Call this first when querying for a specific tag and then iterate over the
		 *  number of instances with separate calls to th_comment_query() to
		 *  retrieve all the values for that tag in order.
		 * \param _tc    An initialized #th_comment structure.
		 * \param _tag   The tag to look up.
		 * \return The number on instances of this particular tag.*/
		[CCode (cname = "th_comment_query_count")]
		public int query_count ([CCode (array_null_terminated = true)] uint8[] tag);
	}

	[CCode (cname = "int", cprefix = "TH_RATECTL_")]
	public enum RateCtl {
		DROP_FRAMES,
		CAP_OVERFLOW,
		CAP_UNDERFLOW
	}

	[CCode (cname = "int", cprefix = "TH_ENCCTL_")]
	public enum EncodeCtl {
		/**\name th_encode_ctl() codes
		 * \anchor encctlcodes
		 * These are the available request codes for th_encode_ctl().
		 * By convention, these are even, to distinguish them from the
		 *  \ref decctlcodes "decoder control codes".
		 * Keep any experimental or vendor-specific values above \c 0x8000.*/

		/**Sets the Huffman tables to use.
		 * The tables are copied, not stored by reference, so they can be freed after
		 *  this call.
		 * <tt>NULL</tt> may be specified to revert to the default tables.
		 *
		 * \param[in] _buf <tt>#th_huff_code[#TH_NHUFFMAN_TABLES][#TH_NDCT_TOKENS]</tt>
		 * \retval TH_EFAULT \a _enc_ctx is <tt>NULL</tt>.
		 * \retval TH_EINVAL Encoding has already begun or one or more of the given
		 *                     tables is not full or prefix-free, \a _buf is
		 *                     <tt>NULL</tt> and \a _buf_sz is not zero, or \a _buf is
		 *                     non-<tt>NULL</tt> and \a _buf_sz is not
		 *                     <tt>sizeof(#th_huff_code)*#TH_NHUFFMAN_TABLES*#TH_NDCT_TOKENS</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		SET_HUFFMAN_CODES,
		/**Sets the quantization parameters to use.
		 * The parameters are copied, not stored by reference, so they can be freed
		 *  after this call.
		 * <tt>NULL</tt> may be specified to revert to the default parameters.
		 *
		 * \param[in] _buf #th_quant_info
		 * \retval TH_EFAULT \a _enc_ctx is <tt>NULL</tt>.
		 * \retval TH_EINVAL Encoding has already begun, \a _buf is 
		 *                    <tt>NULL</tt> and \a _buf_sz is not zero,
		 *                    or \a _buf is non-<tt>NULL</tt> and
		 *                    \a _buf_sz is not <tt>sizeof(#th_quant_info)</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		SET_QUANT_PARAMS,
		/**Sets the maximum distance between key frames.
		 * This can be changed during an encode, but will be bounded by
		 *  <tt>1<<th_info#keyframe_granule_shift</tt>.
		 * If it is set before encoding begins, th_info#keyframe_granule_shift will
		 *  be enlarged appropriately.
		 *
		 * \param[in]  _buf <tt>ogg_uint32_t</tt>: The maximum distance between key
		 *                   frames.
		 * \param[out] _buf <tt>ogg_uint32_t</tt>: The actual maximum distance set.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(ogg_uint32_t)</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		SET_KEYFRAME_FREQUENCY_FORCE,
		/**Disables any encoder features that would prevent lossless transcoding back
		 *  to VP3.
		 * This primarily means disabling block-adaptive quantization and always coding
		 *  all four luma blocks in a macro block when 4MV is used.
		 * It also includes using the VP3 quantization tables and Huffman codes; if you
		 *  set them explicitly after calling this function, the resulting stream will
		 *  not be VP3-compatible.
		 * If you enable VP3-compatibility when encoding 4:2:2 or 4:4:4 source
		 *  material, or when using a picture region smaller than the full frame (e.g.
		 *  a non-multiple-of-16 width or height), then non-VP3 bitstream features will
		 *  still be disabled, but the stream will still not be VP3-compatible, as VP3
		 *  was not capable of encoding such formats.
		 * If you call this after encoding has already begun, then the quantization
		 *  tables and codebooks cannot be changed, but the frame-level features will
		 *  be enabled or disabled as requested.
		 *
		 * \param[in]  _buf <tt>int</tt>: a non-zero value to enable VP3 compatibility,
		 *                   or 0 to disable it (the default).
		 * \param[out] _buf <tt>int</tt>: 1 if all bitstream features required for
		 *                   VP3-compatibility could be set, and 0 otherwise.
		 *                  The latter will be returned if the pixel format is not
		 *                   4:2:0, the picture region is smaller than the full frame,
		 *                   or if encoding has begun, preventing the quantization
		 *                   tables and codebooks from being set.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		SET_VP3_COMPATIBLE,
		/**Gets the maximum speed level.
		 * Higher speed levels favor quicker encoding over better quality per bit.
		 * Depending on the encoding mode, and the internal algorithms used, quality
		 *  may actually improve, but in this case bitrate will also likely increase.
		 * In any case, overall rate/distortion performance will probably decrease.
		 * The maximum value, and the meaning of each value, may change depending on
		 *  the current encoding mode (VBR vs. constant quality, etc.).
		 *
		 * \param[out] _buf <tt>int</tt>: The maximum encoding speed level.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation in the current
		 *                    encoding mode.*/
		GET_SPLEVEL_MAX,
		/**Sets the speed level.
		 * The current speed level may be retrieved using #TH_ENCCTL_GET_SPLEVEL.
		 *
		 * \param[in] _buf <tt>int</tt>: The new encoding speed level.
		 *                 0 is slowest, larger values use less CPU.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt>, or the
		 *                    encoding speed level is out of bounds.
		 *                   The maximum encoding speed level may be
		 *                    implementation- and encoding mode-specific, and can be
		 *                    obtained via #TH_ENCCTL_GET_SPLEVEL_MAX.
		 * \retval TH_EIMPL   Not supported by this implementation in the current
		 *                    encoding mode.*/
		SET_SPLEVEL,
		/**Gets the current speed level.
		 * The default speed level may vary according to encoder implementation, but if
		 *  this control code is not supported (it returns #TH_EIMPL), the default may
		 *  be assumed to be the slowest available speed (0).
		 * The maximum encoding speed level may be implementation- and encoding
		 *  mode-specific, and can be obtained via #TH_ENCCTL_GET_SPLEVEL_MAX.
		 *
		 * \param[out] _buf <tt>int</tt>: The current encoding speed level.
		 *                  0 is slowest, larger values use less CPU.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation in the current
		 *                    encoding mode.*/
		GET_SPLEVEL,
		/**Sets the number of duplicates of the next frame to produce.
		 * Although libtheora can encode duplicate frames very cheaply, it costs some
		 *  amount of CPU to detect them, and a run of duplicates cannot span a
		 *  keyframe boundary.
		 * This control code tells the encoder to produce the specified number of extra
		 *  duplicates of the next frame.
		 * This allows the encoder to make smarter keyframe placement decisions and
		 *  rate control decisions, and reduces CPU usage as well, when compared to
		 *  just submitting the same frame for encoding multiple times.
		 * This setting only applies to the next frame submitted for encoding.
		 * You MUST call th_encode_packetout() repeatedly until it returns 0, or the
		 *  extra duplicate frames will be lost.
		 *
		 * \param[in] _buf <tt>int</tt>: The number of duplicates to produce.
		 *                 If this is negative or zero, no duplicates will be produced.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt>, or the
		 *                    number of duplicates is greater than or equal to the
		 *                    maximum keyframe interval.
		 *                   In the latter case, NO duplicate frames will be produced.
		 *                   You must ensure that the maximum keyframe interval is set
		 *                    larger than the maximum number of duplicates you will
		 *                    ever wish to insert prior to encoding.
		 * \retval TH_EIMPL   Not supported by this implementation in the current
		 *                    encoding mode.*/
		SET_DUP_COUNT,
		/**Modifies the default bitrate management behavior.
		 * Use to allow or disallow frame dropping, and to enable or disable capping
		 *  bit reservoir overflows and underflows.
		 * See \ref encctlcodes "the list of available flags".
		 * The flags are set by default to
		 *  <tt>#TH_RATECTL_DROP_FRAMES|#TH_RATECTL_CAP_OVERFLOW</tt>.
		 *
		 * \param[in] _buf <tt>int</tt>: Any combination of
		 *                  \ref ratectlflags "the available flags":
		 *                 - #TH_RATECTL_DROP_FRAMES: Enable frame dropping.
		 *                 - #TH_RATECTL_CAP_OVERFLOW: Don't bank excess bits for later
		 *                    use.
		 *                 - #TH_RATECTL_CAP_UNDERFLOW: Don't try to make up shortfalls
		 *                    later.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt> or rate control
		 *                    is not enabled.
		 * \retval TH_EIMPL   Not supported by this implementation in the current
		 *                    encoding mode.*/
		SET_RATE_FLAGS,
		/**Sets the size of the bitrate management bit reservoir as a function
		 *  of number of frames.
		 * The reservoir size affects how quickly bitrate management reacts to
		 *  instantaneous changes in the video complexity.
		 * Larger reservoirs react more slowly, and provide better overall quality, but
		 *  require more buffering by a client, adding more latency to live streams.
		 * By default, libtheora sets the reservoir to the maximum distance between
		 *  keyframes, subject to a minimum and maximum limit.
		 * This call may be used to increase or decrease the reservoir, increasing or
		 *  decreasing the allowed temporary variance in bitrate.
		 * An implementation may impose some limits on the size of a reservoir it can
		 *  handle, in which case the actual reservoir size may not be exactly what was
		 *  requested.
		 * The actual value set will be returned.
		 *
		 * \param[in]  _buf <tt>int</tt>: Requested size of the reservoir measured in
		 *                   frames.
		 * \param[out] _buf <tt>int</tt>: The actual size of the reservoir set.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(int)</tt>, or rate control
		 *                    is not enabled.  The buffer has an implementation
		 *                    defined minimum and maximum size and the value in _buf
		 *                    will be adjusted to match the actual value set.
		 * \retval TH_EIMPL   Not supported by this implementation in the current
		 *                    encoding mode.*/
		SET_RATE_BUFFER,
		/**Enable pass 1 of two-pass encoding mode and retrieve the first pass metrics.
		 * Pass 1 mode must be enabled before the first frame is encoded, and a target
		 *  bitrate must have already been specified to the encoder.
		 * Although this does not have to be the exact rate that will be used in the
		 *  second pass, closer values may produce better results.
		 * The first call returns the size of the two-pass header data, along with some
		 *  placeholder content, and sets the encoder into pass 1 mode implicitly.
		 * This call sets the encoder to pass 1 mode implicitly.
		 * Then, a subsequent call must be made after each call to
		 *  th_encode_ycbcr_in() to retrieve the metrics for that frame.
		 * An additional, final call must be made to retrieve the summary data,
		 *  containing such information as the total number of frames, etc.
		 * This must be stored in place of the placeholder data that was returned
		 *  in the first call, before the frame metrics data.
		 * All of this data must be presented back to the encoder during pass 2 using
		 *  #TH_ENCCTL_2PASS_IN.
		 *
		 * \param[out] <tt>char *</tt>_buf: Returns a pointer to internal storage
		 *              containing the two pass metrics data.
		 *             This storage is only valid until the next call, or until the
		 *              encoder context is freed, and must be copied by the
		 *              application.
		 * \retval >=0       The number of bytes of metric data available in the
		 *                    returned buffer.
		 * \retval TH_EFAULT \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL \a _buf_sz is not <tt>sizeof(char *)</tt>, no target
		 *                    bitrate has been set, or the first call was made after
		 *                    the first frame was submitted for encoding.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		@2PASS_OUT,
		/**Submits two-pass encoding metric data collected the first encoding pass to
		 *  the second pass.
		 * The first call must be made before the first frame is encoded, and a target
		 *  bitrate must have already been specified to the encoder.
		 * It sets the encoder to pass 2 mode implicitly; this cannot be disabled.
		 * The encoder may require reading data from some or all of the frames in
		 *  advance, depending on, e.g., the reservoir size used in the second pass.
		 * You must call this function repeatedly before each frame to provide data
		 *  until either a) it fails to consume all of the data presented or b) all of
		 *  the pass 1 data has been consumed.
		 * In the first case, you must save the remaining data to be presented after
		 *  the next frame.
		 * You can call this function with a NULL argument to get an upper bound on
		 *  the number of bytes that will be required before the next frame.
		 *
		 * When pass 2 is first enabled, the default bit reservoir is set to the entire
		 *  file; this gives maximum flexibility but can lead to very high peak rates.
		 * You can subsequently set it to another value with #TH_ENCCTL_SET_RATE_BUFFER
		 *  (e.g., to set it to the keyframe interval for non-live streaming), however,
		 *  you may then need to provide more data before the next frame.
		 *
		 * \param[in] _buf <tt>char[]</tt>: A buffer containing the data returned by
		 *                  #TH_ENCCTL_2PASS_OUT in pass 1.
		 *                 You may pass <tt>NULL</tt> for \a _buf to return an upper
		 *                  bound on the number of additional bytes needed before the
		 *                  next frame.
		 *                 The summary data returned at the end of pass 1 must be at
		 *                  the head of the buffer on the first call with a
		 *                  non-<tt>NULL</tt> \a _buf, and the placeholder data
		 *                  returned at the start of pass 1 should be omitted.
		 *                 After each call you should advance this buffer by the number
		 *                  of bytes consumed.
		 * \retval >0            The number of bytes of metric data required/consumed.
		 * \retval 0             No more data is required before the next frame.
		 * \retval TH_EFAULT     \a _enc_ctx is <tt>NULL</tt>.
		 * \retval TH_EINVAL     No target bitrate has been set, or the first call was
		 *                        made after the first frame was submitted for
		 *                        encoding.
		 * \retval TH_ENOTFORMAT The data did not appear to be pass 1 from a compatible
		 *                        implementation of this library.
		 * \retval TH_EBADHEADER The data was invalid; this may be returned when
		 *                        attempting to read an aborted pass 1 file that still
		 *                        has the placeholder data in place of the summary
		 *                        data.
		 * \retval TH_EIMPL       Not supported by this implementation.*/
		@2PASS_IN,
		/**Sets the current encoding quality.
		 * This is only valid so long as no bitrate has been specified, either through
		 *  the #th_info struct used to initialize the encoder or through
		 *  #TH_ENCCTL_SET_BITRATE (this restriction may be relaxed in a future
		 *  version).
		 * If it is set before the headers are emitted, the target quality encoded in
		 *  them will be updated.
		 *
		 * \param[in] _buf <tt>int</tt>: The new target quality, in the range 0...63,
		 *                  inclusive.
		 * \retval 0             Success.
		 * \retval TH_EFAULT     \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL     A target bitrate has already been specified, or the
		 *                        quality index was not in the range 0...63.
		 * \retval TH_EIMPL       Not supported by this implementation.*/
		SET_QUALITY,
		/**Sets the current encoding bitrate.
		 * Once a bitrate is set, the encoder must use a rate-controlled mode for all
		 *  future frames (this restriction may be relaxed in a future version).
		 * If it is set before the headers are emitted, the target bitrate encoded in
		 *  them will be updated.
		 * Due to the buffer delay, the exact bitrate of each section of the encode is
		 *  not guaranteed.
		 * The encoder may have already used more bits than allowed for the frames it
		 *  has encoded, expecting to make them up in future frames, or it may have
		 *  used fewer, holding the excess in reserve.
		 * The exact transition between the two bitrates is not well-defined by this
		 *  API, but may be affected by flags set with #TH_ENCCTL_SET_RATE_FLAGS.
		 * After a number of frames equal to the buffer delay, one may expect further
		 *  output to average at the target bitrate.
		 *
		 * \param[in] _buf <tt>long</tt>: The new target bitrate, in bits per second.
		 * \retval 0             Success.
		 * \retval TH_EFAULT     \a _enc_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL     The target bitrate was not positive.
		 * \retval TH_EIMPL       Not supported by this implementation.*/
		SET_BITRATE
	}

	/* You must link to <tt>libtheoraenc</tt> and <tt>libtheoradec</tt>
	 *  if you use any of the functions in this section.
	 *
	 * The functions are listed in the order they are used in a typical encode.
	 * The basic steps are:
	 * - Fill in a #th_info structure with details on the format of the video you
	 *    wish to encode.
	 * - Allocate a #th_enc_ctx handle with th_encode_alloc().
	 * - Perform any additional encoder configuration required with
	 *    th_encode_ctl().
	 * - Repeatedly call th_encode_flushheader() to retrieve all the header
	 *    packets.
	 * - For each uncompressed frame:
	 *   - Submit the uncompressed frame via th_encode_ycbcr_in()
	 *   - Repeatedly call th_encode_packetout() to retrieve any video data packets
	 *      that are ready.
	 * - Call th_encode_free() to release all encoder memory.*/

	[CCode (cname = "th_enc_ctx", free_function = "th_encode_free")]
	[Compact]
	public class Encoder {
		/**Allocates an encoder instance.
		 * \param _info A #th_info struct filled with the desired encoding parameters.
		 * \return The initialized #th_enc_ctx handle.
		 * \retval NULL If the encoding parameters were invalid.*/
		[CCode (cname = "th_encode_alloc")]
		public Encoder (ref Info info);
		/**Encoder control function.
		 * This is used to provide advanced control the encoding process.
		 * \param _enc    A #th_enc_ctx handle.
		 * \param _req    The control code to process.
		 *                See \ref encctlcodes "the list of available control codes"
		 *                 for details.
		 * \param _buf    The parameters for this control code.
		 * \param _buf_sz The size of the parameter buffer.*/
		[CCode (cname = "th_encode_ctl")]
		public ReturnCode ctl (EncodeCtl req, void *buf, size_t buf_sz);
		[CCode (cname = "th_encode_ctl")]
		public ReturnCode ctl_arr_out (EncodeCtl req, 
		                               [CCode (array_length = false)] out uint8[] buf,
		                               size_t reserved = 0);
		[CCode (cname = "th_encode_ctl")]
		public ReturnCode ctl_arr_in (EncodeCtl req, 
		                               [CCode (array_length_type = "size_t")] uint8[] buf);
		/**Outputs the next header packet.
		 * This should be called repeatedly after encoder initialization until it
		 *  returns 0 in order to get all of the header packets, in order, before
		 *  encoding actual video data.
		 * \param _enc      A #th_enc_ctx handle.
		 * \param _comments The metadata to place in the comment header, when it is
		 *                   encoded.
		 * \param _op       An <tt>ogg_packet</tt> structure to fill.
		 *                  All of the elements of this structure will be set,
		 *                   including a pointer to the header data.
		 *                  The memory for the header data is owned by
		 *                   <tt>libtheoraenc</tt>, and may be invalidated when the
		 *                   next encoder function is called.
		 * \return A positive value indicates that a header packet was successfully
		 *          produced.
		 * \retval 0         No packet was produced, and no more header packets remain.
		 * \retval TH_EFAULT \a _enc, \a _comments, or \a _op was <tt>NULL</tt>.*/
		[CCode (cname = "th_encode_flushheader")]
		public ReturnCode flushheader (ref Comments comments, ref Ogg.Packet op);
		/**Submits an uncompressed frame to the encoder.
		 * \param _enc   A #th_enc_ctx handle.
		 * \param _ycbcr A buffer of Y'CbCr data to encode.
		 * \retval 0         Success.
		 * \retval TH_EFAULT \a _enc or \a _ycbcr is <tt>NULL</tt>.
		 * \retval TH_EINVAL The buffer size does not match the frame size the encoder
		 *                    was initialized with, or encoding has already
		 *                    completed.*/
		[CCode (cname = "th_encode_ycbcr_in")]
		public ReturnCode ycbcr_in ([CCode (array_length = false)] ImgPlane[] ycbcr);
		/**Retrieves encoded video data packets.
		 * This should be called repeatedly after each frame is submitted to flush any
		 *  encoded packets, until it returns 0.
		 * The encoder will not buffer these packets as subsequent frames are
		 *  compressed, so a failure to do so will result in lost video data.
		 * \note Currently the encoder operates in a one-frame-in, one-packet-out
		 *        manner.
		 *       However, this may be changed in the future.
		 * \param _enc  A #th_enc_ctx handle.
		 * \param _last Set this flag to a non-zero value if no more uncompressed
		 *               frames will be submitted.
		 *              This ensures that a proper EOS flag is set on the last packet.
		 * \param _op   An <tt>ogg_packet</tt> structure to fill.
		 *              All of the elements of this structure will be set, including a
		 *               pointer to the video data.
		 *              The memory for the video data is owned by
		 *               <tt>libtheoraenc</tt>, and may be invalidated when the next
		 *               encoder function is called.
		 * \return A positive value indicates that a video data packet was successfully
		 *          produced.
		 * \retval 0         No packet was produced, and no more encoded video data
		 *                    remains.
		 * \retval TH_EFAULT \a _enc or \a _op was <tt>NULL</tt>.*/
		[CCode (cname = "th_encode_packetout")]
		public ReturnCode packetout (int last, ref Ogg.Packet op);
	}

	/**\name th_decode_ctl() codes
	 * \anchor decctlcodes
	 * These are the available request codes for th_decode_ctl().
	 * By convention, these are odd, to distinguish them from the
	 *  \ref encctlcodes "encoder control codes".
	 * Keep any experimental or vendor-specific values above \c 0x8000.*/
	[CCode (cname = "int", cprefix = "TH_DECCTL_")]
	public enum DecodeCtl {
		/**Gets the maximum post-processing level.
		 * The decoder supports a post-processing filter that can improve
		 * the appearance of the decoded images. This returns the highest
		 * level setting for this post-processor, corresponding to maximum
		 * improvement and computational expense.
		 *
		 * \param[out] _buf int: The maximum post-processing level.
		 * \retval TH_EFAULT  \a _dec_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL  \a _buf_sz is not <tt>sizeof(int)</tt>.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		GET_PPLEVEL_MAX,
		/**Sets the post-processing level.
		 * By default, post-processing is disabled.
		 *
		 * Sets the level of post-processing to use when decoding the
		 * compressed stream. This must be a value between zero (off)
		 * and the maximum returned by TH_DECCTL_GET_PPLEVEL_MAX.
		 *
		 * \param[in] _buf int: The new post-processing level.
		 *                      0 to disable; larger values use more CPU.
		 * \retval TH_EFAULT  \a _dec_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL  \a _buf_sz is not <tt>sizeof(int)</tt>, or the
		 *                     post-processing level is out of bounds.
		 *                    The maximum post-processing level may be
		 *                     implementation-specific, and can be obtained via
		 *                     #TH_DECCTL_GET_PPLEVEL_MAX.
		 * \retval TH_EIMPL   Not supported by this implementation.*/
		SET_PPLEVEL,
		/**Sets the granule position.
		 * Call this after a seek, before decoding the first frame, to ensure that the
		 *  proper granule position is returned for all subsequent frames.
		 * If you track timestamps yourself and do not use the granule position
		 *  returned by the decoder, then you need not call this function.
		 *
		 * \param[in] _buf <tt>ogg_int64_t</tt>: The granule position of the next
		 *                  frame.
		 * \retval TH_EFAULT  \a _dec_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL  \a _buf_sz is not <tt>sizeof(ogg_int64_t)</tt>, or the
		 *                     granule position is negative.*/
		SET_GRANPOS,
		/**Sets the striped decode callback function.
		 * If set, this function will be called as each piece of a frame is fully
		 *  decoded in th_decode_packetin().
		 * You can pass in a #th_stripe_callback with
		 *  th_stripe_callback#stripe_decoded set to <tt>NULL</tt> to disable the
		 *  callbacks at any point.
		 * Enabling striped decode does not prevent you from calling
		 *  th_decode_ycbcr_out() after the frame is fully decoded.
		 *
		 * \param[in]  _buf #th_stripe_callback: The callback parameters.
		 * \retval TH_EFAULT  \a _dec_ctx or \a _buf is <tt>NULL</tt>.
		 * \retval TH_EINVAL  \a _buf_sz is not
		 *                     <tt>sizeof(th_stripe_callback)</tt>.*/
		SET_STRIPE_CB,

		/**Enables telemetry and sets the macroblock display mode */
		SET_TELEMETRY_MBMODE,
		/**Enables telemetry and sets the motion vector display mode */
		SET_TELEMETRY_MV,
		/**Enables telemetry and sets the adaptive quantization display mode */
		SET_TELEMETRY_QI,
		/**Enables telemetry and sets the bitstream breakdown visualization mode */
		SET_TELEMETRY_BITS
	}

	/**A callback function for striped decode.
	 * This is a function pointer to an application-provided function that will be
	 *  called each time a section of the image is fully decoded in
	 *  th_decode_packetin().
	 * This allows the application to process the section immediately, while it is
	 *  still in cache.
	 * Note that the frame is decoded bottom to top, so \a _yfrag0 will steadily
	 *  decrease with each call until it reaches 0, at which point the full frame
	 *  is decoded.
	 * The number of fragment rows made available in each call depends on the pixel
	 *  format and the number of post-processing filters enabled, and may not even
	 *  be constant for the entire frame.
	 * If a non-<tt>NULL</tt> \a _granpos pointer is passed to
	 *  th_decode_packetin(), the granule position for the frame will be stored
	 *  in it before the first callback is made.
	 * If an entire frame is dropped (a 0-byte packet), then no callbacks will be
	 *  made at all for that frame.
	 * \param _ctx       An application-provided context pointer.
	 * \param _buf       The image buffer for the decoded frame.
	 * \param _yfrag0    The Y coordinate of the first row of 8x8 fragments
	 *                    decoded.
	 *                   Multiply this by 8 to obtain the pixel row number in the
	 *                    luma plane.
	 *                   If the chroma planes are subsampled in the Y direction,
	 *                    this will always be divisible by two.
	 * \param _yfrag_end The Y coordinate of the first row of 8x8 fragments past
	 *                    the newly decoded section.
	 *                   If the chroma planes are subsampled in the Y direction,
	 *                    this will always be divisible by two.
	 *                   I.e., this section contains fragment rows
	 *                    <tt>\a _yfrag0 ...\a _yfrag_end -1</tt>.*/
	[CCode (cname = "th_stripe_decoded_func", has_target = false, 
	        has_type_id = false)]
	public delegate void DecodedFunc (
	    void *ctx, [CCode (array_length = false)] ImgPlane[] buf,
	    int yfrag0, int yfrag_end);

	/**The striped decode callback data to pass to #TH_DECCTL_SET_STRIPE_CB.*/
	[CCode (cname = "th_stripe_callback")]
	public struct StripeCallback {
		/**An application-provided context pointer.
		 * This will be passed back verbatim to the application.*/
		void *ctx;
		/**The callback function pointer.*/
		DecodedFunc stripe_decoded;
	}

	/**\defgroup decfuncs Functions for Decoding*/

	/**\name Functions for decoding
	 * You must link to <tt>libtheoradec</tt> if you use any of the 
	 * functions in this section.
	 *
	 * The functions are listed in the order they are used in a typical decode.
	 * The basic steps are:
	 * - Parse the header packets by repeatedly calling th_decode_headerin().
	 * - Allocate a #th_dec_ctx handle with th_decode_alloc().
	 * - Call th_setup_free() to free any memory used for codec setup
	 *    information.
	 * - Perform any additional decoder configuration with th_decode_ctl().
	 * - For each video data packet:
	 *   - Submit the packet to the decoder via th_decode_packetin().
	 *   - Retrieve the uncompressed video data via th_decode_ycbcr_out().
	 * - Call th_decode_free() to release all decoder memory.*/

	/**\name Decoder state
	   The following data structures are opaque, and their contents are not
		publicly defined by this API.
	   Referring to their internals directly is unsupported, and may break without
		warning.*/

	/**Setup information.
	  This contains auxiliary information (Huffman tables and quantization
	  parameters) decoded from the setup header by th_decode_headerin() to be
	  passed to th_decode_alloc().
	  It can be re-used to initialize any number of decoders, and can be freed
	  via th_setup_free() at any time.*/
	[CCode (cname = "th_setup_info", destroy_function = "th_setup_free")]
	public struct SetupInfo {
	}

	/**The decoder context.*/
	[CCode (cname = "th_dec_ctx", free_function = "th_decode_free")]
	[Compact]
	public class Decoder {
		/**Allocates a decoder instance.
		 *
		 * <b>Security Warning:</b> The Theora format supports very large frame sizes,
		 *  potentially even larger than the address space of a 32-bit machine, and
		 *  creating a decoder context allocates the space for several frames of data.
		 * If the allocation fails here, your program will crash, possibly at some
		 *  future point because the OS kernel returned a valid memory range and will
		 *  only fail when it tries to map the pages in it the first time they are
		 *  used.
		 * Even if it succeeds, you may experience a denial of service if the frame
		 *  size is large enough to cause excessive paging.
		 * If you are integrating libtheora in a larger application where such things
		 *  are undesirable, it is highly recommended that you check the frame size in
		 *  \a _info before calling this function and refuse to decode streams where it
		 *  is larger than some reasonable maximum.
		 * libtheora will not check this for you, because there may be machines that
		 *  can handle such streams and applications that wish to.
		 * \param _info  A #th_info struct filled via th_decode_headerin().
		 * \param _setup A #th_setup_info handle returned via
		 *                th_decode_headerin().
		 * \return The initialized #th_dec_ctx handle.
		 * \retval NULL If the decoding parameters were invalid.*/
		[CCode (cname = "th_decode_alloc")]
		public Decoder (Info info, SetupInfo setup);
		/**Decoder control function.
		 * This is used to provide advanced control of the decoding process.
		 * \param _dec    A #th_dec_ctx handle.
		 * \param _req    The control code to process.
		 *                See \ref decctlcodes "the list of available control codes"
		 *                 for details.
		 * \param _buf    The parameters for this control code.
		 * \param _buf_sz The size of the parameter buffer.*/
		[CCode (cname = "th_decode_ctl")]
		public int ctl (DecodeCtl req, void *buf, size_t buf_sz);
		/**Submits a packet containing encoded video data to the decoder.
		 * \param _dec     A #th_dec_ctx handle.
		 * \param _op      An <tt>ogg_packet</tt> containing encoded video data.
		 * \param _granpos Returns the granule position of the decoded packet.
		 *                 If non-<tt>NULL</tt>, the granule position for this specific
		 *                  packet is stored in this location.
		 *                 This is computed incrementally from previously decoded
		 *                  packets.
		 *                 After a seek, the correct granule position must be set via
		 *                  #TH_DECCTL_SET_GRANPOS for this to work properly.
		 * \retval 0             Success.
		 *                       A new decoded frame can be retrieved by calling
		 *                        th_decode_ycbcr_out().
		 * \retval TH_DUPFRAME   The packet represented a dropped (0-byte) frame.
		 *                       The player can skip the call to th_decode_ycbcr_out(),
		 *                        as the contents of the decoded frame buffer have not
		 *                        changed.
		 * \retval TH_EFAULT     \a _dec or \a _op was <tt>NULL</tt>.
		 * \retval TH_EBADPACKET \a _op does not contain encoded video data.
		 * \retval TH_EIMPL      The video data uses bitstream features which this
		 *                        library does not support.*/
		[CCode (cname = "th_decode_packetin")]
		public int packetin (Ogg.Packet op, out int64 granpos);
		/**Outputs the next available frame of decoded Y'CbCr data.
		 * If a striped decode callback has been set with #TH_DECCTL_SET_STRIPE_CB,
		 *  then the application does not need to call this function.
		 * \param _dec   A #th_dec_ctx handle.
		 * \param _ycbcr A video buffer structure to fill in.
		 *               <tt>libtheoradec</tt> will fill in all the members of this
		 *                structure, including the pointers to the uncompressed video
		 *                data.
		 *               The memory for this video data is owned by
		 *                <tt>libtheoradec</tt>.
		 *               It may be freed or overwritten without notification when
		 *                subsequent frames are decoded.
		 * \retval 0 Success
		 * \retval TH_EFAULT     \a _dec or \a _ycbcr was <tt>NULL</tt>.
		 */
		[CCode (cname = "th_decode_ycbcr_out")]
		public int ycbcr_out ([CCode (array_length = false)] ImgPlane[] ycbcr);
	}

}
