#include <stdio.h>
#include <stdint.h>
#include <pthread.h>
#include <unistd.h>

#include "pll.h"
#include "client_handler.h"

int read_fully(int fd, void *data, size_t len) {
	size_t processed = 0;
	while(processed < len) {
		ssize_t n = read(fd, (uint8_t *) data + processed, len - processed);
		if(n <= 0) {
			return -1;
		}
		processed += n;
	}
	return 0;
}

int write_fully(int fd, void *data, size_t len) {
	size_t processed = 0;
	while(processed < len) {
		ssize_t n = write(fd, (uint8_t *) data + processed, len - processed);
		if(n <= 0) {
			return -1;
		}
		processed += n;
	}
	return 0;
}

uint64_t magic_version = 0xAE93CF2900000001;

#define CHECK(a) if((a) == -1) goto terminate

void get_status(struct status *stat, volatile struct client_thread_info *info) {
	volatile struct logic_analyzer *la = info->la;

	stat->entry_addr = la->ENTRY_ADDR;
	stat->trig_addr = la->TRIG_ADDR;
	uint32_t info_run = la->INFO_RUN;
	stat->trig_sample = (info_run >> 8) & 0xFF;
	stat->triggered = (info_run >> 16) & 1;
	stat->fill_wrapped = (info_run >> 17) & 1;
	stat->running = (info_run >> 0) & 1;

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

}

void apply_config(struct config_options *opts, volatile struct client_thread_info *info) {
	volatile struct logic_analyzer *la = info->la;

	// Terminate
	la->INFO_RUN = 4;

	// Reset everything
	la->CTRL = 7;

	// Restore clocks to allow register writes
	pll_set_freq(info->pll_capture, 500e6);
	pll_set_freq(info->pll_adc, 40e6);

	// Delay to allow PLLs to lock
	usleep(1000);

	uint8_t num_adc_configs = opts->num_adc_configs;
	if(num_adc_configs >= 1) {
		num_adc_configs--;
	}

	la->TRIG_COND_MATCH = opts->trigger_match;
	la->TRIG_COND_MASK = opts->trigger_mask;
	la->SAMPLE_D_LIMIT = opts->limit_samples >> (8 - (opts->channels & 0x7));
	la->ENTRY_LIMIT = opts->limit_entries;
	la->ADC_CONFIG_1 = 
		((opts->adc_config[0] & 0x1F) <<  0) |
		((opts->adc_config[1] & 0x1F) <<  5) |
		((opts->adc_config[2] & 0x1F) << 10) |
		((opts->adc_config[3] & 0x1F) << 15) |
		((opts->adc_config[4] & 0x1F) << 20) |
		((opts->adc_config[5] & 0x1F) << 25);

	la->ADC_CONFIG_2 = 
		((opts->adc_config[6] & 0x1F) <<  0) |
		((opts->adc_config[7] & 0x1F) <<  5) |
		((num_adc_configs & 7) << 7);

	pll_set_freq(info->pll_capture, opts->sample_rate_digital);
	pll_set_freq(info->pll_adc, opts->sample_rate_analog * 80.0);

	uint32_t ctrl =
		((opts->channels & 0x7) << 16) | 
		((opts->trigger_channel & 0x1F) << 19) | 
		((opts->trigger_mode & 0x7) << 24);

	if(opts->disable_analog) {
		ctrl |= 1 << 2;
	}
	if(opts->disable_digital) {
		ctrl |= 1 << 2;
	}
	la->CTRL = ctrl;
}

void launch(volatile struct client_thread_info *info) {
	info->la->INFO_RUN |= 1 << 1;
}

void terminate(volatile struct client_thread_info *info) {
	info->la->INFO_RUN |= 1 << 2;
}

bool is_running(volatile struct client_thread_info *info) {
	return info->la->INFO_RUN & (1 << 0);
}

void *client_thread(void *ptr) {
	volatile struct client_thread_info *info = (volatile struct client_thread_info *) ptr;
	int sockfd = info->sockfd;

	struct config_options opts;
	struct status stat;

	uint32_t start;
	uint32_t len;

	while(1) {
		uint32_t cmd;
		CHECK(read_fully(sockfd, &cmd, 4));
		switch(cmd) {
			case 0:
				printf("req ident\n");
				// Ident
				CHECK(write_fully(sockfd, &magic_version, 8));
				break;
			case 1:
				printf("req config\n");
				// Configure
				CHECK(read_fully(sockfd, &opts, sizeof(opts)));
				apply_config(&opts, info);
				break;
			case 2:
				printf("req launch\n");
				// Launch
				launch(info);
				break;
			case 3:
				printf("req terminate\n");
				// Terminate
				terminate(info);
				break;
			case 4:
				printf("req status\n");
				// Status
				get_status(&stat, info);
				CHECK(write_fully(sockfd, &stat, sizeof(stat)));
				break;
			case 5:
				printf("req dump\n");
				// Dump memory
				CHECK(read_fully(sockfd, &start, 4));
				CHECK(read_fully(sockfd, &len, 4));
				if(start > 512*1024*1024 || len > 512*1024*1024 || start + len > 512*1024*1024) {
					goto terminate;
				}
				CHECK(write_fully(sockfd, (uint8_t *) info->sdram + start, len));
				break;
		}
	}

terminate:
	close(sockfd);
}
