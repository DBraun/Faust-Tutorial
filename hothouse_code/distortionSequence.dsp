import("stdfaust.lib");

/*
An insane sequence of 3 distortion units...
Each unit is a vertical column on the pedal
containing two knobs and a toggle.
The top knob is always an pre-gain to the unit.
We'll now describe the "bottom" slider and toggle for each column.

Col 1: Slider increases the amount of wavefolder distortion.
       Toggle selects between no effect, softclip quadratic, and hardclip
Col 2: Slider increases the amount of time-domain downsampling.
       Toggle selects between no effect, asinh2, and sinarctan2. 
Col 3: Slider increases the amount of bit-crushing.
       Toggle selects between no effect, hyperbolic, and tanh. 
*/

unit(i) = _*preGain : ba.selectmulti(1024, (circuit1(i), circuit2(i), circuit3(i)), toggle) : secondary(i)
with {
    preGain = sliderTop : it.remap(0, 1, -12, 12) : ba.db2linear;

    // column 1
    circuit1(i) = _;
    circuit2(0) = aa.softclipQuadratic2;
    circuit3(0) = aa.hardclip2;

    // column 2
    circuit2(1) = aa.asinh2;
    circuit3(1) = aa.sinarctan2;

    // column 3
    circuit2(2) = aa.hyperbolic2;
    circuit3(2) = aa.tanh1;

    secondary(0) = ef.wavefold(sliderBottom);
    secondary(1) = ba.downSampleCV(sliderBottom);
    secondary(2) = ba.mulaw_bitcrusher(255, it.remap(0, 1, 32, 8, sliderBottom));

    // helpers:
    j = i+1;
    k = j + 3;
    sliderTop = hslider("h:[0] top/Slider %j [knob:%j][style:knob]", 0.5, 0, 1, .01);
    sliderBottom = hslider("h:[1] bot/Slider %k [knob:%k][style:knob]", 0, 0, 1, .01);
    toggle = nentry("h:[2] toggles/Toggle %j [toggle:%j]", 0, 0, 2, 1);
};

monoFX = seq(i, 3, unit(i));

// process = hgroup("Chain", monoFX);
process = vgroup("Pedal", ba.bypass2(1-checkbox("[3] Enable [foot:2]"), (monoFX, monoFX)));
