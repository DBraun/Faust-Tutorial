/*
This is a lowpass gate that uses a Butterworth filter. The amplitude of the input signal is sent to an envelope follower, which drives the filter cutoff frequency. A random LFO is sent to a lowpass filter which modulates a single delay time, creating pitch modulation. 'Damp' controls the amount of filtering of the random signal.

inspiration:
https://www.native-instruments.com/en/reaktor-community/reaktor-user-library/entry/show/13091/
https://twitter.com/imagi_ro/status/1552950734831878145
*/

import("stdfaust.lib");

MAXDELAY = .004 * ma.SR; // MAXDELAY is in samples units. Used in the delayByNoise.

//---------------`(ef.)delayByLFO`--------------------------
// Delay according to LFO with controllable rate and depth
//
// #### Usage
//
// ```
// _ : delayByLFO(MAXDELAY, DELAYORDER, rate, depth) : _
// ```
//
// Where:
//
// * `MAXDELAY`: Maximum delay amount in samples (constant numerical expression)
// * `DELAYORDER`: The order of the Lagrange interpolation polynomial (constant numerical expression)
// * `rate`: Rate of LFO, measured in hertz
// * `depth`: The depth of variation in the delay amount. [0-1]
//
// Example:
// ```
// delayByLFOGui = 
//     hslider("[0]Rate[unit:Hz]", .5, 0., 5.0, .00001),
//     hslider("[1]Depth", .1, 0., 1., .00001): 
//     delayByLFO(50 * .001 * ma.SR, 5);
// ```
//------------------------------------------------------------
declare delayByLFO author "David Braun";

delayByLFO(MAXDELAY, DELAYORDER, rate, depth) = delay
with {
    MINDELAY = (DELAYORDER-1)/2+1;
    delayAmt = os.osc(rate) * depth : aa.clip(-1,1) : it.remap(-1., 1., MINDELAY, MAXDELAY);
    delay = de.fdelayltv(DELAYORDER, MAXDELAY, delayAmt);
};


//---------------`(ef.)delayByNoise`-------------------------------------------------
// A time-varying delay effect where a low-frequency noise controls the delay amount.
// The noise has controllable rate, depth, and dampening.
//
// #### Usage:
//
// ```
// _ : delayByNoise(.004*ma.SR, 3, rate, damp, depth) : _
// ```
//
// Where:
//
// * `MAXDELAY`: Maximum delay amount in samples (constant numerical expression)
// * `DELAYORDER`: The order of the Lagrange interpolation polynomial (constant numerical expression)
// * `rate`: The rate (Hz) of the noise oscillator. Values between 1 and 100 are suggested.
// * `damp`: The dampening of the noise oscillator. [0-1] where 1 is the most dampening.
// * `depth`: The depth of variation in the delay amount. [0-1]
//
//------------------------------------------------------------
declare delayByNoise author "David Braun";

delayByNoise(MAXDELAY, DELAYORDER, rate, damp, depth) = delay
with {
    MINDELAY = (DELAYORDER-1)/2+1;
    noiseCutoff = it.interpolate_linear(damp, 30., 2.);
    rawNoise = no.lfnoise0(rate);
    delayAmt = rawNoise * depth : fi.lowpass(4, noiseCutoff) : aa.clip(-1,1) : it.remap(-1., 1., MINDELAY, MAXDELAY);
    delay = de.fdelayltv(DELAYORDER, MAXDELAY, delayAmt);
};


filterByAmpFollower(i, gain, followAttack, followRelease, freq, x) = filter
with {
    ampFollow = x : *(gain) : aa.clip(-1, 1) : an.amp_follower_ar(followAttack, followRelease)
        // <: attach(_, vbargraph("h:Meters/h:Amp Follow/%i",0.,1.))
    ;
    cutoffFreq = (freq:ba.midikey2hz)+ampFollow*ma.SR*.5 : aa.clip(30, ma.SR*.45)
        // <: attach(_, vbargraph("h:Meters/h:Filter Freq/%i",20, 20000))
    ;
    filter = x : fi.lowpass(4, cutoffFreq);
};

// Fairfield Circuitry - Shallow Water
// This is a stereo effect inspired by Fairfield Circuitry's Shallow Water effects pedal.
// The effect is a time-varying delay followed by a low-pass filter.
// A low-frequency noise controls the delay amount.
// The noise's rate, dampening and depth are controllable.
// An amplitude follower controls the filter's cutoff frequency.
// The amplitude follower's gain, attack, and release are controllable.
//
// #### Usage:
//
// ```
// _,_ : fairfieldCircuitryShallowWater(folGain, folAtt, folRel, freq, rate, damp, depth, wet) : _,_
// ```
//
// Where:
//
// * `folGain`: The gain of the signal sent to the amplitude follower. [0-1]
// * `folAtt`: The attack time (sec) of the amplitude follower.
// * `folRel`: The release time (sec) of the amplitude follower.
// * `freq`: The MIDI pitch of the lowest the filter cutoff will be.
// * `rate`: The rate (Hz) of the noise oscillator. Values between 1 and 100 are suggested.
// * `damp`: The dampening of the noise oscillator. [0-1] where 1 is the most dampening.
// * `depth`: The depth of variation in the delay amount. [0-1]
// * `wet`: The wetness of the effect. [0-1] where 1 produces only the wet signal.
//
// #### References:
//
// * <https://www.native-instruments.com/en/reaktor-community/reaktor-user-library/entry/show/13091/>
//------------------------------------------------------------
declare fairfieldCircuitryShallowWater author "David Braun";

fairfieldCircuitryShallowWater(folGain, folAtt, folRel, freq, rate, damp, depth, wet) = result
with {

    fairfieldChan(i) = delay : filter
    with {
        DELAYORDER = 3; // Quality of delay interpolation
        whiteNoise = no.noise*.0001;
        delay = delayByNoise(MAXDELAY, DELAYORDER, rate, damp, depth), whiteNoise :> _;
        filter = filterByAmpFollower(i, folGain, folAtt, folRel, freq);
    };

    result = ef.dryWetMixer(wet, (fairfieldChan(0), fairfieldChan(1)));
};

FairfieldCircuitryShallowWater = hgroup("Shallow Water", (filterPars, delayPars, wet)), si.bus(2) : fairfieldCircuitryShallowWater
with {
    
    delayPars = hgroup("[0] Delay",(
        (hslider("[0] Rate [style:knob][unit:Hz][knob:1]", 50., 1., 100., .0001) : si.smoo),
        (hslider("[1] Damp [style:knob][knob:2]", 0.5, 0., 1., .0001) : si.smoo),
        (hslider("[2] Depth [style:knob][knob:3]", .0, 0., 1., .00001) : si.smooth(ba.tau2pole(.5)))
    ));

    ampPars = hgroup("[0] Amp Follow", (
        (hslider("[0] Gain [style:knob][knob:4]", 0.1, 0., 1., .0001) : si.smoo),
        (hslider("[1] Attack [style:knob][unit:sec]", .2, 0., .4, .0001) : si.smoo),
        (hslider("[2] Release [style:knob][unit:sec]", .5, 0., 1., .0001) : si.smoo)
    ));

    filterPars = hgroup("[1] Filter",(
        ampPars,
        (hslider("[1] Filter Freq [style:knob][unit:pitch][knob:5]", 70., 20, 120., .0001) : si.smoo)
    ));

    wet = hgroup("[3] Mix", (hslider("Dry/Wet [style:knob][knob:6]", 1, 0, 1, .0001) : si.smoo));
};

process = ba.bypass2(checkbox("bypass [foot:2]"), FairfieldCircuitryShallowWater);
