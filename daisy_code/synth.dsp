// suggested compilation:
// faust2daisy -pod -sdram -sr 48000 -bs 16 synth.dsp

//------------------------------------------------------------
// An oscillator that can be triggered with a button. The pitch
// is quantized to a major scale with the range of a standard
// piano.
//
// #### Parameters
//
// * `Button 1`: Gate to trigger note.
// * `Button 2`: Toggle an echo effect.
// * `Knob 1`: Note in terms of MIDI pitch.
// * `Knob 2`: Filter cutoff of a lowpass filter.
//------------------------------------------------------------

import("stdfaust.lib");

//---------------scaleIonian-------------------------
// This takes a MIDI note, quantizes it to an Ionian
// (major) scale, and produces a frequency.
//
// #### Usage
//
// ```
// _ : scaleIonian(rootNote) : _
// ```
//
// Where:
//
// * `rootNote`: A root note (MIDI key) such as 24 for C0.
//----------------------------------------------------
scaleIonian(rootNote) = ba.midikey2hz : qu.quantize(rootFreq,qu.ionian)
with {
    rootFreq = ba.midikey2hz(rootNote);
};

note = hslider("Note [knob:1]", 60, 22, 108, 1);
gate = button("gate [switch:1]");

envVol = hgroup("Env", en.adsr(attack, decay, sustain, release, gate))
with {
    timeScale(x) = (x^4)*32;
    attack = hslider("[0] Attack [style:knob]", 0.1, 0, 1, .01) : timeScale;
    decay = hslider("[1] Decay [style:knob]", 1, 0, 1, .01);
    sustain = hslider("[2] Sustain [style:knob]", 0, 0, 1, .01) : timeScale;
    release = hslider("[3] Release [style:knob]", .15, 0, 1, .01) : timeScale;
};

rootNote = hslider("Root Note [style:knob]", 30, 22, 33, 1);

lowpass = fi.lowpass(2, filterCutoff)
with {
    filterCutoff = hslider("Cutoff [style:knob][knob:2]", 60, ba.hz2midikey(20), ba.hz2midikey(20000), .1) : ba.midikey2hz;
};

echo = ba.bypass1(1-checkbox("Echo [switch:2]"), ef.echo(maxDuration, duration, feedback))
with {
    maxDuration = 0.125;
    duration = maxDuration;
    feedback = 0.5;
};

synth = note : scaleIonian(rootNote) : os.sawtooth : _*envVol*0.8 : lowpass : echo <: _,_;

process = hgroup("Synth", synth);
