# NDS Slot 2 reverse engineering documentation

## Introduction
This is intended to be an extension of [jojolebarjos/gba-cartridge](https://github.com/jojolebarjos/gba-cartridge) to the NDS slot 2. The NDS has different registers and timings from the GBA slot.

Additionally, nobody has done proper timing diagrams for the NDS (or GBA) slot. This is important for designing your own GBA/NDS peripherals. 

I used the SignalTap logic analyzer for Alterra FPGAs to analyze the timings, then [WaveDrom](https://wavedrom.com) to create nice timing diagrams. The diagrams are presented further down in this document.

## Nintendo DS timings vs. GBA timings

There are subdle differences on the NDS and GBA timings. You can find the full comparison the GBATEK reference document, [DS Cartridge GBA Slot](https://problemkaputt.de/gbatek.htm#dscartridgegbaslot) section.

### The use of `EXMEMCNT`
The NDS allows some flexibility in the way the slot-2 is accesses. Specifically, it allows you to control how fast (how many cycles) a read or write should take. This is all controlled through the `EXMEMCNT` register. This register is very well documented on the GBATEK reference document. In this publication I have collected data for multiple `EXMEMCNT` configurations. 

The GBA's equivalent register to `EXMEMCNT` is the `WAITCNT` register. It has different timings (so these diagrams may not be accurate). I could do captures but I don't own a GBA. If you would like to donate one to the cause, please contact me at ([devel@ivanveloz.com](mailto:devel@ivanveloz.com)).

### Clock polarity inconsistencies
In addition to what Martin has documented, I have found the NDS slot 2 has one unexpected inconsistency. The NDS slot 2 may start transfers on either the rising or falling edge of the clock. My suspicion is that the PHI output is being divided by two from the ~33MHz system clock, but the slot 2 bus logic is being clocked at ~33MHz, not ~16MHz like on the GBA. The consequence of this is that transfers may start on either the rising or falling edge. In other words, the `PHI` signal on the diagrams below may look inverted in some transfers.

If you are working with an FPGA and using PHI as the clock source this situation breaks your HDL code. The solution is to use a phase locked loop to (at least) double the clock. It also gives you an opportunity to add a phase offset, which may help you meet timing constraints. That is the setup I used to do these captures. The `BUS` signal on the diagrams shows how this clock could look like if you set it up.

### Clock frequency
The exact nominal clock frequency of the GBA is 16.77216MHz. The NDS is 33.513982MHz. The NDS's frequency is not exactly double: if the frequency is divided in half the result is 16.756991MHz. In fact GBA games run slightly slower on the NDS. The difference is 1207ppm or ~0.12%. Considering common quartz oscillators have under 50ppm tolerances this may be a significant difference in some applications.

## Read/write diagrams

The read and write diagrams are subdivided divided by their access type and their `EXMEMCNT` setting.

By access type:
- Single read (or write): a single 16-bit value is read (or written).
- Double read (or write): a single 32-but value is read (or written).
- DMA read (or write):  DMA is used to write a series of values.

They are also divided by `EXMEMCNT` setting (I use the GBATEK descriptions):
- `E860`: first access 10 cycles, second access 6 cycles.
- `E864`: first access 8 cycles, second access 6 cycles.
- `E868`: first access 6 cycles, second access 6 cycles.
- `E86C`: first access 18 cycles, second access 6 cycles.
- `E870`: first access 10 cycles, second access 4 cycles.
- `E878`: first access 6 cycles, second access 4 cycles.

All of the diagrams are drawn assuming PHI is set up at 16MHz.

The diagrams only cover `~CS1` reads and writes (in GBA terms, the ROM, not the RAM). A textual description of `~CS2` access can be found in [jojolebarjos/gba-cartridge](https://github.com/jojolebarjos/gba-cartridge).

I have not collected all possible combinations, but you can see what's available and extrapolate or capture on your own. Contributions, of course, are very welcome. Requests too.

Without further ado, these are the timing diagrams. You can also download them [here](https://github.com/IvanVeloz/nds-slot2/tree/gh-pages). They may not be to scale relative to each other, depending on how wide your screen is.

### Powerup diagram

**Powerup sequence**: at 0ms voltage on VCC starts ramping up. Simultaneously, `~CS1` and `~CS2` ramp up with no delay, suggesting a strong pullup resistor. At 125ms the `~WR` and `~RD` lines are activated. The `AD` lines are weakly pulled up. At some point `~CS1` and `~CS2` become actively driven, perhaps together with `~WR` and `~RD`. At 2200ms, the splash screen is shown, with the health warning. The NDS proceeds to seach for a GBA game or NDS accessory. Documentation for this is beyond the scope of this document, but I believe GBATEK has details on it.

![Powerup timings](https://ivanveloz.github.io/nds-slot2/powerup.svg)

### Write diagrams
In this context, "write" means the NDS outputs information into the cartridge. Note how the first single write word takes one less cycle than the first double write word.

![Write timings double write EXMEMCNT=E860](https://ivanveloz.github.io/nds-slot2/E860-doublewrite-GBA_BUS.svg)

![Write timings single write EXMEMCNT=E860](https://ivanveloz.github.io/nds-slot2/E860-singlewrite-GBA_BUS.svg)

![Write timings double write EXMEMCNT=E864](https://ivanveloz.github.io/nds-slot2/E864-doublewrite-GBA_BUS.svg)

![Write timings single write EXMEMCNT=E864](https://ivanveloz.github.io/nds-slot2/E864-singlewrite-GBA_BUS.svg)

![Write timings single write EXMEMCNT=E868](https://ivanveloz.github.io/nds-slot2/E868-singlewrite-GBA_BUS.svg)

![Write timings single write EXMEMCNT=E86C](https://ivanveloz.github.io/nds-slot2/E86C-singlewrite-GBA_BUS.svg)

![Write timings double write EXMEMCNT=E870](https://ivanveloz.github.io/nds-slot2/E870-doublewrite-GBA_BUS.svg)

![Write timings DMA write EXMEMCNT=E878](https://ivanveloz.github.io/nds-slot2/E878-dmawrite-GBA_BUS.svg)
**Note:** DMA writes are often stalled when the processors perform bus access.

![Write timings double write EXMEMCNT=E878](https://ivanveloz.github.io/nds-slot2/E878-doublewrite-GBA_BUS.svg)

### Read diagrams
In this context, "read" means the cartridge outputs information into the NDS. Make sure to read the electrical observations to avoid damaging the `AD` outputs.

![Read timings double read EXMEMCNT=E860](https://ivanveloz.github.io/nds-slot2/E860-doubleread-GBA_BUS.svg)

![Read timings single read EXMEMCNT=E860](https://ivanveloz.github.io/nds-slot2/E860-singleread-GBA_BUS.svg)

![Read timings single read EXMEMCNT=E864](https://ivanveloz.github.io/nds-slot2/E864-singleread-GBA_BUS.svg)

![Read timings single read EXMEMCNT=E868](https://ivanveloz.github.io/nds-slot2/E868-singleread-GBA_BUS.svg)

## Electrical observations
Working with these captures gave an oportunity to see what is going on with the bus, electrically. This is not well documented in other places like GBATEK because they focus on emulation.

### The `~CS` pins

These pins indicate when a transfer is about to happen. When `~CS1` is low, a 16-bit transfer will happen on `AD15` to `AD0`. When `~CS2` is low, an 8-bit transfer is done on `AD23` to `AD16`.

These pins are pulled up at start-up (presumably by an external pull-up), then they are actively driven (i.e. a low impedance output). See the powerup diagram for details.

### The `AD` pins
When `~CS1` and `~CS2` are deasserted (are high) the `AD` pins are left floating. They very are very slowly pulled up (takes tens of PHI clock cycles). This will look like confusing garbage on a logic analyzer, but on an oscilloscope you can see the voltage rising. The pull-ups seem to be weak pull-ups of approximately 50k.

It's only safe to drive the `AD15` to `AD0` pins when both `~RD` and `~CS1` are low. Do not drive these pins in any other circumstance.

During `~CS1` reads the pins `AD23` to `AD16` **are driven low** by the NDS. Do not drive these pins from the cartridge side during `~CS1` reads. They can only be driven when both `~RD` and `~CS2` are low (i.e. during `~CS2` reads).

The data is latched by the NDS on the rising edge of `~RD`.

My suggestion  if you're using FPGAs is to have GPIO tri-state buffer driven directly by `~RD` and `~CSn` in combinational logic. This is good for both prototyping and production. Also, for prototyping, an even safer alternative to have 100 ohm resistors between the NDS and FPGA, at least until you get the combinational logic correct (the resistors will affect signal integrity).

For microcontrollers, if you have the I/O, by far the safest option is to have a 74LVC125 tri-state buffer (or similar). Have some logic gates enable the 74LVC125 outputs only when `~RD` and `~CSn` are low. This is very safe for prototyping, then you can move on to a cheaper software-based solution.

### The `IRQ` pin
The `IRQ` pin is an input (signal goes into the NDS). It has a weak pull-up of approximately 50k, pulled up to 3.3V. I am not sure if it's a physical resistor or if is built into the NTR processor.

On commercial cartridges the IRQ line is shorted to ground. I assume this is done to detect whether the cartridge is plugged in or not, and to allow interrupting then halting the processor if the cartridge is unplugged.
