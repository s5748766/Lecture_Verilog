#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#pragma pack(push,1)
typedef struct { uint16_t bfType; uint32_t bfSize; uint16_t bfReserved1; uint16_t bfReserved2; uint32_t bfOffBits; } BMPFILEHDR;
typedef struct { uint32_t biSize; int32_t biWidth; int32_t biHeight; uint16_t biPlanes; uint16_t biBitCount; uint32_t biCompression; uint32_t biSizeImage; int32_t biXPelsPerMeter; int32_t biYPelsPerMeter; uint32_t biClrUsed; uint32_t biClrImportant; } BMPINFOHDR;
typedef struct { uint8_t b,g,r; } BGR;
#pragma pack(pop)

#define W 630
#define H 630
#define NPIX (W*H)

static inline uint8_t clamp8(int v){ if(v<0) return 0; if(v>255) return 255; return (uint8_t)v; }
static inline int IDX(int x,int y){ if(x<0) x=0; if(x>=W) x=W-1; if(y<0) y=0; if(y>=H) y=H-1; return y*W+x; }
static inline int iabs(int v){ return v<0 ? -v : v; }

static int load_bmp_24_to_gray(const char* path, uint8_t* gray){
    FILE* fp=NULL;
#ifdef _MSC_VER
    if(fopen_s(&fp,path,"rb")!=0) fp=NULL;
#else
    fp=fopen(path,"rb");
#endif
    if(!fp){ printf("Cannot open input BMP: %s\n", path); return 0; }
    BMPFILEHDR fh; BMPINFOHDR ih;
    fread(&fh,sizeof(fh),1,fp);
    fread(&ih,sizeof(ih),1,fp);
    if(fh.bfType!=0x4D42 || ih.biBitCount!=24 || ih.biWidth!=W || ih.biHeight!=H){
        printf("Need 24bpp %dx%d BMP.\n", W,H);
        fclose(fp); return 0;
    }
    int pad = (4 - ((W*3) % 4)) % 4;
    fseek(fp, fh.bfOffBits, SEEK_SET);
    for(int y=H-1;y>=0;y--){
        for(int x=0;x<W;x++){
            BGR px; fread(&px,sizeof(px),1,fp);
            int Y = (int)(0.299*px.r + 0.587*px.g + 0.114*px.b + 0.5);
            gray[y*W+x] = clamp8(Y);
        }
        fseek(fp,pad,SEEK_CUR);
    }
    fclose(fp); return 1;
}

static int save_bmp_gray(const char* path, const uint8_t* img){
    FILE* fp=NULL;
#ifdef _MSC_VER
    if(fopen_s(&fp,path,"wb")!=0) fp=NULL;
#else
    fp=fopen(path,"wb");
#endif
    if(!fp){ printf("Cannot write BMP: %s\n", path); return 0; }
    int pad = (4 - (W % 4)) % 4;
    int row = W + pad;
    int palsz=256*4;
    BMPFILEHDR fh={0}; BMPINFOHDR ih={0};
    fh.bfType=0x4D42;
    fh.bfOffBits=sizeof(fh)+sizeof(ih)+palsz;
    fh.bfSize=fh.bfOffBits + row*H;
    ih.biSize=40; ih.biWidth=W; ih.biHeight=H; ih.biPlanes=1; ih.biBitCount=8; ih.biCompression=0;
    ih.biSizeImage=row*H; ih.biClrUsed=256; ih.biClrImportant=256;
    fwrite(&fh,sizeof(fh),1,fp); fwrite(&ih,sizeof(ih),1,fp);
    for(int i=0;i<256;i++){ uint8_t pal[4]={i,i,i,0}; fwrite(pal,4,1,fp); }
    uint8_t padb[4]={0};
    for(int y=H-1;y>=0;y--){
        fwrite(&img[y*W],1,W,fp);
        if(pad) fwrite(padb,1,pad,fp);
    }
    fclose(fp); return 1;
}

static int save_mem(const char* path, const uint8_t* img){
    FILE* fp=NULL;
#ifdef _MSC_VER
    if(fopen_s(&fp,path,"wb")!=0) fp=NULL;
#else
    fp=fopen(path,"wb");
#endif
    if(!fp){ printf("Cannot write MEM: %s\n", path); return 0; }
    for(int i=0;i<NPIX;i++){
        char buf[6]; sprintf(buf,"%02X\r\n", img[i]); fwrite(buf,1,4,fp);
    }
    fclose(fp); return 1;
}

static void roberts2x2(const uint8_t* src, uint8_t* dst){
    for(int y=0;y<H;y++){
        for(int x=0;x<W;x++){
            int gx = (int)src[IDX(x,  y  )] - (int)src[IDX(x+1,y+1)];
            int gy = (int)src[IDX(x+1,y  )] - (int)src[IDX(x,  y+1)];
            int mag = iabs(gx) + iabs(gy);
            if(mag>255) mag=255;
            dst[y*W+x] = (uint8_t)mag;
        }
    }
}

static void usage(const char* exe){
    printf("Usage: %s [--in brainct_001.bmp] [--outdir .]\n", exe);
}

int main(int argc, char** argv){
    const char* inbmp="brainct_001.bmp";
    const char* outdir=".";

    for(int i=1;i<argc;i++){
        if(strcmp(argv[i],"--in")==0 && i+1<argc) inbmp=argv[++i];
        else if(strcmp(argv[i],"--outdir")==0 && i+1<argc) outdir=argv[++i];
        else if(strcmp(argv[i],"--help")==0){ usage(argv[0]); return 0; }
    }

    uint8_t* gray=(uint8_t*)malloc(NPIX);
    uint8_t* out =(uint8_t*)malloc(NPIX);
    if(!gray||!out){ printf("OOM\n"); return 1; }

    if(!load_bmp_24_to_gray(inbmp, gray)) return 1;
    roberts2x2(gray,out);

    char gpath[512], bpath[512], mpath[512];
    snprintf(gpath,sizeof(gpath), "%s/../../output_grayscale-c.bmp", outdir);
    snprintf(bpath,sizeof(bpath), "%s/../../output_roberts-c.bmp", outdir);
    snprintf(mpath,sizeof(mpath), "%s/../../output_roberts-c.mem", outdir);
    save_bmp_gray(gpath, gray);
    save_bmp_gray(bpath, out);
    save_mem(mpath, out);

    free(gray); free(out);
    printf("Done C: roberts\n");
    return 0;
}
