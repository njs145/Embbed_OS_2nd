#include "stdint.h"
#include "UART.h"
#include "HalUART.h"
#include "HalInterrupt.h"

extern volatile PL011_t* Uart;

static void interrupt_handler(void)
{
    uint8_t ch = Hal_uart_get_char();
    Hal_uart_put_char(ch);
}

void Hal_uart_init(void)
{
    // Enable Uart
    Uart->uartcr.bits.UARTEN = 0;
    Uart->uartcr.bits.TXE = 1;
    Uart->uartcr.bits.RXE = 1;
    Uart->uartcr.bits.UARTEN = 1;

    Uart->uartimsc.bits.RXIM = 1;

    Hal_interrupt_enable(UART_INTERRUPT0);
    Hal_interrupt_register_handler(interrupt_handler, UART_INTERRUPT0);
}

void Hal_uart_put_char(uint8_t ch)
{
    while(Uart->uartfr.bits.TXFF);
    Uart->uartdr.all = (ch & 0xFF);
}

uint8_t Hal_uart_get_char(void)
{
    uint8_t data;

    while(Uart->uartfr.bits.RXFE);

    data = Uart->uartdr.all;
    // Check for an error flag
    if (data & 0xFFFFFF00)
    {
        Uart->uartrsr.all = 0xF;
        return 0;
    }

    return (uint8_t)(data & 0xFF);
}
