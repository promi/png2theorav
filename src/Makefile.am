# png2theorav - create theora movie from png files
# Copyright (C) 2002-2009 Xiph.Org Foundation and contributors 
#                         <http://www.xiph.org>
# Copyright (C) 2015 Prometheus <prometheus@unterderbruecke.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This is a derived work, original license and copyright:
#
# ********************************************************************
# *                                                                  *
# * THIS FILE IS PART OF THE OggTheora SOFTWARE CODEC SOURCE CODE.   *
# * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
# * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
# * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
# *                                                                  *
# * THE Theora SOURCE CODE IS COPYRIGHT (C) 2002-2009,2009           *
# * by the Xiph.Org Foundation and contributors http://www.xiph.org/ *
# *                                                                  *
# ********************************************************************
#
#  function: example encoder application; makes an Ogg Theora
#            file from a sequence of png images
#  last mod: $Id$
#             based on code from Vegard Nossum
#
# ********************************************************************

## Process this file with automake to produce Makefile.in

## Created by Anjuta

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	$(PNG2THEORAV_CFLAGS)

AM_CFLAGS = \
	 -Wno-unused-variable

bin_PROGRAMS = png2theorav

png2theorav_SOURCES = \
	main.vala config.vapi theora.vapi ogg.vapi rgb-image.vala \
	frame-writer.vala png-reader.vala png.vapi y-cb-cr.vala \
	options.vala main-loop.vala error.vala stream-state-adapter.vala \
	file-writer.vala two-pass-file.vala

png2theorav_VALAFLAGS = \
	--pkg gio-2.0 --pkg gee-0.8 --enable-experimental-non-null

png2theorav_LDFLAGS = \
	-Wl,--export-dynamic

png2theorav_LDADD = $(LIBM) $(PNG2THEORAV_LIBS)

uninstall-local:
	-rm -r $(pkgdatadir)

