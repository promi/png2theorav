dnl png2theorav - create theora movie from png files
dnl Copyright (C) 2002-2009 Xiph.Org Foundation and contributors 
dnl                         <http://www.xiph.org>
dnl Copyright (C) 2015 Prometheus <prometheus@unterderbruecke.de>
dnl
dnl This program is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU Affero General Public License as
dnl published by the Free Software Foundation, either version 3 of the
dnl License, or (at your option) any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU Affero General Public License for more details.
dnl
dnl You should have received a copy of the GNU Affero General Public License
dnl along with this program.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl This is a derived work, original license and copyright:
dnl
dnl ********************************************************************
dnl *                                                                  *
dnl * THIS FILE IS PART OF THE OggTheora SOFTWARE CODEC SOURCE CODE.   *
dnl * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
dnl * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
dnl * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
dnl *                                                                  *
dnl * THE Theora SOURCE CODE IS COPYRIGHT (C) 2002-2009,2009           *
dnl * by the Xiph.Org Foundation and contributors http://www.xiph.org/ *
dnl *                                                                  *
dnl ********************************************************************
dnl
dnl  function: example encoder application; makes an Ogg Theora
dnl            file from a sequence of png images
dnl  last mod: $Id$
dnl             based on code from Vegard Nossum
dnl
dnl ********************************************************************

dnl Process this file with autoconf to produce a configure script.
dnl Created by Anjuta application wizard.

AC_INIT(png2theorav, 1.0)

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])

AC_PROG_CC

LT_INIT
LT_LIB_M

dnl Not useful, lrint should always be in libm anyways
dnl AC_CHECK_LIB([m], lrint)

dnl Check for vala
AM_PROG_VALAC([0.10.0])

PKG_CHECK_MODULES(PNG2THEORAV, [gio-2.0 gee-0.8 ogg theoraenc libpng])

AC_OUTPUT([
Makefile
src/Makefile
])
