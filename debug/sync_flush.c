///////////////////////////////////////////////////////////////////////////////
//
/// \file       sync_flush.c
/// \brief      Encode files using LZMA_SYNC_FLUSH
//
//  Copyright (C) 2008 Lasse Collin
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
///////////////////////////////////////////////////////////////////////////////

#include "sysdefs.h"
#include <stdio.h>


static lzma_stream strm = LZMA_STREAM_INIT;
static FILE *file_in;


static void
encode(size_t size, lzma_action action)
{
	static const size_t CHUNK = 64;
	uint8_t in[CHUNK];
	uint8_t out[CHUNK];
	lzma_ret ret;

	do {
		if (strm.avail_in == 0 && size > 0) {
			const size_t amount = MIN(size, CHUNK);
			strm.avail_in = fread(in, 1, amount, file_in);
			strm.next_in = in;
			size -= amount; // Intentionally not using avail_in.
		}

		strm.next_out = out;
		strm.avail_out = CHUNK;

		ret = lzma_code(&strm, size == 0 ? action : LZMA_RUN);

		if (ret != LZMA_OK && ret != LZMA_STREAM_END) {
			fprintf(stderr, "%s:%u: %s: ret == %d\n",
					__FILE__, __LINE__, __func__, ret);
			exit(1);
		}

		fwrite(out, 1, CHUNK - strm.avail_out, stdout);

	} while (size > 0 || strm.avail_out == 0);

	if ((action == LZMA_RUN && ret != LZMA_OK)
			|| (action != LZMA_RUN && ret != LZMA_STREAM_END)) {
		fprintf(stderr, "%s:%u: %s: ret == %d\n",
				__FILE__, __LINE__, __func__, ret);
		exit(1);
	}
}


int
main(int argc, char **argv)
{
	lzma_init_encoder();

	file_in = argc > 1 ? fopen(argv[1], "rb") : stdin;

	// Config
	lzma_options_lzma opt_lzma = {
		.dictionary_size = 1 << 16,
		.literal_context_bits = LZMA_LITERAL_CONTEXT_BITS_DEFAULT,
		.literal_pos_bits = LZMA_LITERAL_POS_BITS_DEFAULT,
		.pos_bits = LZMA_POS_BITS_DEFAULT,
		.preset_dictionary = NULL,
		.mode = LZMA_MODE_BEST,
		.fast_bytes = 32,
		.match_finder = LZMA_MF_BT3,
		.match_finder_cycles = 0,
	};

	lzma_options_stream opt_stream = {
		.check = LZMA_CHECK_NONE,
		.has_crc32 = false,
		.uncompressed_size = LZMA_VLI_VALUE_UNKNOWN,
		.alignment = 0,
	};
	opt_stream.filters[0].id = LZMA_FILTER_LZMA;
	opt_stream.filters[0].options = &opt_lzma;
	opt_stream.filters[1].id = LZMA_VLI_VALUE_UNKNOWN;

	// Init
	if (lzma_stream_encoder_single(&strm, &opt_stream) != LZMA_OK) {
		fprintf(stderr, "init failed\n");
		exit(1);
	}

	// Encoding
	encode(0, LZMA_SYNC_FLUSH);
	encode(6, LZMA_SYNC_FLUSH);
	encode(0, LZMA_SYNC_FLUSH);
	encode(6, LZMA_SYNC_FLUSH);
	encode(0, LZMA_SYNC_FLUSH);
	encode(0, LZMA_FINISH);

	// Clean up
	lzma_end(&strm);

	return 0;
}