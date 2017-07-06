#target remote 172.23.6.202:2331
#target remote 172.23.6.201:2331
#target remote 172.23.4.57:2331
target remote 192.168.17.125:2331
#target remote 192.168.64.128:2331

load
monitor halt 
set print pretty on

# trace commands
#set trace-commands on
#set logging on

echo Start running\n

#source ~/FreeRTOS-GDB/src/FreeRTOS.py

b main
c

####################################################################################
#
# define Function
#
####################################################################################

define attach_cpu
    target remote 192.168.17.149:2331
    file ../../_build/Vienna/test_UART/test_UART.elf 
    monitor halt
    monitor regs
end

define savetrace
    set $traceptr = (unsigned long)&RecorderData
    set $traceptr_end = $traceptr + 0x100000
    printf "Dump tracedata to trace.bin @ %x ~ %x\n", $traceptr, $traceptr_end
    dump binary memory trace.bin $traceptr $traceptr_end
end

define saveconsole
    set $consoleptr = (unsigned long)&bConsoleOutputBuffer
    set $consoleptr_end = $consoleptr + 0x100000
    printf "Dump consoledata to console.bin @ %x ~ %x\n", $consoleptr, $consoleptr_end
    dump binary memory console.bin $consoleptr $consoleptr_end
end

define dataabort
    set $cpsr = $spsr
	set $PC = $lr
    bt
end

# Command "freertos_show_threads"
# Shows tasks table: handle(xTaskHandle) and name
define freertos_show_threads
	set $thread_list_size = 0
	set $thread_list_size = uxCurrentNumberOfTasks
	if ($thread_list_size == 0)
		echo FreeRTOS missing or scheduler isn't started\n
	else
		printf "\n"
		printf "  <Priority>  <ThreadID>   <Stack>  <Task Name>\n"
		printf "=================================================\n"
		
		set $current_thread = pxCurrentTCB
		set $tasks_found = 0
		set $idx = 0

		set $task_list = pxReadyTasksLists
		set $task_list_size = sizeof(pxReadyTasksLists)/sizeof(pxReadyTasksLists[0])

		printf "\n[ pxReadyTasksLists[%d] ]\n", $task_list_size
		while ($idx < $task_list_size)
			_freertos_show_thread_item $task_list[$idx]
			set $idx = $idx + 1
		end
		
		printf "\n[ xDelayedTaskList1:        %2d ]\n", xDelayedTaskList1.uxNumberOfItems
		_freertos_show_thread_item xDelayedTaskList1
		printf "\n[ xDelayedTaskList2:        %2d ]\n", xDelayedTaskList2.uxNumberOfItems
		_freertos_show_thread_item xDelayedTaskList2
		printf "\n[ xPendingReadyList:        %2d ]\n", xPendingReadyList.uxNumberOfItems
		_freertos_show_thread_item xPendingReadyList
		
		printf "\n[ xSuspendedTaskList:       %2d ]\n", xSuspendedTaskList.uxNumberOfItems
#		set $VAL_dbgFreeRTOSConfig_suspend = dbgFreeRTOSConfig_suspend_value
#		if ($VAL_dbgFreeRTOSConfig_suspend != 0)
			_freertos_show_thread_item xSuspendedTaskList
#		end

		printf "\n[ xTasksWaitingTermination: %2d ]\n", xTasksWaitingTermination.uxNumberOfItems
#		set $VAL_dbgFreeRTOSConfig_delete = dbgFreeRTOSConfig_delete_value
#		if ($VAL_dbgFreeRTOSConfig_delete != 0)
			_freertos_show_thread_item xTasksWaitingTermination
#		end
	end
end

# Command "freertos_switch_to_task"
# Switches debugging context to specified task, argument - task handle
define freertos_switch_to_task
	set var dbgPendingTaskHandle = $arg0
	set $current_IPSR_val = $xpsr & 0xFF
	if (($current_IPSR_val >= 1) && ($current_IPSR_val <= 15))
		echo Switching from system exception context isn't supported
	else
		set $VAL_dbgPendSVHookState = dbgPendSVHookState
		if ($VAL_dbgPendSVHookState == 0)
			set $last_PRIMASK_val = $PRIMASK
			set $last_SCB_ICSR_val = *((volatile unsigned long *)0xE000ED04)
			set $last_SYSPRI2_val = *((volatile unsigned long *)0xE000ED20)
			set $last_SCB_CCR_val = *((volatile unsigned long *)0xE000ED14)
			set $running_IPSR_val = $current_IPSR_val
			set $PRIMASK = 0
			# *(portNVIC_SYSPRI2) &= ~(255 << 16) // temporary increase PendSV priority to highest
				set {unsigned int}0xe000ed20 = ($last_SYSPRI2_val & (~(255 << 16)))
			# set SCB->CCR NONBASETHRDENA bit (allows processor enter thread mode from at any execution priority level)
			set {unsigned int}0xE000ED14 = (1) | $last_SCB_CCR_val
			set var dbgPendSVHookState = 1
		end
		# *(portNVIC_INT_CTRL) = portNVIC_PENDSVSET
			set {unsigned int}0xe000ed04 = 0x10000000
		continue
		# here we stuck at "bkpt" instruction just before "bx lr" (in helper's xPortPendSVHandler)
		# force returning to thread mode with process stack
		set $lr = 0xFFFFFFFD
		stepi
		stepi
		# here we get rewound to task
	end
end

# Command "freertos_restore_running_context"
# Restores context of running task
define freertos_restore_running_context
	set $VAL_dbgPendSVHookState = dbgPendSVHookState
	if ($VAL_dbgPendSVHookState == 0)
		echo Current task is RUNNING, ignoring command...
	else
		set var dbgPendingTaskHandle = (void *)pxCurrentTCB
		# *(portNVIC_INT_CTRL) = portNVIC_PENDSVSET
			set {unsigned int}0xe000ed04 = 0x10000000
		continue
		# here we stuck at "bkpt" instruction just before "bx lr" (in helper's xPortPendSVHandler)
		# check what execution mode was in context we started to switch from
		if ($running_IPSR_val == 0)
			# force returning to thread mode with process stack
			set $lr = 0xFFFFFFFD
		else
			# force returning to handler mode
			set $lr = 0xFFFFFFF1
		end
		stepi
		stepi
		# here we get rewound to running task at place we started switching
		# restore processor state
		set $PRIMASK = $last_PRIMASK_val
		set {unsigned int}0xe000ed20 = $last_SYSPRI2_val
		set {unsigned int}0xE000ED14 = $last_SCB_CCR_val
		if ($last_SCB_ICSR_val & (1 << 28))
			set {unsigned int}0xe000ed04 = 0x10000000
		end
		set var dbgPendSVHookState = 0
	end
end

# Command "show_broken_backtrace"
# Workaround of issue when context is being stuck in the middle of function epilogue (i.e., in vTaskDelay())
# This solution is applied to following situation only:
### ... function body end
### xxxxxxxx+0: add.w r7, r7, #16
### xxxxxxxx+4: mov sp, r7        ; <- debug current instruction pointer
### xxxxxxxx+6: pop {r7, pc}
### }
# (Otherwise it will crash !)
define show_broken_backtrace
	# cancel effect of xxxxxxxx+4 instruction twice (because we will step it to update eclipse views)
	set $r7 = $r7 - 16 - 16
	set $pc = $pc - 4
	stepi
end


#######################
# Internal functions
define _freertos_show_thread_item
##	printf "<show item> count = %d, @ 0x%x\n", $arg0.uxNumberOfItems, &($arg0)

	set $list_thread_count = $arg0.uxNumberOfItems
	set $prev_list_elem_ptr = -1
	set $list_elem_ptr = $arg0.xListEnd.pxPrevious
	
	while (($list_thread_count > 0) && ($list_elem_ptr != 0) && ($list_elem_ptr != $prev_list_elem_ptr) && ($tasks_found < $thread_list_size))
		set $threadid = $list_elem_ptr->pvOwner
		set $thread_name_str = (*((tskTCB *)$threadid)).pcTaskName
		set $thread_priority = (*((tskTCB *)$threadid)).uxPriority
		set $thread_stack = (*((tskTCB *)$threadid)).pxStack
		set $tasks_found = $tasks_found + 1
		set $list_thread_count = $list_thread_count - 1
		set $prev_list_elem_ptr = $list_elem_ptr
		set $list_elem_ptr = $prev_list_elem_ptr->pxPrevious
		
		if ($threadid == $current_thread)
			printf "  %8d    0x%08x  0x%08x  %s\t<---RUNNING\n", $thread_priority, $threadid, $thread_stack, $thread_name_str
		else
			printf "  %8d    0x%08x  0x%08x  %s\n", $thread_priority, $threadid, $thread_stack, $thread_name_str
		end
	end
end
