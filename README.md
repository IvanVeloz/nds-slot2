# NDS Slot 2 reverse engineering documentation

## Motivation
This is intended to be an extension of [jojolebarjos/gba-cartridge](https://github.com/jojolebarjos/gba-cartridge) to the NDS slot 2. It has different registers and timings from the GBA.

Additionally, nobody has done proper timing diagrams for the GBA slot. This is important for designing your own GBA/NDS peripherals. I used [WaveDrom](https://wavedrom.com) for this. 

## Nintendo DS timings vs. GBA timings

You can find the full comparison the GBATEK reference document, [DS Cartridge GBA Slot](https://problemkaputt.de/gbatek.htm#dscartridgegbaslot) section.

### Clock polarity inconsistencies
The NDS slot 2 may start transfers on either the rising or falling edge of the clock. My suspicion is that the PHI output is being divided by two from the ~33MHz system clock, but the transfers started whenever the bus (clocked at ~33MHz) is ready.
