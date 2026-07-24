# Preemptive Scheduler ⏱️

A preemptive task scheduler built in [RUST]. This project demonstrates core operating system concepts—including context switching, timer interrupts, and time-slicing—allowing multiple tasks to share a single CPU seamlessly without requiring the tasks to explicitly yield control.

## 🚀 Features

*   **Preemptive Multitasking:** Automatically interrupts running tasks based on a time-slice (quantum) using timer interrupts.
*   **Context Switching:** Efficiently saves and restores task states (CPU registers, stack pointers, program counters).
*   **Scheduling Algorithm:** Uses a [Round-Robin / Priority-based] scheduling algorithm to determine the next task to run.
*   **Task Management:** Simple interface to create, pause, resume, and terminate tasks.
*   **[Hardware/Architecture]:** Built to run on [Bare-metal riscv/ x86_64 / aarch64].

## 🧠 How It Works

Unlike cooperative schedulers where tasks must manually yield (`yield()`), this preemptive scheduler takes control away from a running task when its time quantum expires. 

1.  **Timer Interrupt (ISR):** A hardware timer triggers an interrupt every $N$ milliseconds.
2.  **Context Save:** The CPU pushes the current task's registers onto its individual stack.
3.  **Scheduling Decision:** The scheduler selects the next task from the "Ready" queue based on the [Round Robin] policy.
4.  **Context Restore:** The CPU loads the registers and stack pointer of the new task.
5.  **Execution:** The CPU resumes execution exactly where the new task previously left off.

## 🛠️ Prerequisites

To build and run this project, you will need:
*   [Rust >= 1.79.0]
*   [Rust Toolchain]
*   [QEMU (if emulating) or specific hardware board]

## 💻 Building and Running

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/bhaskar10h/Preemptive_Scheduler.git](https://github.com/bhaskar10h/Preemptive_Scheduler.git)
   cd Preemptive_Scheduler