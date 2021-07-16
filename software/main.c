#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sendfile.h>
#include <netdb.h>
#include <fcntl.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "pll.h"

struct logic_analyzer {
	uint32_t CTRL;
	uint32_t INFO_RUN;
	uint32_t TRIG_COND_MATCH;
	uint32_t TRIG_COND_MASK;
	uint64_t SAMPLE_D_COUNT;
	uint64_t SAMPLE_D_LIMIT;
	uint32_t ENTRY_ADDR;
	uint32_t ENTRY_LIMIT;
	uint32_t TRIG_ADDR;
	uint32_t ADC_CONFIG_1;
	uint32_t ADC_CONFIG_2;
	uint32_t SAMPLE_A_COUNT;
	uint32_t CLK_CNT_SAMPLE;
	uint32_t CLK_CNT_ADC;
};

int main() {
	int memfd = open("/dev/mem", O_RDWR | O_SYNC);
	if(memfd == -1) {
		perror("open /dev/mem");
		return 1;
	}
	void *h2f_lw = mmap(NULL, 0x200000, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, 0xFF200000);
	if(!h2f_lw) {
		perror("mmap h2f_lw");
		return 1;
	}

	void *sdram = mmap(NULL, 0x20000000, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, 0x20000000);
	if(!sdram) {
		perror("mmap sdram");
		return 1;
	}

	volatile struct pll_reconfig *pll_capture = (volatile struct pll_reconfig *) ((uint32_t) h2f_lw + 0x200);
	volatile struct pll_reconfig *pll_adc = (volatile struct pll_reconfig *) ((uint32_t) h2f_lw + 0x300);
	volatile struct logic_analyzer *la = (volatile struct logic_analyzer *) h2f_lw;

//  0: Register CTRL (RW)
//     31  - run
// [26:24] - trig mode
//             0 - always
//             1 - never
//             2 - rising edge
//             3 - falling edge
//             4 - both edges
//             5 - high
//             6 - low
// [23:19] - trig channel
// [18:16] - num channels
//      2  - reset adc
//      1  - reset digital frontend
//      0  - reset sdram_iface
//

	la->INFO_RUN = 0x00000004;
	la->CTRL = 0x00050000;
	la->ENTRY_LIMIT = 0x00010000;
	la->SAMPLE_D_LIMIT = 0x100000000L;
	la->INFO_RUN = 0x00000002;

	while(true) {
		printf("CTRL = %08x\n", la->CTRL);
		printf("INFO_RUN = %08x\n", la->INFO_RUN);
		printf("TRIG_COND_MATCH = %08x\n", la->TRIG_COND_MATCH);
		printf("TRIG_COND_MASK = %08x\n", la->TRIG_COND_MASK);
		printf("SAMPLE_D_COUNT = %016llx\n", la->SAMPLE_D_COUNT);
		printf("SAMPLE_D_LIMIT = %016llx\n", la->SAMPLE_D_LIMIT);
		printf("ENTRY_ADDR = %08x\n", la->ENTRY_ADDR);
		printf("ENTRY_LIMIT = %08x\n", la->ENTRY_LIMIT);
		printf("TRIG_ADDR = %08x\n", la->TRIG_ADDR);
		printf("ADC_CONFIG_1 = %08x\n", la->ADC_CONFIG_1);
		printf("ADC_CONFIG_2 = %08x\n", la->ADC_CONFIG_2);
		printf("SAMPLE_A_COUNT = %08x\n", la->SAMPLE_A_COUNT);
		printf("CLK_CNT_SAMPLE = %d\n", la->CLK_CNT_SAMPLE);
		printf("CLK_CNT_ADC = %d\n", la->CLK_CNT_ADC);
		printf("\n");
		usleep(100000);
	}

//	regs[0] = 0;
//	int i;
//	for(i = 0; i < 1000; ++i) {
//		printf("%d\n", regs[6]);
//		usleep(100000);
//	}

//	uint64_t read = *(uint64_t *) regs;
//	*(uint64_t *) regs = 0x0123456789ABCDEF;
//	*(uint64_t *) regs = 0;

//	regs[3] = 0x10000000;
//	int i;
//	for(i = 0; i < 10; ++i) {
//		printf("%08x\n", regs[3]);
//	}

//	printf("%016llx\n", *((uint64_t *) regs + 1));
//	regs[0] = 1;
//	printf("%x\n", regs[0]);

//	memset(h2f_lw, 0x80, 0x200000);
//	memset(h2f, 0x80, 0x3C000000);
//	memset(sdram, 0x80, 0x20000000);

	return 0;

	struct addrinfo hints = {0};
	struct addrinfo *res;
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE;
	if(getaddrinfo("10.42.0.1", "8888", &hints, &res) != 0) {
		return -1;
	}

	int sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
	if(sockfd == -1) {
		perror("socket");
		return 1;
	}

	if(connect(sockfd, res->ai_addr, res->ai_addrlen) == -1) {
		perror("connect");
		return 1;
	}

	uint32_t len = 0x20000000;
	uint32_t offset = 0;
	ssize_t n;

	// 26 MiB/s
	while((n = write(sockfd, ((uint8_t *) sdram) + offset, len - offset)) > 0) {
		offset += n;
	}

	if(n == -1) {
		perror("write");
		return 1;
	}

	return 0;
}

