/* -*- Mode: C; tab-width: 8; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* vim: set ts=2 et sw=2 tw=80: */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/** Hindsight utility functions @file */

#ifndef hs_util_h_
#define hs_util_h_

#include <stdbool.h>
#include <stdio.h>
#include <time.h>

/**
 * Test a file exists and can be opened for reading.
 *
 * @param fn filename
 *
 * @return bool True if the file exists
 */
bool hs_file_exists(const char *fn);

/**
 * Test if a filename ends with the specified extension
 *
 * @param fn filename
 * @param ext extension
 *
 * @return bool True if the extension matches
 */
bool hs_has_ext(const char *fn, const char *ext);

/**
 * Constructs a fully qualified filename from the provided components
 *
 * @param path Base path
 * @param name File name
 * @param fqfn Buffer to construct the string in
 * @param fqfn_len Length of the buffer
 *
 * @return int 0 if string was successfully constructed
 */
int hs_get_fqfn(const char *path,
                const char *name,
                char *fqfn,
                size_t fqfn_len);

/**
 * Escapes a string being written to a Lua file
 *
 * @param fh file handle write the string to
 * @param s string to escape
 *
 * @return int 0 if successfully escaped/output
 */
int hs_output_lua_string(FILE *fh, const char *s);


/**
 * Returns the amount of free disk space as the number of output
 * buffers remaining.
 *
 * @param path Pathname to a file mounted on the filesystem
 * @param ob_size Output buffer size in bytes
 *
 * @return unsigned Number of buffers
 */
unsigned hs_disk_free_ob(const char *path, unsigned ob_size);
#endif
