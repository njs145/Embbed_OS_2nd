#include "stdbool.h"
#include "stdint.h"
#include "HalInterrupt.h"

/* IRQ가 발생하면 자동으로 Irq_Handler로 점프하게 됨. */
__attribute__ ((interrupt ("IRQ"))) void Irq_Handler(void)
{
    Hal_interrupt_run_handler();
}

__attribute__ ((interrupt ("FIQ"))) void Fiq_Handler(void)
{
    while(true);
}