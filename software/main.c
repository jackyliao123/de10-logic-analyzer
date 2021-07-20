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
#include <pthread.h>
#include <signal.h>

#include "client_handler.h"
#include "pll.h"

int main() {
	signal(SIGPIPE, SIG_IGN);

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

	volatile struct logic_analyzer *la = (volatile struct logic_analyzer *) h2f_lw;
	volatile struct pll_reconfig *pll_capture = (volatile struct pll_reconfig *) ((uint8_t *) h2f_lw + 0x200);
	volatile struct pll_reconfig *pll_adc = (volatile struct pll_reconfig *) ((uint8_t *) h2f_lw + 0x300);

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

//	la->INFO_RUN = 0x00000004;
//	la->CTRL = 0x00050000;
//	la->ENTRY_LIMIT = 0x00010000;
//	la->SAMPLE_D_LIMIT = 0x100000000L;
//	la->INFO_RUN = 0x00000002;
//
//	while(true) {
//		printf("CTRL = %08x\n", la->CTRL);
//		printf("INFO_RUN = %08x\n", la->INFO_RUN);
//		printf("TRIG_COND_MATCH = %08x\n", la->TRIG_COND_MATCH);
//		printf("TRIG_COND_MASK = %08x\n", la->TRIG_COND_MASK);
//		printf("SAMPLE_D_COUNT = %016llx\n", la->SAMPLE_D_COUNT);
//		printf("SAMPLE_D_LIMIT = %016llx\n", la->SAMPLE_D_LIMIT);
//		printf("ENTRY_ADDR = %08x\n", la->ENTRY_ADDR);
//		printf("ENTRY_LIMIT = %08x\n", la->ENTRY_LIMIT);
//		printf("TRIG_ADDR = %08x\n", la->TRIG_ADDR);
//		printf("ADC_CONFIG_1 = %08x\n", la->ADC_CONFIG_1);
//		printf("ADC_CONFIG_2 = %08x\n", la->ADC_CONFIG_2);
//		printf("SAMPLE_A_COUNT = %08x\n", la->SAMPLE_A_COUNT);
//		printf("CLK_CNT_SAMPLE = %d\n", la->CLK_CNT_SAMPLE);
//		printf("CLK_CNT_ADC = %d\n", la->CLK_CNT_ADC);
//		printf("\n");
//		usleep(100000);
//	}

	struct addrinfo hints = {0};
	struct addrinfo *res;
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE;
	if(getaddrinfo("0.0.0.0", "8888", &hints, &res) != 0) {
		return -1;
	}

	int server_sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
	if(server_sockfd == -1) {
		perror("socket");
		return 1;
	}

	if(setsockopt(server_sockfd, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) == -1) {
		perror("setsockopt");
		return 1;
	}

	if(bind(server_sockfd, res->ai_addr, res->ai_addrlen) == -1) {
		perror("connect");
		return 1;
	}

	freeaddrinfo(res);

	if(listen(server_sockfd, 16) == -1) {
		perror("listen");
		return 1;
	}

	bool has_thread = false;
	volatile struct client_thread_info client_info;
	pthread_t thread;

	while(1) {
		int sockfd = accept(server_sockfd, NULL, NULL);
//		if(has_thread) {
//			close(client_info.sockfd);
//			pthread_join(thread, NULL);
//		}
		memset((void *) &client_info, 0, sizeof(client_info));
		client_info.sockfd = sockfd;
		client_info.sdram = sdram;
		client_info.la = la;
		client_info.pll_capture = pll_capture;
		client_info.pll_adc = pll_adc;
		has_thread = true;
		pthread_create(&thread, NULL, client_thread, (void *) &client_info);
	}

	return 0;
}

