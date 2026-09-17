/*
 * Bring-up firmware for the FPGA-side Nios V/g on the QMTECH Cyclone V SoC
 * KFB board.  It runs from the instruction/data TCMs, so it starts as soon as
 * the FPGA is configured, without the HPS or its DDR3 memory.
 *
 * - The user LED blinks with a half period of 500 ms / (DIPSW + 1): 1 Hz with
 *   all switches off, faster as the switch value increases.
 * - Holding KEY[0] forces the LED on; holding KEY[1] forces it off.
 * - Switch and button changes are reported on the JTAG UART.
 */

#include <stdio.h>
#include <unistd.h>

#include "altera_avalon_pio_regs.h"
#include "sys/alt_alarm.h"
#include "system.h"

#define DIPSW_MASK   0xFu
#define KEY_MASK     0x3u
#define KEY0_PRESSED 0x1u
#define KEY1_PRESSED 0x2u

#define POLL_PERIOD_US 10000u /* input polling period: 10 ms */

static unsigned read_dipsw(void)
{
    return IORD_ALTERA_AVALON_PIO_DATA(PIO_DIPSW_BASE) & DIPSW_MASK;
}

/* The buttons are active-low; return a bit mask of the pressed buttons. */
static unsigned read_keys_pressed(void)
{
    return ~IORD_ALTERA_AVALON_PIO_DATA(PIO_BUTTON_BASE) & KEY_MASK;
}

static void report_inputs(unsigned dipsw, unsigned keys)
{
    printf("DIPSW=0x%X KEY0=%s KEY1=%s\n", dipsw,
           (keys & KEY0_PRESSED) ? "pressed" : "released",
           (keys & KEY1_PRESSED) ? "pressed" : "released");
}

int main(void)
{
    unsigned dipsw = read_dipsw();
    unsigned keys = read_keys_pressed();
    unsigned blink = 0;
    alt_u64 last_toggle = alt_nticks();

    printf("\nQMTECH C5SOC KFB: Nios V/g control processor running\n");
    report_inputs(dipsw, keys);

    for (;;) {
        unsigned new_dipsw = read_dipsw();
        unsigned new_keys = read_keys_pressed();

        if (new_dipsw != dipsw || new_keys != keys) {
            dipsw = new_dipsw;
            keys = new_keys;
            report_inputs(dipsw, keys);
        }

        alt_u32 half_period = (alt_ticks_per_second() / 2u) / (dipsw + 1u);
        if (half_period == 0u) {
            half_period = 1u;
        }

        alt_u64 now = alt_nticks();
        if (now - last_toggle >= half_period) {
            blink ^= 1u;
            last_toggle = now;
        }

        unsigned led = blink;
        if (keys & KEY0_PRESSED) {
            led = 1u;
        } else if (keys & KEY1_PRESSED) {
            led = 0u;
        }
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, led);

        usleep(POLL_PERIOD_US);
    }

    return 0;
}
