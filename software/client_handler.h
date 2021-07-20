#ifndef client_handler_h
#define client_handler_h

#include <stdbool.h>
#include "structs.h"
#include "pll.h"

struct client_thread_info {
	int sockfd;
	volatile void *sdram;
	volatile struct logic_analyzer *la;
	volatile struct pll_reconfig *pll_capture;
	volatile struct pll_reconfig *pll_adc;
};

void *client_thread(void *ptr);

#endif
