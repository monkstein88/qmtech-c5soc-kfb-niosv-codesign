/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu' in SOPC Builder design 'niosv_system'
 * SOPC Builder design path: ../../qsys/niosv_system.sopcinfo
 *
 * Generated: Sun Oct 11 23:56:09 EEST 2026
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "intel_niosv_g"
#define ALT_CPU_CLIC_EN 0
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_DATA_ADDR_WIDTH 0x20
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HAS_CSR_SUPPORT 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x20
#define ALT_CPU_INT_MODE 1
#define ALT_CPU_MTIME_OFFSET 0x00038000
#define ALT_CPU_NAME "cpu"
#define ALT_CPU_NIOSV_CORE_VARIANT 3
#define ALT_CPU_NUM_GPR 32
#define ALT_CPU_NUM_SRF_BANKS 2
#define ALT_CPU_RESET_ADDR 0x00000000
#define ALT_CPU_TICKS_PER_SEC NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND
#define ALT_CPU_TIMER_DEVICE_TYPE 2


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define BANTAMLAKE_CLIC_EN 0
#define BANTAMLAKE_CPU_FREQ 100000000u
#define BANTAMLAKE_DATA_ADDR_WIDTH 0x20
#define BANTAMLAKE_DCACHE_LINE_SIZE 32
#define BANTAMLAKE_DCACHE_LINE_SIZE_LOG2 5
#define BANTAMLAKE_DCACHE_SIZE 0
#define BANTAMLAKE_HAS_CSR_SUPPORT 1
#define BANTAMLAKE_HAS_DEBUG_STUB
#define BANTAMLAKE_ICACHE_LINE_SIZE 32
#define BANTAMLAKE_ICACHE_LINE_SIZE_LOG2 5
#define BANTAMLAKE_ICACHE_SIZE 0
#define BANTAMLAKE_INST_ADDR_WIDTH 0x20
#define BANTAMLAKE_INT_MODE 1
#define BANTAMLAKE_MTIME_OFFSET 0x00038000
#define BANTAMLAKE_NIOSV_CORE_VARIANT 3
#define BANTAMLAKE_NUM_GPR 32
#define BANTAMLAKE_NUM_SRF_BANKS 2
#define BANTAMLAKE_RESET_ADDR 0x00000000
#define BANTAMLAKE_TICKS_PER_SEC NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND
#define BANTAMLAKE_TIMER_DEVICE_TYPE 2


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_PIO
#define __ALTSYNCRAM
#define __INTEL_NIOSV_G


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone V"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x38070
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x38070
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x38070
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "niosv_system"
#define ALT_SYS_CLK_TICKS_PER_SEC ALT_CPU_TICKS_PER_SEC
#define ALT_TIMESTAMP_CLK_TIMER_DEVICE_TYPE ALT_CPU_TIMER_DEVICE_TYPE


/*
 * cpu_dm_agent configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_dm_agent intel_niosv_g
#define CPU_DM_AGENT_BASE 0x20000
#define CPU_DM_AGENT_CLIC_EN 0
#define CPU_DM_AGENT_CPU_FREQ 100000000u
#define CPU_DM_AGENT_DATA_ADDR_WIDTH 0x20
#define CPU_DM_AGENT_DCACHE_LINE_SIZE 32
#define CPU_DM_AGENT_DCACHE_LINE_SIZE_LOG2 5
#define CPU_DM_AGENT_DCACHE_SIZE 0
#define CPU_DM_AGENT_HAS_CSR_SUPPORT 1
#define CPU_DM_AGENT_HAS_DEBUG_STUB
#define CPU_DM_AGENT_ICACHE_LINE_SIZE 32
#define CPU_DM_AGENT_ICACHE_LINE_SIZE_LOG2 5
#define CPU_DM_AGENT_ICACHE_SIZE 0
#define CPU_DM_AGENT_INST_ADDR_WIDTH 0x20
#define CPU_DM_AGENT_INTERRUPT_CONTROLLER_ID 0
#define CPU_DM_AGENT_INT_MODE 1
#define CPU_DM_AGENT_IRQ -1
#define CPU_DM_AGENT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_DM_AGENT_MTIME_OFFSET 0x00038000
#define CPU_DM_AGENT_NAME "/dev/cpu_dm_agent"
#define CPU_DM_AGENT_NIOSV_CORE_VARIANT 3
#define CPU_DM_AGENT_NUM_GPR 32
#define CPU_DM_AGENT_NUM_SRF_BANKS 2
#define CPU_DM_AGENT_RESET_ADDR 0x00000000
#define CPU_DM_AGENT_SPAN 65536
#define CPU_DM_AGENT_TICKS_PER_SEC NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND
#define CPU_DM_AGENT_TIMER_DEVICE_TYPE 2
#define CPU_DM_AGENT_TYPE "intel_niosv_g"


/*
 * cpu_timer_sw_agent configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_timer_sw_agent intel_niosv_g
#define CPU_TIMER_SW_AGENT_BASE 0x38000
#define CPU_TIMER_SW_AGENT_CLIC_EN 0
#define CPU_TIMER_SW_AGENT_CPU_FREQ 100000000u
#define CPU_TIMER_SW_AGENT_DATA_ADDR_WIDTH 0x20
#define CPU_TIMER_SW_AGENT_DCACHE_LINE_SIZE 32
#define CPU_TIMER_SW_AGENT_DCACHE_LINE_SIZE_LOG2 5
#define CPU_TIMER_SW_AGENT_DCACHE_SIZE 0
#define CPU_TIMER_SW_AGENT_HAS_CSR_SUPPORT 1
#define CPU_TIMER_SW_AGENT_HAS_DEBUG_STUB
#define CPU_TIMER_SW_AGENT_ICACHE_LINE_SIZE 32
#define CPU_TIMER_SW_AGENT_ICACHE_LINE_SIZE_LOG2 5
#define CPU_TIMER_SW_AGENT_ICACHE_SIZE 0
#define CPU_TIMER_SW_AGENT_INST_ADDR_WIDTH 0x20
#define CPU_TIMER_SW_AGENT_INTERRUPT_CONTROLLER_ID 0
#define CPU_TIMER_SW_AGENT_INT_MODE 1
#define CPU_TIMER_SW_AGENT_IRQ -1
#define CPU_TIMER_SW_AGENT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_TIMER_SW_AGENT_MTIME_OFFSET 0x00038000
#define CPU_TIMER_SW_AGENT_NAME "/dev/cpu_timer_sw_agent"
#define CPU_TIMER_SW_AGENT_NIOSV_CORE_VARIANT 3
#define CPU_TIMER_SW_AGENT_NUM_GPR 32
#define CPU_TIMER_SW_AGENT_NUM_SRF_BANKS 2
#define CPU_TIMER_SW_AGENT_RESET_ADDR 0x00000000
#define CPU_TIMER_SW_AGENT_SPAN 64
#define CPU_TIMER_SW_AGENT_TICKS_PER_SEC NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND
#define CPU_TIMER_SW_AGENT_TIMER_DEVICE_TYPE 2
#define CPU_TIMER_SW_AGENT_TYPE "intel_niosv_g"


/*
 * hal2 configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK CPU
#define ALT_TIMESTAMP_CLK CPU
#define INTEL_FPGA_DFL_START_ADDRESS 0xffffffffffffffff
#define INTEL_FPGA_USE_DFL_WALKER 0


/*
 * intel_niosv_g_hal_driver configuration
 *
 */

#define NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND 1000


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x38070
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 1024
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 1024
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * niosvdtcm1 configuration
 *
 */

#define ALT_MODULE_CLASS_niosvdtcm1 altsyncram
#define NIOSVDTCM1_BASE 0x20000000
#define NIOSVDTCM1_IRQ -1
#define NIOSVDTCM1_IRQ_INTERRUPT_CONTROLLER_ID -1
#define NIOSVDTCM1_NAME "/dev/niosvdtcm1"
#define NIOSVDTCM1_SPAN 32768
#define NIOSVDTCM1_TYPE "altsyncram"


/*
 * niosvitcm1 configuration
 *
 */

#define ALT_MODULE_CLASS_niosvitcm1 altsyncram
#define NIOSVITCM1_BASE 0x0
#define NIOSVITCM1_IRQ -1
#define NIOSVITCM1_IRQ_INTERRUPT_CONTROLLER_ID -1
#define NIOSVITCM1_NAME "/dev/niosvitcm1"
#define NIOSVITCM1_SPAN 131072
#define NIOSVITCM1_TYPE "altsyncram"


/*
 * pio_button configuration
 *
 */

#define ALT_MODULE_CLASS_pio_button altera_avalon_pio
#define PIO_BUTTON_BASE 0x38050
#define PIO_BUTTON_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BUTTON_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BUTTON_CAPTURE 0
#define PIO_BUTTON_DATA_WIDTH 2
#define PIO_BUTTON_DO_TEST_BENCH_WIRING 0
#define PIO_BUTTON_DRIVEN_SIM_VALUE 0
#define PIO_BUTTON_EDGE_TYPE "NONE"
#define PIO_BUTTON_FREQ 100000000
#define PIO_BUTTON_HAS_IN 1
#define PIO_BUTTON_HAS_OUT 0
#define PIO_BUTTON_HAS_TRI 0
#define PIO_BUTTON_IRQ -1
#define PIO_BUTTON_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BUTTON_IRQ_TYPE "NONE"
#define PIO_BUTTON_NAME "/dev/pio_button"
#define PIO_BUTTON_RESET_VALUE 0
#define PIO_BUTTON_SPAN 16
#define PIO_BUTTON_TYPE "altera_avalon_pio"


/*
 * pio_dipsw configuration
 *
 */

#define ALT_MODULE_CLASS_pio_dipsw altera_avalon_pio
#define PIO_DIPSW_BASE 0x38040
#define PIO_DIPSW_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_DIPSW_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_DIPSW_CAPTURE 0
#define PIO_DIPSW_DATA_WIDTH 4
#define PIO_DIPSW_DO_TEST_BENCH_WIRING 0
#define PIO_DIPSW_DRIVEN_SIM_VALUE 0
#define PIO_DIPSW_EDGE_TYPE "NONE"
#define PIO_DIPSW_FREQ 100000000
#define PIO_DIPSW_HAS_IN 1
#define PIO_DIPSW_HAS_OUT 0
#define PIO_DIPSW_HAS_TRI 0
#define PIO_DIPSW_IRQ -1
#define PIO_DIPSW_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_DIPSW_IRQ_TYPE "NONE"
#define PIO_DIPSW_NAME "/dev/pio_dipsw"
#define PIO_DIPSW_RESET_VALUE 0
#define PIO_DIPSW_SPAN 16
#define PIO_DIPSW_TYPE "altera_avalon_pio"


/*
 * pio_led configuration
 *
 */

#define ALT_MODULE_CLASS_pio_led altera_avalon_pio
#define PIO_LED_BASE 0x38060
#define PIO_LED_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LED_CAPTURE 0
#define PIO_LED_DATA_WIDTH 1
#define PIO_LED_DO_TEST_BENCH_WIRING 0
#define PIO_LED_DRIVEN_SIM_VALUE 0
#define PIO_LED_EDGE_TYPE "NONE"
#define PIO_LED_FREQ 100000000
#define PIO_LED_HAS_IN 0
#define PIO_LED_HAS_OUT 1
#define PIO_LED_HAS_TRI 0
#define PIO_LED_IRQ -1
#define PIO_LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LED_IRQ_TYPE "NONE"
#define PIO_LED_NAME "/dev/pio_led"
#define PIO_LED_RESET_VALUE 0
#define PIO_LED_SPAN 16
#define PIO_LED_TYPE "altera_avalon_pio"

#endif /* __SYSTEM_H_ */
