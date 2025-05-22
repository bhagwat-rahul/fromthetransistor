# From chatgpt

A UART (Universal Asynchronous Receiver/Transmitter) is a hardware block that turns parallel data into a serial bit-stream for transmission, and vice-versa for reception, using no separate clock line—just two data pins (TX and RX) and agreed timing parameters. Conceptually, building one in Verilog means decomposing it into three major pieces:

---

## 1. Baud-Rate Generator

* **Purpose**: Derives the “baud tick” (bit-period timing) from your system clock.
* **How it works**:

  1. You choose a data rate (e.g. 115200 baud) and know your system clock (e.g. 50 MHz).
  2. Compute a divisor:

     $$
       \text{divisor} = \frac{\text{sys\_clk\_freq}}{\text{baud} \times \text{oversampling}}
     $$
  3. A counter divides the clock down. Every time it rolls over, it emits a tick.
* **Oversampling** (commonly 16×): The receiver samples the incoming line multiple times per bit to reject line noise and detect the bit center precisely.

---

## 2. Transmitter (TX) Engine

* **Shift Register**: Holds the byte to send.
* **Finite-State Machine (FSM)**:

  1. **IDLE**: TX line is held high (“mark”).
  2. **START**: Pull TX low for one baud tick to signal the start bit.
  3. **DATA**: Serially shift out each data bit (LSB first) on successive baud ticks.
  4. **PARITY** (optional): If enabled, send an extra bit computed over the data bits.
  5. **STOP**: Drive TX high for 1–2 baud ticks to mark the end of the frame.
  6. **DONE**: Assert a “ready for next byte” flag, then return to IDLE.
* **Handshake**: An input “send\_request” strobes the FSM to load a new byte; an output “busy” or “done” indicates when you can issue the next one.

---

## 3. Receiver (RX) Engine

* **Input Sampling**: You tie the RX pin into a shift-in register and oversample it.
* **FSM Sequence**:

  1. **IDLE**: Watch for RX to fall from high to low—that’s the start bit edge.
  2. **START-BIT VALIDATION**: Wait half a bit-period (to hit the bit center), sample again to confirm it’s still low.
  3. **DATA**: Every baud tick, sample the line and shift the sampled bit into a register.
  4. **PARITY CHECK** (optional): Sample the parity bit and compare to expected.
  5. **STOP-BIT CHECK**: Sample one or two bits of stop (should read high); if not, flag a framing error.
  6. **BYTE READY**: Assert a “data\_ready” flag and present the assembled byte on an output bus.
* **Noise Rejection**: Oversampling plus majority voting or digital filtering can improve reliability.

---

## 4. Top-Level Integration & FIFOs

* **Control Registers**: Expose configuration (baud rate divisor, parity, data-bit length, stop-bit count) via a simple bus or register interface.
* **FIFO Buffers** (optional):

  * **TX FIFO**: Queue up bytes to send without stalling the CPU.
  * **RX FIFO**: Buffer incoming bytes until the CPU is ready to read them.
* **Interrupts / Polling**: Generate an interrupt or set a status bit when RX has data or TX FIFO is below a threshold.

---

### Putting It All Together in Verilog (Conceptually)

1. **baud\_gen** module

   * Inputs: `clk`, `reset`
   * Outputs: `baud_tick` (and, if oversampling, `tick_16x`)
2. **uart\_tx** module

   * Inputs: `clk`, `reset`, `baud_tick`, `tx_data[7:0]`, `send_request`, config bits
   * Outputs: `tx_pin`, `tx_busy`, `tx_done`
3. **uart\_rx** module

   * Inputs: `clk`, `reset`, `baud_tick` (or `tick_16x`), `rx_pin`, config bits
   * Outputs: `rx_data[7:0]`, `data_ready`, `parity_err`, `frame_err`
4. **uart\_top** wrapper

   * Instantiates `baud_gen`, `uart_tx`, `uart_rx`
   * Connects FIFOs or registers for CPU interface
   * Hooks up interrupts/status lines

---

### Key Conceptual Takeaways

* **Asynchronous**: No shared clock; both sides must agree on baud rate and framing.
* **Framing**: Start bit, data bits, (optional) parity, stop bits.
* **Shift-and-Sample**: TX shifts data out; RX oversamples and shifts data in.
* **State Machines**: Both TX and RX are simple FSMs gated by the baud-rate generator.
* **Configurability**: Changing the divisor (and optional parity/stop-bit settings) makes your UART flexible across different serial devices.

By breaking the design into these discrete, well-defined modules and using simple FSMs driven by a clock divider, a fully functional UART can be built in under 200 lines of Verilog—readable, reusable, and easy to verify.
