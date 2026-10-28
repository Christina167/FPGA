
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/mman.h>

#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "hps_0.h"

/* 与之前成功的 LED 程序保持相同的地址映射方式 */
#define HW_REGS_BASE (ALT_STM_OFST)
#define HW_REGS_SPAN (0x04000000UL)
#define HW_REGS_MASK (HW_REGS_SPAN - 1UL)

/* 实验三：1024 道，每道 32 bit */
#define RAM_CHANNELS 1024U
#define READ_INTERVAL_SECONDS 1U

#ifndef ONCHIP_MEMORY2_0_BASE
#error "ONCHIP_MEMORY2_0_BASE missing in hps_0.h"
#endif

#ifndef ONCHIP_MEMORY2_0_SPAN
#error "ONCHIP_MEMORY2_0_SPAN missing in hps_0.h"
#endif

static volatile sig_atomic_t stop_requested = 0;

static void handle_sigint(int signo)
{
    (void)signo;
    stop_requested = 1;
}

int main(void)
{
    int fd = -1;
    void *virtual_base = MAP_FAILED;
    volatile uint32_t *ram;
    uintptr_t ram_offset;
    unsigned int round = 0;

    /* 检查 RAM 容量是否满足 1024 道要求 */
    if ((uint64_t)ONCHIP_MEMORY2_0_SPAN <
        (uint64_t)RAM_CHANNELS * sizeof(uint32_t)) {

        fprintf(stderr,
                "ERROR: RAM span too small: %lu bytes\n",
                (unsigned long)ONCHIP_MEMORY2_0_SPAN);
        return EXIT_FAILURE;
    }

    /* 根据 Qsys 生成的地址宏计算 RAM 映射偏移 */
    ram_offset =
        ((uintptr_t)ALT_LWFPGASLVS_OFST +
         (uintptr_t)ONCHIP_MEMORY2_0_BASE)
        & (uintptr_t)HW_REGS_MASK;

    if (ram_offset >
        (uintptr_t)HW_REGS_SPAN -
        RAM_CHANNELS * sizeof(uint32_t)) {

        fprintf(stderr, "ERROR: RAM outside mapped region\n");
        return EXIT_FAILURE;
    }

    /* 打开物理内存设备 */
    fd = open("/dev/mem", O_RDWR | O_SYNC);

    if (fd < 0) {
        perror("ERROR: open /dev/mem");
        return EXIT_FAILURE;
    }

    /* 建立 HPS 物理地址到用户空间的映射 */
    virtual_base = mmap(
        NULL,
        HW_REGS_SPAN,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        fd,
        HW_REGS_BASE
    );

    if (virtual_base == MAP_FAILED) {
        perror("ERROR: mmap");
        close(fd);
        return EXIT_FAILURE;
    }

    /* 定位 Qsys On-Chip RAM 的首地址 */
    ram = (volatile uint32_t *)
        ((uint8_t *)virtual_base + ram_offset);

    signal(SIGINT, handle_sigint);

    printf("FPGA spectrum reader started.\n");
    printf("RAM: %u channels x 32 bit\n", RAM_CHANNELS);
    printf("RAM span: %lu bytes\n",
           (unsigned long)ONCHIP_MEMORY2_0_SPAN);

    printf("RAM offset: 0x%08lX\n",
           (unsigned long)ONCHIP_MEMORY2_0_BASE);

    printf("HPS physical address: 0x%08lX\n",
           (unsigned long)
           ((uintptr_t)ALT_LWFPGASLVS_OFST +
            (uintptr_t)ONCHIP_MEMORY2_0_BASE));

    printf("KEY1: start, KEY2: pause, KEY3: clear\n");
    printf("Press Ctrl+C to exit.\n");

    /* 每秒读取一次完整的 1024 道能谱 */
    while (!stop_requested) {

        unsigned int i;
        unsigned int nonzero = 0;
        unsigned int peak_channel = 0;

        uint32_t peak_count = 0;
        uint64_t total = 0;

        ++round;

        printf("\n========== Spectrum #%u ==========\n",
               round);
        printf("Channel      Counts\n");

        for (i = 0; i < RAM_CHANNELS; ++i) {

            uint32_t value = ram[i];

            total += (uint64_t)value;

            /* 仅打印非零能道 */
            if (value != 0U) {
                printf("%4u         %10" PRIu32 "\n",
                       i, value);
                ++nonzero;
            }

            /* 寻找计数最高的能道 */
            if (value > peak_count) {
                peak_count = value;
                peak_channel = i;
            }
        }

        if (nonzero == 0U) {
            puts("All channels are zero.");
        }

        printf("Nonzero channels : %u\n", nonzero);
        printf("Total counts     : %" PRIu64 "\n", total);
        printf("Peak channel     : %u (count=%" PRIu32 ")\n",
               peak_channel, peak_count);

        fflush(stdout);

        if (!stop_requested) {
            sleep(READ_INTERVAL_SECONDS);
        }
    }

    /* 释放映射和文件描述符 */
    puts("\nStopping RAM reader...");

    if (munmap(virtual_base, HW_REGS_SPAN) != 0) {
        perror("WARNING: munmap");
    }

    close(fd);

    return EXIT_SUCCESS;
}
