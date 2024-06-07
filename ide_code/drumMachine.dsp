//-------------------------------------------------
// 		A simple, fully generative
//		drum machine
//-------------------------------------------------

// DBraun modified this from:
// https://github.com/grame-cncm/faust/blob/master-dev/examples/misc/drumkit.dsp

// todo:
// how to sequence velocity?
// swing?

N_VOICES = 2; // multiple voices so that multiple kick hits can overlap
N_BEATS = 16; // divisions in a measure

declare name "DRUM MACHINE";

import("stdfaust.lib");

// `measure`: a linear ramp from 0 to 1 where 0 is the start of a measure and 1 is the end.
// `measurePulse`: a single sample pulse when `measure` goes to 0
// `measureTotal`: the total number of measures elapsed.
clock = vgroup("Clock", (measure, measurePulse, measureTotal))
with {
    bpm = hslider("BPM", 120, 60, 240, 1);
    reset = button("Reset") : ba.impulsify;
    resetPhase = 0;
    measure = os.lf_sawpos_phase_reset(bpm/240.,resetPhase,reset);
    measurePulse = measure < measure';
    measureTotal =  _ ~ ( _ + (measurePulse))*(1-reset);
};

// `VOICES`: Number of voices of polyphony (constant integer greater than 0)
// `g`: a single sample pulse "gate"
voicer(VOICES, g) = g : ba.selectoutn(VOICES, voiceId)
letrec {
    'voiceId = (voiceId+g)%VOICES;
};

// `VOICES`: Number of voices of polyphony (constant integer greater than 0)
// `BEATS`: Number of beat subdivisions in a measure (constant integer expression). 4 is typical.
// `instrument`: A sound generator with 1 input and 2 outputs. The input is a single sample pulse "gate".
drumkit(VOICES, BEATS, instrument, measure, measurePulse, measureTotal) = sequencer(boxes) <: instruments :> _, _
with {
    beatIndex = floor(measure*BEATS);
    gate = beatIndex != beatIndex';

    boxes = par(i, BEATS, checkbox("h:[0] z/%2i")); // todo: how to get rid of z here?
    monitor = par(i, BEATS, hbargraph("h:[1] seq/%2i [style:led]", 0, 1)); // todo: how to get rid of seq here?
    nn = 1 : ba.selectoutn(BEATS, beatIndex) : monitor :> _;

    sequencer(t) = t : ba.selectn(BEATS, beatIndex) : *(attach(gate, nn) : mem) : voicer(VOICES);
    instruments = par(i, VOICES, instrument <: _, _);
};

// Sine-tone kick drum
// `g`: a single sample pulse "gate"
kick(g) = g : env : _*os.osc(100) <: _, _
with {
    // todo: what ui grouping makes most sense for Release
    release = hslider("Release", .05, .01, .2, .001);
    env = en.ar(0.001, release);
};

drumkit_ui_demo = clock : vgroup("Kick", drumkit(N_VOICES, N_BEATS, kick));

process = drumkit_ui_demo;
