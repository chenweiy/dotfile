#
# MACRO List
# - savetrace
# - saveprintk
# - setup_exception
# - setup_illegal_func
# - loadapp
# - freertos_show_threads
# - freertos_switch_to_task (maybe not ok)
# - freertos_restore_running_context (maybe not ok)

# -------------------------------------------------------- #
define savetrace
  set $tracePtr = (unsigned long)RecorderDataPtr
##  set $traceSize = ((unsigned long)RecorderDataPtr->maxEvents * 4) + 20780
  set $traceSize = sizeof(RecorderDataType)
  set $tracePtr_end = $tracePtr + $traceSize
  printf "Dump FreeRTOS+Trace data to [ trace.bin ] @ 0x%x ~ 0x%x, size = %d bytes\n", $tracePtr, $tracePtr_end, $traceSize
  dump binary memory trace.bin $tracePtr $tracePtr_end
end
document savetrace
  Store FreeRTOS+Trace records into a file.    
end

# -------------------------------------------------------- #
define saveprintk
    set $printptr = (unsigned long)bConsoleOutputBuffer
    set $printptr_end = $printptr + configPLATFORM_CONSOLE_OUTPUT_BUFF_SIZE
    printf "Dump printk buffer to printk.txt @ %x ~ %x\n", $printptr, $printptr_end
    dump binary memory printk.txt $printptr $printptr_end
end
document saveprintk
  Store printk buffer into a file.
end


# -------------------------------------------------------- #
define setup_exception
  set debug arm

  # Break at main first
  break main
  
  # DataAbort
  break __vDataAbort
  commands
    dcpu
    set $pc = $lr
  #    set $cpsr = 0x6000001f
    bt
  end


  # PrefetchAbort
  break __vPrefetchAbort
  commands
    dcpu
    set $pc = $lr
    bt
  end

  # Undefine Abort
  break __vUndefAbort
  commands
    dcpu
  #    set $cpsr = 0x6000001f
    set $pc = $lr
    bt
  end

end

# -------------------------------------------------------- #
define setup_illegal_func
  break printf
  commands
    echo Can't use libc printf\n
    bt
  end

#  break fclose
#  commands
#    echo Can't use libc fclose\n
#    bt
#  end

#  break calloc 
#  commands
#    echo Can't use libc calloc\n
#    bt
#  end
#
#  break malloc 
#  commands
#    echo Can't use libc malloc\n
#    bt
#  end
#
#  break free
#  commands
#    echo Can't use libc free\n
#    bt
#  end
#
#  break calloc 
#  commands
#    echo Can't use libc calloc\n
#    bt
#  end

end

# -------------------------------------------------------- #
# Command "freertos_show_threads"
# Shows tasks table: handle(xTaskHandle) and name
define freertos_show_threads
	set $thread_list_size = 0
	set $thread_list_size = uxCurrentNumberOfTasks
	if ($thread_list_size == 0)
		echo FreeRTOS missing or scheduler isn't started\n
	else
		printf "\n"
		printf "  <Priority>  <ThreadID>  <Stack - Allocate, Size, Used Size, Top>  <Task Name>\n"
		printf "=================================================\n"
		
		set $current_thread = pxCurrentTCB
		set $tasks_found = 0
		set $idx = 0

		set $task_list = pxReadyTasksLists
		set $task_list_size = sizeof(pxReadyTasksLists)/sizeof(pxReadyTasksLists[0])

		printf "[ pxReadyTasksLists[%d] ]\n", $task_list_size
		while ($idx < $task_list_size)
			_freertos_show_thread_item $task_list[$idx]
			set $idx = $idx + 1
		end
		
		printf "[ xDelayedTaskList1:        %2d ]\n", xDelayedTaskList1.uxNumberOfItems
		_freertos_show_thread_item xDelayedTaskList1
		printf "[ xDelayedTaskList2:        %2d ]\n", xDelayedTaskList2.uxNumberOfItems
		_freertos_show_thread_item xDelayedTaskList2
		printf "[ xPendingReadyList:        %2d ]\n", xPendingReadyList.uxNumberOfItems
		_freertos_show_thread_item xPendingReadyList
		
		printf "[ xSuspendedTaskList:       %2d ]\n", xSuspendedTaskList.uxNumberOfItems
#		set $VAL_dbgFreeRTOSConfig_suspend = dbgFreeRTOSConfig_suspend_value
#		if ($VAL_dbgFreeRTOSConfig_suspend != 0)
			_freertos_show_thread_item xSuspendedTaskList
#		end

		printf "[ xTasksWaitingTermination: %2d ]\n", xTasksWaitingTermination.uxNumberOfItems
#		set $VAL_dbgFreeRTOSConfig_delete = dbgFreeRTOSConfig_delete_value
#		if ($VAL_dbgFreeRTOSConfig_delete != 0)
			_freertos_show_thread_item xTasksWaitingTermination
#		end
	end
end

#######################
# Internal functions
define _freertos_show_thread_item
##	printf "<show item> count = %d, @ 0x%x\n", $arg0.uxNumberOfItems, &($arg0)

	set $list_thread_count = $arg0.uxNumberOfItems
	set $prev_list_elem_ptr = -1
	set $list_elem_ptr = $arg0.xListEnd.pxPrevious

# [ Stack Size ] -> get info from Heap Struct Size
	set $portBYTE_ALIGNMENT	= 32
	set $portBYTE_ALIGNMENT_MASK = 0x0000003F

	set $_PAR_HEAP_STRUCT_SIZE = 12
	set $_PAR_HEAP_ALIGN_BYTE = $portBYTE_ALIGNMENT
	set $_PAR_HEAP_ALLOCATE_MASK = 0x80000000
# [ Stack Size ] <-

	while (($list_thread_count > 0) && ($list_elem_ptr != 0) && ($list_elem_ptr != $prev_list_elem_ptr) && ($tasks_found < $thread_list_size))
		set $threadId = $list_elem_ptr->pvOwner
		set $thread_name_str = (*((tskTCB *)$threadId)).pcTaskName
		set $thread_priority = (*((tskTCB *)$threadId)).uxPriority
		## .pxStack is allocated address, bottom of stack!!
		set $thread_stack = (*((tskTCB *)$threadId)).pxStack		
		set $tasks_found = $tasks_found + 1
		set $list_thread_count = $list_thread_count - 1
		set $prev_list_elem_ptr = $list_elem_ptr
		set $list_elem_ptr = $prev_list_elem_ptr->pxPrevious
# [ Stack Size ] -> get info from Heap Struct Size
		set $pdwStackAddr = $thread_stack
		set $extraHeapSize = *(--$pdwStackAddr) - $_PAR_HEAP_STRUCT_SIZE
		set $dwTmp = *(--$pdwStackAddr)
		set $stackSize = 0		
		set $stackUsedSize = 0
		set $thread_TopOfStack = (*((tskTCB *)$threadId)).pxTopOfStack
		set $thread_EndOfStack = $thread_stack
		
		if ($dwTmp & $_PAR_HEAP_ALLOCATE_MASK)
			set $stackSize = $dwTmp & (~0x80000000) - $portBYTE_ALIGNMENT - $extraHeapSize
			# Argument to arithmetic operation not a number or boolean.
#			set $thread_EndOfStack = ($thread_stack + ( ($stackSize / sizeof(StackType_t)) - 1 )) & (~$portBYTE_ALIGNMENT_MASK)
			set $thread_EndOfStack = $thread_stack + ( ($stackSize / sizeof(StackType_t)) - 0 )
			set $stackUsedSize = ($thread_EndOfStack - $thread_TopOfStack) << 2
		end	
# [ Stack Size ] <-
		
		if ($threadId == $current_thread)
			printf "  %8d    0x%08x  (0x%08x, %6d, %6d, 0x%08x)  %s\t<---RUNNING\n", $thread_priority, $threadId, $thread_stack, $stackSize, $stackUsedSize, $thread_TopOfStack, $thread_name_str
		else
			printf "  %8d    0x%08x  (0x%08x, %6d, %6d, 0x%08x)  %s\n", $thread_priority, $threadId, $thread_stack, $stackSize, $stackUsedSize, $thread_TopOfStack, $thread_name_str
		end
	end
end

# -------------------------------------------------------- #
# Command "freertos_switch_to_task"
#
define freertos_switch_to_task
	set $stack_top = $arg0
	set $critcial_count = *((volatile unsigned long *) $stack_top)
	set $cpsr = *((volatile unsigned long *) ($stack_top + 4))
	set $r0 = *((volatile unsigned long *) ($stack_top + 8))
	set $r1 = *((volatile unsigned long *) ($stack_top + 12))
	set $r2 = *((volatile unsigned long *) ($stack_top + 16))
	set $r3 = *((volatile unsigned long *) ($stack_top + 20))
	set $r4 = *((volatile unsigned long *) ($stack_top + 24))
	set $r5 = *((volatile unsigned long *) ($stack_top + 28))
	set $r6 = *((volatile unsigned long *) ($stack_top + 32))
	set $r7 = *((volatile unsigned long *) ($stack_top + 36))
	set $r8 = *((volatile unsigned long *) ($stack_top + 40))
	set $r9 = *((volatile unsigned long *) ($stack_top + 44))
	set $r10 = *((volatile unsigned long *) ($stack_top + 48))
	set $r11 = *((volatile unsigned long *) ($stack_top + 52))
	set $r12 = *((volatile unsigned long *) ($stack_top + 56))
	set $r13 = *((volatile unsigned long *) ($stack_top + 60))
	set $r14 = *((volatile unsigned long *) ($stack_top + 64))
	set $r15 = *((volatile unsigned long *) ($stack_top + 68)) - 4
end

# -------------------------------------------------------- #
# Command "freertos_switch_to_task"
# Switches debugging context to specified task, argument - task handle
#define freertos_switch_to_task
#	set var dbgPendingTaskHandle = $arg0
#	set $current_IPSR_val = $xpsr & 0xFF
#	if (($current_IPSR_val >= 1) && ($current_IPSR_val <= 15))
#		echo Switching from system exception context isn't supported
#	else
#		set $VAL_dbgPendSVHookState = dbgPendSVHookState
#		if ($VAL_dbgPendSVHookState == 0)
#			set $last_PRIMASK_val = $PRIMASK
#			set $last_SCB_ICSR_val = *((volatile unsigned long *)0xE000ED04)
#			set $last_SYSPRI2_val = *((volatile unsigned long *)0xE000ED20)
#			set $last_SCB_CCR_val = *((volatile unsigned long *)0xE000ED14)
#			set $running_IPSR_val = $current_IPSR_val
#			set $PRIMASK = 0
#			# *(portNVIC_SYSPRI2) &= ~(255 << 16) // temporary increase PendSV priority to highest
#				set {unsigned int}0xe000ed20 = ($last_SYSPRI2_val & (~(255 << 16)))
#			# set SCB->CCR NONBASETHRDENA bit (allows processor enter thread mode from at any execution priority level)
#			set {unsigned int}0xE000ED14 = (1) | $last_SCB_CCR_val
#			set var dbgPendSVHookState = 1
#		end
#		# *(portNVIC_INT_CTRL) = portNVIC_PENDSVSET
#			set {unsigned int}0xe000ed04 = 0x10000000
#		continue
#		# here we stuck at "bkpt" instruction just before "bx lr" (in helper's xPortPendSVHandler)
#		# force returning to thread mode with process stack
#		set $lr = 0xFFFFFFFD
#		stepi
#		stepi
#		# here we get rewound to task
#	end
#end

# -------------------------------------------------------- #
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

