/**************************************************************************************
 * Copyright (c) 2018-2020 ["Peking University Shenzhen Graduate School",
 *   "Peng Cheng Laboratory", and "Guangdong Bohua UHD Innovation Corporation"]
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *    This product includes software developed by the <organization>.
 * 4. Neither the name of the <organization> nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * For more information, contact us at rgwang@pkusz.edu.cn.
 **************************************************************************************/

#define _CRT_SECURE_NO_WARNINGS

#include "utest.h"

#include "../source/decoder/uavs3d.h"

#include "../version.h"

#define DYM_LOAD_DYNAMIC_LIBRARY 0

#if DYM_LOAD_DYNAMIC_LIBRARY
#if defined(__GNUC__) 
#include <dlfcn.h>
#endif
uavs3d_create_t         libuavs3d_create;
uavs3d_delete_t         libuavs3d_delete;
uavs3d_reset_t          libuavs3d_reset;
uavs3d_pull_frm_t       libuavs3d_pull_frm;
uavs3d_flush_t          libuavs3d_flush;
uavs3d_decode_t         libuavs3d_decode;
uavs3d_img_cpy_cvt_t    libuavs3d_img_cpy_cvt;
#else
#define libuavs3d_create        uavs3d_create
#define libuavs3d_delete        uavs3d_delete
#define libuavs3d_reset         uavs3d_reset
#define libuavs3d_pull_frm      uavs3d_pull_frm
#define libuavs3d_flush         uavs3d_flush
#define libuavs3d_decode        uavs3d_decode
#define libuavs3d_img_cpy_cvt   uavs3d_img_cpy_cvt
#endif

#define MAX_BS_BUF                 (32*1024*1024) /* byte */

static uavs3d_cfg_t    dec_cfg;
static int             frame_num = 0;

typedef enum
{
    INVALID,
    HELP,
    VERSION,
    INPUT_FILE,
    OUTPUT_FILE,
    NUM_THREADS,
    NUM_FRAMES,
    LOG_LEVEL,
    CHECK_MD5
}UAVS3D_ARG_T;

typedef struct
{
    char argument_shortname[4];
    char argument_name[128];
    UAVS3D_ARG_T argument;
    char description[512];
}uavs3d_arg_t;

static const uavs3d_arg_t argument_mapping[] =
{
    { "-h",  "--help",                  HELP,
    "Print this help\n" },
    { "-v",  "--version",               VERSION,
    "Version information\n" },
    { "-i",  "--input",                 INPUT_FILE,
    "Input file\n" },
    { "-o",  "--output",                OUTPUT_FILE,
    "Output file\n" },
    { "-l",  "--loglevel",              LOG_LEVEL,
    "Log level (0: no message; 1: seq level message; 2: frame level log (default) \n" },
    { "-t",  "--threads",               NUM_THREADS,
    "Number of frame-level threads\n" },
    { "-f",  "--frames",                NUM_FRAMES,
    "Total frames to decode\n" },
    { "-s",  "--check_md5",             CHECK_MD5,
    "Enable to check md5 or not\n" },
};

UAVS3D_ARG_T get_argument(const char *name)
{
    int i = 0;
    int num_entries = sizeof(argument_mapping) / sizeof(UAVS3D_ARG_T);
    while (i < num_entries)
    {
        if ((0 == strcmp(argument_mapping[i].argument_name, name)) ||
            ((0 == strcmp(argument_mapping[i].argument_shortname, name)) &&
            (0 != strcmp(argument_mapping[i].argument_shortname, "--"))))
        {
            return argument_mapping[i].argument;
        }
        i++;
    }
    return INVALID;
}

void print_help()
{
    int i = 0;
    int num_entries = sizeof(argument_mapping) / sizeof(uavs3d_arg_t);
    fprintf(stderr, "\nArguments:\n");
    char arg[48];
    while (i < num_entries)
    {
        sprintf(arg, "%s (%s)", argument_mapping[i].argument_shortname, argument_mapping[i].argument_name);
        fprintf(stderr, "%-16s\t %s", arg, argument_mapping[i].description);
        i++;
    }
}

void print_version()
{
    fprintf(stderr, "\nuavs2d: %s_%s, %s\n", VERSION_STR, VERSION_TYPE, VERSION_SHA1);
}

void parse_argument(uavs3d_cfg_t *dec_ctx, const char *argument, const char *value)
{
    UAVS3D_ARG_T arg;

    arg = get_argument(argument);
    switch (arg)
    {
    case HELP:
        print_help();
        exit(-1);
    case VERSION:
        print_version();
        exit(-1);
    case INPUT_FILE:
        dec_ctx->input_file = value;
        break;

    case OUTPUT_FILE:
        dec_ctx->output_file = value;
        break;

    case NUM_THREADS:
        sscanf(value, "%d", &dec_ctx->frm_threads);
        break;

    case NUM_FRAMES:
        sscanf(value, "%d", &dec_ctx->dec_frames);
        break;

    case LOG_LEVEL:
        sscanf(value, "%d", &dec_ctx->log_level);
        break;

    case CHECK_MD5:
        sscanf(value, "%d", &dec_ctx->check_md5);
        break;
    case INVALID:
    default:
        fprintf(stderr, "Ignoring argument :  %s\n", argument);
        break;
    }
}

static int app_img_write(char * fname, uavs3d_io_frm_t * img, com_seqh_t *seqhdr, int bit_depth)
{
    int i, j;
    int scale = (bit_depth == 10 ? 2 : 1);
    FILE *fp = fopen(fname, "ab");

    if (fp == NULL) {
        print("cannot open file = %s\n", fname);
        return -1;
    }
    for (i = 0; i < 3; i++) {
        int hor_size = seqhdr->horizontal_size >> (i ? 1 : 0);
        int ver_size = seqhdr->vertical_size >> (i ? 1 : 0);
        unsigned char * p8 = (unsigned char *)img->buffer[i];

        for (j = 0; j < ver_size; j++) {
            fwrite(p8, hor_size * scale, 1, fp);
            p8 += img->stride[i];
        }
    }
    fclose(fp);
    return 0;
}

static void app_img_free(uavs3d_io_frm_t * img)
{
    int i;
    for (i = 0; i < img->num_plane; i++) {
        if (img->buffer[i]) free(img->buffer[i]);
    }
    free(img);
}

static uavs3d_io_frm_t * app_img_alloc(int width, int height, int bitDepth)
{
    int i;
    uavs3d_io_frm_t * img;
    img = (uavs3d_io_frm_t *)malloc(sizeof(uavs3d_io_frm_t));

    if (img == NULL) {
        log_level_0("cannot create image buffer\n");
        return NULL;
    }
    memset(img, 0, sizeof(uavs3d_io_frm_t));

    for (i = 0; i < 3; i++) {
        img->width[i] = width;
        img->stride[i] = width * (bitDepth == 8 ? 1 : 2);
        img->height[i] = height;
        img->buffer[i] = malloc(img->stride[i] * height);

        if (img->buffer[i] == NULL) {
            log_level_0("cannot allocate picture buffer\n");
            return NULL;
        }
        if (i == 0) {
            width = (width + 1) >> 1;
            height = (height + 1) >> 1;
        }
    }
    img->num_plane = 3;

    return img;
}

static int find_next_start_code(FILE * fp, int *nal_size, unsigned char *bs_buf)
{
    char prefix_code[3];
    char is_bs_end = 0;
    size_t read_size = fread(&prefix_code, 1, 3, fp);

    if (read_size != 3 || feof(fp)) {
        return -1;
    }

    assert(0 == prefix_code[0] && 0 == prefix_code[1] && 1 == prefix_code[2]);

    int next_start_code = 0;
    unsigned int byte_idx = 0;
    unsigned int zero_num = 0;

    bs_buf[byte_idx++] = 0x00;
    bs_buf[byte_idx++] = 0x00;
    bs_buf[byte_idx++] = 0x01;

    while (1) {
        unsigned char byte = 0;
        read_size = fread(&byte, 1, 1, fp);

        if (feof(fp)) {
            next_start_code = 0;
            is_bs_end = 1;
            break;
        }
        bs_buf[byte_idx++] = byte;

        if (1 < byte) {
            zero_num = 0;
        } else if (0 == byte) {
            zero_num++;
        } else if (zero_num > 1) {
            unsigned char last_byte = byte;

            if (fread(&byte, 1, 1, fp) != 1) {
                return -1;
            }
           
            bs_buf[byte_idx++] = byte;

            if (last_byte == 0x01 && (byte == 0xb3 || byte == 0xb6 || byte == 0xb0 || byte == 0x00 || byte == 0xb1)) {
                next_start_code = 2 + 1 + 1;
                zero_num = 0;
                break;
            } else {
                zero_num = 0;
                next_start_code = 0;// 2 + 1 + 1;
            }
        } else {
            zero_num = 0;
        }
    }
    *nal_size = byte_idx - next_start_code;

    if (is_bs_end) {
        return 0;
    }
    if (fseek(fp, -1 * next_start_code, SEEK_CUR) != 0) {
        printf("Seek failed!\n");
    }
    return 0;
}

static int read_one_nal(FILE * fp, int * pos, unsigned char * bs_buf)
{
    int bs_size = 0;
    int read_size = 0;

    if (!fseek(fp, *pos, SEEK_SET)) {
        int ret = find_next_start_code(fp, &bs_size, bs_buf);

        if (ret == -1) {
            log_level_2(" ->  End of file\n");
            return -1;
        }
        read_size = bs_size;
    } else {
        log_level_0(" ->  Cannot seek bitstream!\n");
        return -1;
    }
    return read_size;
}

static int print_stat(uavs3d_io_frm_t *img)
{
    char type = 0;
    int i, j;

    switch (img->type) {
    case SLICE_I:
        type = 'I';
        break;
    case SLICE_P:
        type = 'P';
        break;
    case SLICE_B:
        type = 'B';
        break;
    default:
        type = 'U';
        break;
    }

    log_level_2("%6d %6d ", frame_num, (int)img->ptr);
    log_level_2("(%c) ", type);
      
    for (i = 0; i < 2; i++) {
        log_level_2("[L%d  ", i);
        for (j = 0; j < img->refpic_num[i]; j++) log_level_2("%lld ", img->refpic[i][j]);
        log_level_2("] ");
    }
    log_level_2("\n");
    return 0;
}

static int write_dec_img(const char * fname, uavs3d_io_frm_t * img, com_seqh_t *seqhdr)
{
    uavs3d_io_frm_t* app_img_t = NULL;
    int bit_depth_internal = img->bit_depth;

    if (app_img_t == NULL) {
        app_img_t = app_img_alloc(img->width[0], img->height[0], bit_depth_internal);
        if (app_img_t == NULL) {
            log_level_0("failed to allocate temporay image buffer\n");
            return -1;
        }
    }

    libuavs3d_img_cpy_cvt(app_img_t, img, bit_depth_internal);

    if (app_img_write((char*)fname, app_img_t, seqhdr, bit_depth_internal)) return -1;

    if (app_img_t) {
        app_img_free(app_img_t);
    }

    return RET_OK;
}

void output_callback(uavs3d_io_frm_t *frm) {
    if (dec_cfg.dec_frames > 0 && frame_num >= dec_cfg.dec_frames) {
        return;
    }

    print_stat(frm);
    if (dec_cfg.output_file) {
        write_dec_img(dec_cfg.output_file, frm, frm->seqhdr);
    }
    frame_num++;
}

#if defined(__APPLE__) && (defined(__arm64__) || defined(__ARM_NEON__))
int uavs3d_decode_sample(int argc, const char **argv)
#else
int main(int argc, const char **argv)
#endif
{
    int               decoding = 1;
    unsigned char   * bs_buf = NULL;
    void            * h = NULL;
    int               ret;
    long long         time_start, time_total;
    long long         time_frm_start, time_decode = 0;
    int               bs_cnt;
    int               bs_size, bs_read_pos = 0;
    int               width = 0, height = 0, hor_size = 0, ver_size = 0;
    FILE            * fp_bs = NULL;
    long long         dts = 0;
    int               i;

#if DYM_LOAD_DYNAMIC_LIBRARY
#if defined(_WIN32)
    HMODULE inst_lib;
    if ((inst_lib = LoadLibrary("libuavs3d.dll")) == NULL) {
        printf("Load library error.\n");
        return -1;
    }
#define LOAD_FUN GetProcAddress
#else
    void* inst_lib = dlopen("libuavs3d.so", RTLD_LAZY);
    if (!inst_lib) {
        printf("Load library error.(%s).\n", dlerror());
        return -1;
    }
#define LOAD_FUN dlsym
#endif

    libuavs3d_create      = (uavs3d_create_t     )LOAD_FUN(inst_lib, "uavs3d_create"     );
    libuavs3d_delete      = (uavs3d_delete_t     )LOAD_FUN(inst_lib, "uavs3d_delete"     );
    libuavs3d_reset       = (uavs3d_reset_t      )LOAD_FUN(inst_lib, "uavs3d_reset"      );
    libuavs3d_pull_frm    = (uavs3d_pull_frm_t   )LOAD_FUN(inst_lib, "uavs3d_pull_frm"   );
    libuavs3d_flush       = (uavs3d_flush_t      )LOAD_FUN(inst_lib, "uavs3d_flush"      );
    libuavs3d_decode      = (uavs3d_decode_t     )LOAD_FUN(inst_lib, "uavs3d_decode"     );
    libuavs3d_img_cpy_cvt = (uavs3d_img_cpy_cvt_t)LOAD_FUN(inst_lib, "uavs3d_img_cpy_cvt");

#endif //#if DYM_LOAD_DYNAMIC_LIBRARY

    time_start = get_time();

    /* parse argv */
    memset(&dec_cfg, 0, sizeof(uavs3d_cfg_t));

    dec_cfg.log_level = 1;
    dec_cfg.frm_threads = 1;

    if (argc % 2 != 1 || argc < 2) {
        log_level_0("Error config, please check arguments: \n");
        print_help();
        return -1;
    }
    for (i = 1; i < argc; i += 2)
    {
        parse_argument(&dec_cfg, argv[i], argv[i + 1]);
    }

    cfg_log_level = dec_cfg.log_level;

    fp_bs = fopen(dec_cfg.input_file, "rb");
    if(fp_bs == NULL)
    {
        log_level_0("ERROR: failed to open bitstream file : %s\n", dec_cfg.input_file);
        print_help();
        return -1;
    }

    log_level_1("bitstream file : %s\n", dec_cfg.input_file);

    if(dec_cfg.output_file)
    {
        FILE * fp;
        fp = fopen(dec_cfg.output_file, "wb");
        if(fp == NULL)
        {
            log_level_0("ERROR: failed to open decoded file: %s\n", dec_cfg.output_file);
            print_help();
            return -1;
        }
        fclose(fp);
    }

    bs_buf = malloc(MAX_BS_BUF);
    if(bs_buf == NULL)
    {
        log_level_0("ERROR: failed to allocate stream buffer (size = %d)\n", MAX_BS_BUF);
        return -1;
    }

    dec_cfg.check_md5 = dec_cfg.log_level >= LOG_LVL_2 ? dec_cfg.check_md5 : 0;

    h = libuavs3d_create(&dec_cfg, output_callback, NULL);

    if(h == NULL) {
        log_level_0("ERROR: failed to create uavs3d decoder\n");
        return -1;
    }

    frame_num = 0;
    bs_cnt  = 0;
    width = height = 0;

    int repeat = 0;
    uavs3d_io_frm_t dec_frame;
    while(decoding) {

        if (dec_cfg.dec_frames > 0 && frame_num >= dec_cfg.dec_frames) {
            goto finished;
        }

        bs_size = read_one_nal(fp_bs, &bs_read_pos, bs_buf);

        if (bs_size <= 0 && repeat) {
            repeat--;
            bs_read_pos = 0;
            bs_size = read_one_nal(fp_bs, &bs_read_pos, bs_buf);
        }
#if 0
        if (frame_num == 32) {
            frame_num++;
            libuavs3d_reset((void*)h);
            continue;
        }
#endif

        if(bs_size <= 0) {
            decoding = 0;
        }
        bs_read_pos += bs_size;
        bs_cnt += bs_size;
        time_frm_start = get_time();

        /* main decoding block */
        dec_frame.bs = bs_buf;
        dec_frame.bs_len = bs_size;
        dec_frame.dts = dts;
        dec_frame.pts = -1;

        ret = libuavs3d_decode((void *)h, &dec_frame);
        if(ret < 0) {
            log_level_0(" ->  Failed: %d\n", ret);
        } else if (dec_frame.nal_type == NAL_SEQ_HEADER) {
            log_level_2(" ->  Sequence header\n");
        } else if (dec_frame.nal_type == NAL_SEQ_END) {
            log_level_2(" ->  Sequence finished\n");
        }
        time_decode += app_get_time_dur(time_frm_start);
        
    }

    log_level_2(" ->  Flush\n");

    do {
        if (dec_cfg.dec_frames > 0 && frame_num >= dec_cfg.dec_frames) {
            goto finished;
        }

        time_frm_start = get_time();
        ret = libuavs3d_flush((void *)h, &dec_frame);
        time_decode += app_get_time_dur(time_frm_start);
    } while (ret >= 0);
    

finished:

    time_total = app_get_time_dur(time_start);

    if (frame_num) {
        width  = dec_frame.width[0];
        height = dec_frame.height[0];
        hor_size = dec_frame.seqhdr->horizontal_size;
        ver_size = dec_frame.seqhdr->vertical_size;

        log_level_1("=========================================================================================\n");
        log_level_1(" Resolution               = %d x %d (Coding: %d x %d)\n", hor_size, ver_size, width, height);
        log_level_1(" Average bits per frame   = %d\n", bs_cnt * 8 / frame_num);
        log_level_1(" Decoded frame count      = %d\n", frame_num);

        if (frame_num > 0) {
            log_level_1(" Total decoding time      = %d msec, fps = %.1f\n",
                (int)SCALE_TIME(time_total), ((float)frame_num * 1000) / ((float)SCALE_TIME(time_total)));

            if (dec_cfg.frm_threads == 1) {
                log_level_1(" Pure  decoding time      = %d msec, fps = %.1f\n",
                    (int)SCALE_TIME(time_decode), ((float)frame_num * 1000) / ((float)SCALE_TIME(time_decode)));
            }
        }
        log_level_1("=========================================================================================\n");
    }

    if(h) libuavs3d_delete(h);
    if(fp_bs) fclose(fp_bs);
    if(bs_buf) free(bs_buf);

#if DYM_LOAD_DYNAMIC_LIBRARY
#if defined(_WIN32)
    FreeLibrary(inst_lib);
#else
    dlclose(inst_lib);
#endif
#endif

    return 0;
}
