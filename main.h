/*
 * main.h
 *
 *  Created on: Oct 21, 2024
 *      Author: forsy
 */

#ifndef MAIN_H_
#define MAIN_H_

#include <stdint.h>
#include <stdio.h>

#if !defined(__SOFT_FP__) && defined(__ARM_FP)
  #warning "FPU is not initialized, but the project is compiling for an FPU. Please initialize the FPU before use."
#endif

// prototypes
void enable_processor_faults(void);
__attribute__((naked)) void init_scheduler_stack(uint32_t sched_top_of_stack);
void init_task_stacks(void);
void init_systick_timer(uint32_t tick_hz);
__attribute__((naked)) void switch_sp_to_psp(void);

void task1_handler(void);
void task2_handler(void);
void task3_handler(void);
void task4_handler(void);
void idle_task(void);
void SysTick_Handler(void);
__attribute__((naked)) void PendSV_Handler(void);

void HardFault_Handler(void);
void MemManage_Handler(void);
void BusFault_Handler(void);

uint32_t get_psp_value(void);
void save_psp_value(uint32_t current_psp_value);
void update_next_task(void);
void task_delay(uint32_t tick_count);
void update_global_tick_count(void);
void unblock_tasks(void);
void schedule(void);

// stack memory calculation information Each stack gets 1kb
#define SIZE_TASK_STACK      	1024U
#define SIZE_SCHED_STACK		1024U
#define MAX_TASKS               5

// SRAM init
#define SRAM_START 				0x20000000U
#define SIZE_SRAM				( (128) * (1024) )
#define SRAM_END				( (SRAM_START) + (SIZE_SRAM) )

// Task stack address spaces (1kb each)
#define T1_STACK_START 			SRAM_END
#define T2_STACK_START			( (SRAM_END) - (SIZE_TASK_STACK) )
#define T3_STACK_START			( (SRAM_END) - ( (2) * (SIZE_TASK_STACK) ) )
#define T4_STACK_START			( (SRAM_END) - ( (3) * (SIZE_TASK_STACK) ) )
#define IDLE_STACK_START		( (SRAM_END) - ( (4) * (SIZE_TASK_STACK) ) )
#define SCHED_STACK_START		( (SRAM_END) - ( (5) * (SIZE_TASK_STACK) ) )

// clock settings
#define TICK_HZ 				1000U
#define HSI_CLOCK				16000000U
#define SYSTICK_TIM_CLK			HSI_CLOCK
#define SYSTICK_RVR				0xE000E014
#define SYSTICK_CSR				0xE000E010

#define DUMMY_XPSR 				0x01000000U

#define TASK_READY_STATE      	0x00
#define TASK_BLOCKED_STATE		0xFF

#define INTERRUPT_DISABLE() 		do{__asm volatile("MOV R0, #0x1"); __asm volatile("MSR PRIMASK, R0");} while(0)
#define INTERRUPT_ENABLE() 		do{__asm volatile("MOV R0, #0x0"); __asm volatile("MSR PRIMASK, R0");} while(0)

// global variables
uint8_t current_task = 1;      // 1 represents task 1 (0 is idle task)
uint32_t global_tick_count = 0;


/*TCB: Task Control Block*/
typedef struct
{
	uint32_t psp_value;      								// contains psp value of tasks stack
	uint32_t block_count;
	uint8_t current_state;									// contains tasks running state
	void (*task_handler)(void);								// holds pointers to task handlers
}TCB_t;

TCB_t user_tasks[MAX_TASKS];

#endif /* MAIN_H_ */
