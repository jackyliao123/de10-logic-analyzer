#include <stdio.h>
#include <stdint.h>

#include "pll.h"

uint32_t clamp(uint32_t val, uint32_t min, uint32_t max) {
	if(val < min) {
		return min;
	} else if(val > max) {
		return max;
	} else {
		return val;
	}
}

double fabs(double val) {
	return val < 0 ? -val : val;
}

void pll_compute_vals(double freq, struct pll_vals *vals) {
	vals->C0 = vals->C1 = vals->C2 = vals->C3 = 1;
	if(freq < 800e3) {
		vals->C0 = 500;
		freq *= 500;
	}
	if(freq < 800e3) {
		vals->C1 = 500;
		freq *= 500;
	}
	if(freq < 800e3) {
		vals->C2 = 500;
		freq *= 500;
	}

	uint32_t m = 80;
	uint32_t c = 1;
	uint32_t best_m = 1;
	uint32_t best_c = 1;
	double best_diff = 1.0 / 0.0;

	while(m <= 250 && c <= 512) {
		double comp = 5e6 * m / c;
		if(fabs(comp - freq) < best_diff) {
			best_diff = fabs(comp - freq);
			best_m = m;
			best_c = c;
		}
		if(comp < freq) {
			m++;
		} else {
			c++;
		}
	}

	vals->C3 = clamp(best_c, 1, 512);
	vals->N = 10;
	vals->M = clamp(best_m, 80, 250);
}

double pll_compute_freq(struct pll_vals *vals) {
	return 50e6 * vals->M / vals->N / vals->C0 / vals->C1 / vals->C2 / vals->C3;
}

uint32_t pll_val_to_counter(uint32_t val) {
	if(val == 1) {
		return PLL_COUNTER_BYPASS;
	}
	uint32_t reg = 0;
	if(val & 1) {
		reg |= PLL_COUNTER_ODD_DIVISION;
	}
	uint32_t half = val >> 1;
	reg |= PLL_COUNTER_LOW(half) | PLL_COUNTER_HIGH(val - half);
	return reg;
}

void pll_apply_config(volatile struct pll_reconfig *pll, struct pll_vals *vals) {
	pll->START = 1;
	pll->M = pll_val_to_counter(vals->M);
	pll->N = pll_val_to_counter(vals->N);
	pll->C = pll_val_to_counter(vals->C0) | PLL_C_SELECT(0);
	pll->C = pll_val_to_counter(vals->C1) | PLL_C_SELECT(1);
	pll->C = pll_val_to_counter(vals->C2) | PLL_C_SELECT(2);
	pll->C = pll_val_to_counter(vals->C3) | PLL_C_SELECT(3);
	pll->START = 0;
}

double pll_set_freq(volatile struct pll_reconfig *pll, double freq) {
	struct pll_vals vals;
	pll_compute_vals(freq, &vals);
	double actual_freq = pll_compute_freq(&vals);
	pll_apply_config(pll, &vals);
	printf("pll_set_freq %p, requested = %lf, actual = %lf\n", pll, freq, actual_freq);
	return actual_freq;
}
