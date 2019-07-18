/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include "system.h"
#include <sys/alt_irq.h>
#include <priv/alt_legacy_irq.h>
#include <string.h>
#include <stdio.h>
#include "sha_1.h"

#define STATUS_REG_POS		0
#define START_BIT    		0
#define TEXT_REG_POS		1
#define LENGTH_REG_POS		16

// ### TIMER core ...
#define TIMER_STATUS_REG   0
#define TIMER_CONTROL_REG  1
#define TIMER_LOWER_PERIOD 2
#define TIMER_UPPER_PERIOD 3
#define TIMER_LOWER_SNAPSHOT 4
#define TIMER_UPPER_SNAPSHOT 5

#define TIMER_STOP_BIT  3
#define TIMER_START_BIT 2
#define TIMER_CONT_BIT  1
#define TIMER_ITO_BIT   0
#define TIMER_TO_BIT    0

volatile unsigned int * timer_ptr = (volatile unsigned int *) 0x80009080;
volatile unsigned int *sha_engine_ptr = (volatile unsigned int *) 0x80009000;
volatile unsigned int delay = 0;
unsigned int register_info[22];


void set_timer_period(unsigned int period);
void start_timer();
void stop_timer(void);
unsigned int snapshot_timer();

static void sha_1_hw(void)
{
	  memset(register_info,0,sizeof(register_info));

	  register_info[STATUS_REG_POS] = (1 << START_BIT);
	  register_info[TEXT_REG_POS] 	= (0x61626380);
	  register_info[LENGTH_REG_POS] = (0x18);

	  for(int i = 1; i <= 16; i++)
	  {
		  *(sha_engine_ptr + i) = register_info[i];
		  printf("%08x %08x \n",register_info[i], *(sha_engine_ptr + i));
	  }

	  *(sha_engine_ptr + STATUS_REG_POS) = register_info[STATUS_REG_POS];

	  /* Event loop never exits. */
	  while (!(register_info[STATUS_REG_POS] & 0x2))
	  {
		  register_info[STATUS_REG_POS] = *(sha_engine_ptr + STATUS_REG_POS);
	  }

	  printf("HW Registers:\n");
	  for(int j = 0; j <= 21; j++)
	  {
		  register_info[j] = *(sha_engine_ptr + j);
		  printf("%08x\n",register_info[j]);
	  }
	  printf("\n\n");
}


int main()
{
	unsigned int before_time = 0, after_time = 0;
  alt_putstr("SHA System Alive!\n");

  alt_putstr("SHA Software!\n");
  set_timer_period(0x00024B40);
  start_timer();
  before_time = snapshot_timer();
  sha_1_sw();
  after_time = snapshot_timer();
  stop_timer();
  printf("software timing results: %u\n", before_time - after_time);

  alt_putstr("SHA Hardware!\n");
  set_timer_period(0x00024B40);
  start_timer();
  before_time = snapshot_timer();
  sha_1_hw();
  after_time = snapshot_timer();
  stop_timer();
  printf("hardware timing results: %u\n", before_time - after_time);

  return 0;
}

// ### function implementations ..
void set_timer_period(unsigned int period){
	unsigned short upper_part, lower_part;
	upper_part  = (unsigned short) (period >> 16);
	lower_part  = (unsigned short) (period & 0x0000FFFF);
	// write the period to the respective registers ...
	*(timer_ptr + TIMER_LOWER_PERIOD) = lower_part;
	*(timer_ptr + TIMER_UPPER_PERIOD) = upper_part;
}

void start_timer(){
	*(timer_ptr + TIMER_CONTROL_REG) |= (1 << TIMER_START_BIT) | (1 << TIMER_CONT_BIT) | (1 << TIMER_ITO_BIT);
}
void stop_timer(void){
	*(timer_ptr + TIMER_CONTROL_REG) &= ~(1 << TIMER_STOP_BIT);
}

unsigned int snapshot_timer() {

	unsigned int measure_time = 0;

	measure_time = (*(timer_ptr + TIMER_UPPER_SNAPSHOT) << 16) | (*(timer_ptr + TIMER_LOWER_SNAPSHOT));

	return measure_time;
}
