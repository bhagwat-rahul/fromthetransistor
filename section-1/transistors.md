# Transistor notes

transistors are devices made out of semiconductors. their purpose is to either amplify an electric signal or act as an on off switch.
they are usually made out of 3 regions (a doped semiconductor chip either p or n type which basically means electrons removed or added).
n-type transistors are electron rich and p type are hole rich (electron poor).
when used for switching usually a small current at their base opens a pathway for electric signals to flow through them to turn on/off.
when used for amplification it's similar, a weak signal modulates a much larger one.

a lut in an fpga is a 'look up table'. fpgas are essentially reconfigurable pieces of hardware.
reconfigurable in the 'logical' sense, not as in they actually move wires around physically.
an fpga is just a collection of luts, flip flops and muxes (think of it like a large dynamic truth table that you just fill vals into)
your hw can be broken down into boolean logic and the luts will just implement that logic based on the 'bistream' (similar to a program binary)
the bitstream will have things like what lut to target and what to fill into it + voltage standards, hw pin mappings.
