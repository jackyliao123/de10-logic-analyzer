#ifndef pll_h
#define pll_h

#include <stdint.h>

struct pll_vals {
	uint16_t N;
	uint16_t M;
	uint16_t C0;
	uint16_t C1;
	uint16_t C2;
	uint16_t C3;
};

struct pll_reconfig {
	uint32_t MODE;       // R/W   Mode Register
	uint32_t STATUS;     // R     Status Register
	uint32_t START;      // W     Start Register
	uint32_t N;          // R/W   N Counter
	uint32_t M;          // R/W   M Counter
	uint32_t C;          // R/W   C Counter
	uint32_t DPS;        // W     Dynamic_Phase_Shift
	uint32_t K;          // W     M Counter Fractional Value(K)
	uint32_t BW;         // R/W   Bandwidth Setting
	uint32_t CP;         // R/W   Charge Pump Setting
	uint32_t C_READ[18]; // R     C counter read
	uint32_t VCO;        // R/W   VCO Post Divide Counter Setting
};

#define PLL_COUNTER_LOW(x) (((x) & 0xFF))
#define PLL_COUNTER_HIGH(x) (((x) & 0xFF) << 8)
#define PLL_COUNTER_BYPASS (1 << 16)
#define PLL_COUNTER_ODD_DIVISION (1 << 17)
#define PLL_C_SELECT(x) (((x) & 0x1F) << 18)
#define PLL_DPS_SHIFT(x) (((x) & 0xFFFF))
#define PLL_DPS_SELECT(x) (((x) & 0x1F) << 16)
#define PLL_DPS_ALL_C_COUNTER (0x1F)
#define PLL_DPS_M_COUNTER (0x12)

void pll_compute_vals(double freq, struct pll_vals *vals);
double pll_compute_freq(struct pll_vals *vals);
uint32_t pll_val_to_counter(uint32_t val);
void pll_apply_config(volatile struct pll_reconfig *pll, struct pll_vals *vals);
double pll_set_freq(volatile struct pll_reconfig *pll, double freq);

#endif
