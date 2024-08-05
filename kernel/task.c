#include "stdint.h"
#include "stdbool.h"

#include "ARMv7AR.h"
#include "task.h"

static KernelTcb_t sTask_list[MAX_TASK_NUM];
static uint32_t    sAllocated_tcb_index;
static uint32_t    sCurrent_tcb_index;
static KernelTcb_t* Scheduler_round_robin_algorithm(void);

void Kernel_task_init(void)
{
    sAllocated_tcb_index = 0;

    for(uint32_t i = 0 ; i < MAX_TASK_NUM; i ++)
    {
        sTask_list[i].stack_base = (uint8_t*)(TASK_STACK_START + i * USR_TASK_STACK_SIZE);
        sTask_list[i].sp = (uint32_t)sTask_list[i].stack_base + USR_TASK_STACK_SIZE -4; /* Task간 경계를 나타내기 위해 4바이트를 비웠음. */

        sTask_list[i].sp -= sizeof(KernelTaskContext_t);
        KernelTaskContext_t* ctx = (KernelTaskContext_t*)sTask_list[i].sp;
        ctx->pc = 0;
        ctx->spsr = ARM_MODE_BIT_SYS;
    }
}

uint32_t Kernel_task_create(KernelTaskFunc_t startFunc)
{
    KernelTcb_t* new_tcb = &sTask_list[sAllocated_tcb_index++]; /* 스택은 top 주소 번지에서 bottom으로 내려오는 구조이기때문에 1을 더한다. */

    if(sAllocated_tcb_index > MAX_TASK_NUM)
    {
        return NOT_ENOUGH_TASK_NUM;
    }

    KernelTaskContext_t* ctx = (KernelTaskContext_t*)new_tcb->sp; /* 새로 만든 task의 컨텍스트를 task의 스택에 저장하기 위함. */

    return (sAllocated_tcb_index - 1); /* 인덱스는 0번부터이기 때문에 1을 뺀다. */
}

KernelTcb_t* Scheduler_round_robin_algorithm(void)
{
    sCurrent_tcb_index++;
    sCurrent_tcb_index %= sAllocated_tcb_index; /* 나머지 연산을 사용하여 sCurrent_tcb_index가 sAllocated_tcb_index를 넘지 않게 한다. */

    return &sTask_list[sCurrent_tcb_index];
}