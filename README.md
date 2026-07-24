# Hybrid C & Rust Pre-emptive Scheduler on STM32H7 ⏱️

*Performance-benchmarked RTOS scheduler with interrupt-latency profiling on ARM Cortex-M7, benchmarked against a FreeRTOS baseline.*

**[In Progress]**

A preemptive task scheduler, currently implemented in Rust, that demonstrates core OS concepts — context switching, timer interrupts, and time-slicing — so multiple tasks can share a single CPU without explicitly yielding control. The project's direction is to grow into a hybrid C/Rust RTOS scheduler targeting the **STM32H7 (ARM Cortex-M7)**, with interrupt-latency profiling and head-to-head benchmarks against FreeRTOS.

> **Status note:** the code in this repo today is a `no_std` Rust scheduler targeting **x86_64 / riscv64 / aarch64**. It does not yet include C code, an STM32H7/Cortex-M7 port, or a FreeRTOS benchmarking harness — those are tracked below under [Roadmap](#-roadmap).

## 🚀 Features

**Implemented today:**
*   **Preemptive multitasking:** a running task can be interrupted before it finishes, via `handle_timeout()`, and control handed back to the scheduler instead of relying on the task to yield.
*   **Context switching:** architecture-specific save/restore of registers, stack pointer, and program counter, implemented in raw assembly per target (`src/arch/<target>/switch.S`).
*   **Waker-driven ready queue:** tasks are modeled as async Rust `Future`s; a generator scans per-priority task pages for ones that have been woken and are ready to run.
*   **Task management:** spawn, voluntarily yield (`sched_yield`), and remove tasks through a simple API.
*   **Per-CPU executors + work stealing:** each CPU core runs its own executor and task queue; idle cores can steal work from the busiest core.
*   **Multi-architecture support:** `x86_64`, `riscv64`, `aarch64`.

**Planned / in progress:**
*   Round-robin and/or strict priority-based scheduling policy (a `priority` field and `MAX_PRIORITY` levels already exist in the task model, but task insertion currently only supports the default priority — priority-aware scheduling is not yet active).
*   Port to **ARM Cortex-M7 / STM32H7** (a different architecture family — ARMv7-M — from the aarch64 target currently supported).
*   C interop layer for the "hybrid C & Rust" architecture.
*   Interrupt-latency profiling/instrumentation.
*   Benchmark suite comparing scheduling/latency numbers against FreeRTOS.

## 🧠 How It Works

Unlike cooperative schedulers where tasks must manually yield, this scheduler can take control away from a running task when its time quantum expires (or it can still yield voluntarily via `sched_yield()`).

1.  **Timer interrupt (ISR):** a hardware timer fires periodically (frequency is configured by the embedding kernel/runtime, not by this crate itself).
2.  **Context save:** `handle_timeout()` triggers a context switch that saves the current task/executor's registers onto its own stack.
3.  **Scheduling decision:** the runtime's generator scans the ready queue (currently a single default-priority pool per CPU, plus cross-CPU work stealing when a CPU is idle) for the next task to run.
4.  **Context restore:** the CPU loads the new task's saved context and stack pointer.
5.  **Execution:** the CPU resumes the new task exactly where it previously left off (or begins a fresh task if none was previously in progress).

## 🛠️ Prerequisites

*   Rust **nightly**, pinned via [`rust-toolchain`](./rust-toolchain) (currently `nightly-2022-02-22`) — several unstable features are used (`allocator_api`, `generators`, etc.).
*   A target triple for one of the currently supported architectures: `x86_64`, `riscv64`, `aarch64`.
*   An embedding environment (kernel or bare-metal runtime) that provides a global allocator, since this crate is `#![no_std]` + `extern crate alloc`.
*   For the planned STM32H7 target: an ARM Cortex-M7 toolchain (`thumbv7em-none-eabihf` or similar) and, once added, QEMU or physical hardware to run on.

## 💻 Building and Running

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/bhaskar10h/Preemptive_Scheduler.git
    cd Preemptive_Scheduler
    ```

2.  **Build for a currently supported architecture:**
    ```bash
    # Host architecture (must be x86_64, riscv64, or aarch64)
    cargo build

    # Cross-compile, e.g. for riscv64
    cargo build --target riscv64gc-unknown-none-elf

    # With the baremetal test feature
    cargo build --features baremetal-test
    ```

    Since this crate is a `#![no_std]` library, it doesn't produce a standalone binary — it's meant to be embedded in a larger kernel/runtime project that drives its scheduling loop from boot and interrupt-handling code.

3.  **STM32H7 target:** not yet available in this repo. Once the Cortex-M7 port lands, this section will include the correct target triple, flashing/QEMU instructions, and how to run the FreeRTOS comparison benchmarks.

## 📁 Project Structure

```
.
├── Cargo.toml
├── rust-toolchain          # pins the nightly toolchain used to build
└── src
    ├── lib.rs              # crate entry point, public API re-exports
    ├── runtime.rs          # per-CPU ExecutorRuntime, global runtime table, spawn/yield/timeout API
    ├── executor.rs         # Executor: runs tasks to completion, until preempted, or until yielded
    ├── task_collection.rs  # task queue, priority pools, waker-driven ready-task generator
    ├── context.rs          # architecture-agnostic context abstraction
    ├── waker_page.rs       # bitmap-based waker/status tracking for tasks.
    └── arch/
        ├── x86_64/         # context switch, executor entry, low-level asm (x86_64)
        ├── riscv64/        # context switch, executor entry, low-level asm (riscv64)
        └── aarch64/        # context switch, executor entry, low-level asm (aarch64)
```

## 🗺️ Roadmap

- [ ] Activate priority-aware task scheduling (infrastructure exists; wiring is incomplete)
- [ ] Add Cortex-M7 / STM32H7 architecture support under `src/arch/`
- [ ] Introduce C interop layer for hybrid C/Rust scheduling
- [ ] Add interrupt-latency instrumentation/profiling
- [ ] Build a FreeRTOS baseline benchmark and comparison harness
