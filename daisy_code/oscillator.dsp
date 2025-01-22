// This file is not meant to be used with polyphony.

//------------------------------------------------------------
// An oscillator with a controllable volume. The pitch
// is quantized to a major scale with the range of a standard
// piano.
//
// #### Parameters
//
// * `Knob 1`: Gain
// * `Knob 2`: Note in terms of MIDI pitch.
//------------------------------------------------------------

import("stdfaust.lib");

scaleIonian(rootNote) = ba.midikey2hz : qu.quantize(rootFreq,qu.ionian)
with {
    rootFreq = ba.midikey2hz(rootNote);
};

gain = hslider("gain [knob:1]", -80, -80, 0, .01) : ba.db2linear;
freq = hslider("Note [knob:2]", 60, 22, 108, 1) : scaleIonian(60);
process = os.osc(freq)*gain <: _,_;
