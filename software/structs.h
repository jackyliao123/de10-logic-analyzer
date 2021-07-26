#ifndef structs_h
#define structs_h

struct __attribute__((packed)) config_options {
	uint64_t limit_samples;
	uint32_t limit_entries;
	double sample_rate_digital;
	double sample_rate_analog;
	uint32_t trigger_mask;
	uint32_t trigger_match;
	uint8_t channels; // actual channels = 2^channels
	uint8_t trigger_channel;
	uint8_t trigger_mode;
	uint8_t disable_analog;
	uint8_t disable_digital;
	uint8_t num_adc_configs;
	uint8_t adc_config[8];
};

struct __attribute__((packed)) status {
	uint32_t entry_addr;
	uint32_t trig_addr;
	uint8_t trig_sample;
	uint8_t triggered;
	uint8_t fill_wrapped;
	uint8_t running;
};

struct __attribute__((packed, aligned(4))) logic_analyzer {
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



#endif
