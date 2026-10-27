
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "hps_0.h"

#define HW_REGS_BASE (ALT_STM_OFST)
#define HW_REGS_SPAN (0x04000000)
#define HW_REGS_MASK (HW_REGS_SPAN - 1)

#define RAM_CHANNELS 64

int main(void)
{
    void *virtual_base;
    volatile uint32_t *ram;
    int fd;
    int i;
    int round = 0;

    fd = open("/dev/mem", O_RDWR | O_SYNC);

    if (fd == -1) {
        perror("open /dev/mem failed");
        return 1;
    }

    virtual_base = mmap(
        NULL,
        HW_REGS_SPAN,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        fd,
        HW_REGS_BASE
    );

    if (virtual_base == MAP_FAILED) {
        perror("mmap failed");
        close(fd);
        return 1;
    }

    ram = (volatile uint32_t *)
        ((char *)virtual_base +
        ((unsigned long)
          (ALT_LWFPGASLVS_OFST + ONCHIP_MEMORY2_0_BASE)
          & (unsigned long)HW_REGS_MASK));

    printf("HPS RAM reader started.\n");

    while (1) {
        int nonzero = 0;

        round++;
        printf("\n第 %d 组读取:\n", round);

        for (i = 0; i < RAM_CHANNELS; i++) {
            uint32_t value = ram[i];

            if (value != 0) {
                printf("address[%02d]: %u\n",
                       i, (unsigned int)value);
                nonzero++;
            }
        }

        if (nonzero == 0) {
            printf("当前所有道址数据均为0\n");
        }

        fflush(stdout);
        sleep(1);
    }

    return 0;
}
