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

volatile unsigned int *sha_engine_ptr = (volatile unsigned int *) 0x80009000;
volatile unsigned int delay = 0;

int main()
{ 
  alt_putstr("Hello from Nios II!\n");

  /* Event loop never exits. */
  while (1);

  return 0;
}



#define LED_FADING

#if (defined(LED_BLINKING))
#include "system.h"
#include "sys/alt_stdio.h"

volatile unsigned int *led_ptr = (volatile unsigned int *) 0x80009030;
volatile unsigned int delay = 0;

int main()
{
	unsigned char led_byte = 0x00;
	alt_putstr("System Alive!\n");

	while (1)
	{
		*led_ptr = led_byte++;
		for (delay = 0; delay < 25000; delay++);
	}

	return 0;
}
#elif (defined(LED_FADING))

#include "system.h"
#include <sys/alt_irq.h>
#include <priv/alt_legacy_irq.h>


// ### TIMER core ...
#define TIMER_STATUS_REG   0
#define TIMER_CONTROL_REG  1
#define TIMER_LOWER_PERIOD 2
#define TIMER_UPPER_PERIOD 3

#define TIMER_STOP_BIT  3
#define TIMER_START_BIT 2
#define TIMER_CONT_BIT  1
#define TIMER_ITO_BIT   0
#define TIMER_TO_BIT    0

#define TIMER_IRQ_ID    1

//### PWM core ...
#define PWM_CTRL_REG   0
#define PWM_CONFIG_REG 1

#define PWM_ENABLE	   0

// SET THE CORRESPONDING ADDRESSES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

volatile unsigned int * pwm_ptr   = (volatile unsigned int *) 0x80009040;
volatile unsigned int * timer_ptr = (volatile unsigned int *) 0x80009000;
volatile unsigned int * led_ptr   = (volatile unsigned int *) 0x80009020;

// #### some function prototypes ...

void set_timer_period(unsigned int period);
void start_timer();
void stop_timer(void);

static void timer_irq(void *context, alt_u32 id) __attribute__ ((section (".exceptions")));

// 9-bit values ...
const unsigned short int pwm_values[256]  = {
		0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5,
		5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11,
		11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 19, 19, 19,
		20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 29, 29, 30, 31, 31, 32, 33, 33, 34, 35, 36,
		36, 37, 38, 39, 40, 41, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 56, 57, 59, 60, 61, 63, 64, 65,
		67, 68, 70, 71, 73, 74, 76, 78, 79, 81, 83, 85, 87, 89, 91, 92, 95, 97, 99, 101, 103, 105, 108, 110, 112, 115,
		117, 120, 123, 125, 128, 131, 134, 137, 140, 143, 146, 149, 152, 156, 159, 162, 166, 170, 173, 177, 181, 185, 189,
		193, 197, 202, 206, 211, 215, 220, 225, 230, 235, 240, 245, 252, 256
};

int main(void){

	// enable pwm unit ...
	*(pwm_ptr + PWM_CTRL_REG) = (1 << PWM_ENABLE);

	alt_irq_register(TIMER_IRQ_ID,0,(void *) timer_irq);
	set_timer_period(0x00024B40);
	start_timer();

	while(1){
		// do nothing ...
	}
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

static void timer_irq(void *context, alt_u32 id) {
	static unsigned char pwm_index = 0, direction = 0;
	// clear to flag ...
	*(timer_ptr + TIMER_STATUS_REG) &= ~(1 << TIMER_TO_BIT);
	// ...
	if(direction == 0){
		if(pwm_index == 255){
			pwm_index--;
			direction = 1;
		}
		else
			pwm_index++;
	} else {
		if(pwm_index == 0){
			pwm_index++;
			direction = 0;
		}
		else
			pwm_index--;
	}

	*(pwm_ptr + PWM_CONFIG_REG) = pwm_values[pwm_index];
}

#endif
