import("stdfaust.lib");

//------------------------------------------------------------
// Pitch shifter with 2 pitch shift lanes with controllable
// gain.
//
// #### Parameters
//
// * `Knob 1`: Pitch shift 1 in semitones
// * `Knob 2`: Pitch shift 2 in semitones
// * `Knob 3`: Dry/Wet
// * `Knob 4`: Gain for Pitch shift 1 in decibels
// * `Knob 5`: Gain for Pitch shift 2 in decibels
// * `Knob 6`: Post-gain in decibels
//------------------------------------------------------------

pitchShift(i) = ef.transpose(windowLength, crossfade, semi) : _*g
with {
    windowLength = 1024;
    crossfade = 512;
    j = i+1;
    k = i+4;
    semi = hslider("[%j] Semi %2j [knob:%j][unit:semi][style:knob]", 0, -12, 12, 1);
    g = hslider("[%k] Gain %2j [knob:%k][style:knob][unit:dB]", 0, -80, 12, .01) : ba.db2linear;
};

monoFX = _<:sum(i, 2, pitchShift(i));

postGain = hslider("[6] Post Gain [style:knob][knob:6][unit:dB]", 0, -80, 12, .01) : ba.db2linear;

stereoFX = monoFX, monoFX;
wet = hslider("[3] Dry/Wet [knob:3][style:knob]", 1, 0, 1, .01);
process = hgroup("Shifter", ef.dryWetMixerConstantPower(wet, stereoFX) : _*postGain, _*postGain);
