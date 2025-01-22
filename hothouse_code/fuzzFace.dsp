import("stdfaust.lib");

//---------fuzzFace-------------------------------------------------
// Two transistor stages (modeled with chua) output volume control.
// This was made with the help of Claude, so it likely has mistakes.
//
// #### Usage
//
// ```
// _ : fuzzFace : _
// ```
//------------------------------------------------------------------
fuzzFace(in1) = wd.buildtree(tree)
with {
    // Input stage - reduced capacitor value
    vs1(i) = wd.resVoltage(i, 1000, in1*5000);// Input source. 5000 is arbitrary.
    c1(i) = wd.capacitor(i, 0.1*pow(10,-6));  // Reduced to 0.1uF from 2.2uF
    r1(i) = wd.resistor(i, 33000);            // First base bias
    r2(i) = wd.resistor(i, 100000);           // First base to ground
    
    // First stage components - reduced bypass cap
    rc1(i) = wd.resistor_Vout(i, 8200);       // First collector
    re1(i) = wd.resistor(i, 470);             // First emitter
    ce1(i) = wd.capacitor(i, 1*pow(10,-6));   // Reduced to 1uF from 20uF
    
    // Nonlinear element - adjusted parameters
    nl1(i) = wd.u_chua(i, 0.1, 0.2, 0.1);    // Modified for different response
    
    // Build subtrees
    input_stage = wd.series : (vs1, (wd.series : (c1, (wd.parallel : (r1, r2)))));
    emitter_stage = wd.parallel : (re1, ce1);
    
    // Main connection tree
    tree = nl1 : wd.parallel : (
        input_stage,
        (wd.parallel : (rc1, emitter_stage))
    );
};

process = ef.dryWetMixerConstantPower(wet, (monoFX,monoFX))
with {
    monoFX = _*gain : fuzzFace;
    gain = hslider("Gain [style:knob][knob:1][unit:dB]", 0, -80, 12, .01) : ba.db2linear;
    postGain = hslider("Post Gain [style:knob][knob:3][unit:dB]", 0, -80, 12, .01) : ba.db2linear;
    wet = hslider("Dry/Wet [style:knob][knob:2]", 1, 0, 1, .01);
};
