import("stdfaust.lib");

// Note: this example uses extensive widget modulation:
// https://faustdoc.grame.fr/manual/syntax/#widget-modulation

//------------------------------------------------------------
// Reverb ported from the Vital synthesizer.
//
// #### Parameters
//
// * `Knob 1`: Chorus Amount
// * `Knob 2`: Chorus Rate
// * `Knob 3`: Dry/Wet
// * `Knob 4`: Pre-Delay Duration
// * `Knob 5`: Decay Time
// * `Knob 6`: Room "Size"
// * `Foot 2`: Toggle effect
// * `Toggle 1`: Pre-filter modes. L: lowpass. M: passthrough. H: highpass
// * `Toggle 2`: Filter Low Shelf. L: low gain. M: mid gain. H: high gain.
// * `Toggle 3`: Filter High Shelf. L: low gain. M: mid gain. H: high gain.
//------------------------------------------------------------

toggle1 = ba.selectn(3, nentry("Toggle 1 [toggle:1]", 0, 0, 2, 1));
toggle2 = ba.selectn(3, nentry("Toggle 2 [toggle:2]", 0, 0, 2, 1));
toggle3 = ba.selectn(3, nentry("Toggle 3 [toggle:3]", 0, 0, 2, 1));

vital_rev = [
    "h:Chorus/Amount": hslider("Amount [style:knob][knob:1]", 0.01, 0, 1, .01),
    "h:Chorus/Rate": hslider("Rate [style:knob][knob:2]", 0.1, 0, 1, .01),
    "Mix": hslider("[4] Mix [style:knob][knob:3]", 1, 0, 1, .01),
    "h:Space/Pre-Delay": hslider("Pre-Delay [style:knob][knob:4]", 0, 0, 1, .01),
    "h:Space/Decay Time": hslider("Decay Time [style:knob][knob:5]", 0.5, 0, 1, .01),
    "h:Space/Size": hslider("Decay Time [style:knob][knob:6]", 0.5, 0, 1, .01),
    "h:Pre-filter/Low Cutoff": ((0, 0, 0.5) : toggle1),
    "h:Pre-filter/High Cutoff": ((0.5, 1, 1) : toggle1),
    "h:Filter/Low Shelf": ((0.5, 0.5, 0.5) : toggle2),
    "h:Filter/Low Gain": ((0.5, 0.75, 1) : toggle2),
    "h:Filter/High Shelf": ((0.5, 0.622, 0.622) : toggle3),
    "h:Filter/High Gain": ((0.5, 0.75, 1) : toggle3)
    -> dm.vital_rev_demo];

process = ba.bypass2(1-checkbox("Enable [foot:2]"), vital_rev);
