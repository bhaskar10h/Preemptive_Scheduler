# executor entry function
#
#   void executor_entry()
#
# This function simply retrieves the address of the executor instance at the bottom of the stack
# Then it jumps to the runtime.rs::run_executor function.
#
	.text
	.globl executor_entry
	.balign 4
executor_entry:
	ldr x0, [sp]
	b run_executor


