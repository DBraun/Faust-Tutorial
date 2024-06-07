import("utils.lib");

OUTERMAX = 0.6;
INNERMIN = 0.4;

// In the functions below, we use the equation `y=bias_curve(b,x)`.
// `b`: bias between 0 and 1. Bias of 0.5 results in `y=x`. Bias above 0.5 pulls y upward.
// `x`: input between 0 and 1 that needs to be remapped/biased into `y`
// `y`: `x` after it has been biased. Note that `(y==0 iff x==0) AND (y==1 iff x==1)`.
bias_curve(b,x) = (x / ((((1.0/b) - 2.0)*(1.0 - x))+1.0));

downsample(drive) = ba.sAndH(hold)
with {
    // If amt is 0, then freq should be ma.SR/2.
    // If amt is 1, then freq should be 491.
    // 491 is derived from listening to the Serum synthesizer.
    freq = drive : it.remap(0, 1, ba.hz2midikey(ma.SR/2), ba.hz2midikey(491)) : ba.midikey2hz;
    hold = ba.time%int(ma.SR/freq) == 0;
};

// None
tableReadNone(wtable, phase, warp, warp_external) = wtable(phase);

// sync no window:
tableReadSync(wtable, phase, warp, warp_external) = wtable(pct)
with {
    pct = phase*it.interpolate_linear(pow(warp,3), 1, 16);
};

tableReadSyncHalfWindow(wtable, phase, warp, warp_external) = wtable(pct)*window
with {
    pct = phase*it.interpolate_linear(pow(warp,3), 1, 16);
    window = cos(2*ma.PI*max(0, (abs(phase-.5)-.25)));
};

tableReadSyncFullWindow(wtable, phase, warp, warp_external) = wtable(pct)*window
with {
    pct = phase*it.interpolate_linear(pow(warp,3), 1, 16);
    window = sin(ma.PI*phase);
};

// bend +
tableReadBendPlus(wtable, phase, warp, warp_external) = wtable(pct)
with {
    pct = .5+ba.if(phase>.5,.5,-.5)*bias_curve(.5+.4*warp, abs(phase-.5)*2);
};

// bend -
tableReadBendMinus(wtable, phase, warp, warp_external) = wtable(pct)
with {
    pct = .5+ba.if(phase>.5,.5,-.5)*bias_curve(.5-.4*warp, abs(phase-.5)*2);
};

// bend +/-
tableReadBendPlusMinus(wtable, phase, warp, warp_external) = wtable(pct)
with {
    pct = .5+ba.if(phase>.5,.5,-.5)*bias_curve(it.interpolate_linear(warp, 0.9, 0.1), abs(phase-.5)*2);
};

// pulse-width modulation (PWM)
tableReadPWM(wtable, phase, warp, warp_external) = wtable(pct)
with {
    pct = phase : it.remap(0, 1.-0.9999*warp, 0, 1) : aa.clip(0,1);
};

// asym +
tableReadAsymPlus(wtable, phase, warp, warp_external) = wtable(pct)
with {
    mid = .5-warp*3/8;
    pct = phase : bpf.start(0,0) : bpf.point(mid,.5) : bpf.end(1,1);
};

// asym -
tableReadAsymMinus(wtable, phase, warp, warp_external) = wtable(pct)
with {
    mid = .5+warp*3/8;
    pct = phase : bpf.start(0,0) : bpf.point(mid,.5) : bpf.end(1,1);
};

// asym +/-
tableReadAsymPlusMinus(wtable, phase, warp, warp_external) = wtable(pct)
with {
    mid = .5+it.interpolate_linear(warp, -1, 1)*3/8;
    pct = phase : bpf.start(0,0) : bpf.point(mid,.5) : bpf.end(1,1);
};

// FM
tableReadFM(wtable, phase, warp, warp_external) = wtable(pct)
with {
    pct = phase + warp*warp_external;
};

// Amplitude-modulation (AM)
tableReadAM(wtable, phase, warp, warp_external) = wtable(pct) * it.interpolate_linear(warp, 1, abs(warp_external))
with {
    pct = phase;
};

// Ring modulation
tableReadRM(wtable, phase, warp, warp_external) = wtable(pct) * it.interpolate_linear(warp, 1, warp_external)
with {
    pct = phase;
};

// Flip modulation
// warp of 0 and 1.0 should have no effect. 0.5 should negate the entire wavetable.
tableReadFlip(wtable, phase, warp, warp_external) = wtable(pct) <: ba.if( (phase-warp*2<0)&(phase-warp*2>-1) , -1*_, _)
with {
    pct = phase;
};

// Quantize.
// todo: this isn't exactly the same as Serum.
tableReadQuantize(wtable, phase, warp, warp_external) = wtable(pct) : downsample(warp)
with {
    pct = phase;
};

// Mirror
tableReadMirror(wtable, phase, warp, warp_external) = tableReadAsymPlusMinus(phase2, warp, warp_external)
with {
    phase2 = 1-2*abs(phase-0.5);
};

// return 0 for right, 0.5 for center, 1 for left
// N is [1-16]
// todo: this needs a global panning parameter.
serum_panning(N, i) = if(N%2==0, panEven, panOdd)
with {
    two_cond(conda, a, condb, b, c) = if(conda, a, if(condb, b, c));

    panEven = if(i%2==0, 0, 1);

    panOdd = two_cond(i == (N-1)/2, 0.5, i < N/2, if(i%2==0, 0, 1), if(i%2==1, 0, 1));
};

// * `N`: number of unison voices [1-16]
oscillator(N, warp_mode, wtable, _freq, gate, _octave, _semi, _fine, _coarse, _detune, _blend, _phase, _rand, _wtpos, _warp, _pan, _vol, _warp_external) = 
    par(i, N, voice(i)) :> sp.stereoize(_*vol)
with {

    tableReader(0) = tableReadNone;

    tableReader(1) = tableReadSync;
    tableReader(2) = tableReadSyncHalfWindow;
    tableReader(3) = tableReadSyncFullWindow;

    tableReader(4) = tableReadBendPlus;
    tableReader(5) = tableReadBendMinus;
    tableReader(6) = tableReadBendPlusMinus;

    tableReader(7) = tableReadPWM;

    tableReader(8) = tableReadAsymPlus;
    tableReader(9) = tableReadAsymMinus;
    tableReader(10) = tableReadAsymPlusMinus;

    tableReader(11) = tableReadFlip;
    tableReader(12) = tableReadMirror;

    tableReader(13) = tableReadQuantize;

    tableReader(14) = tableReadFM;  // FM from other Osc
    tableReader(15) = tableReadAM;
    tableReader(16) = tableReadRM;
    tableReader(17) = tableReadFM;  // FM from Noise
    tableReader(18) = tableReadFM;  // FM from Sub

    octave = _octave : clampremap(0, 1, -4, 4) : round : _*12;
    semi   = _semi   : clampremap(0, 1, -12, 12) : round;
    fine   = _fine   : clampremap(0, 1, -100, 100) : round : _/100;
    coarse = _coarse : clampremap(0, 1, -64, 64);
    detune = _detune : aa.clip(0, 1) <: _*_;
    blend  = _blend  : aa.clip(0, 1);
    phase  = _phase  : aa.clip(0, 1);
    rand   = _rand   : aa.clip(0, 1);
    wtpos  = _wtpos  : aa.clip(0, 1);
    warp   = _warp   : aa.clip(0, 1);
    pan    = _pan    : aa.clip(0, 1);
    vol    = _vol    : volScale;

    voice(i) = tableReader(warp_mode, wtable(wtpos), pct, warp, _warp_external) : _*finalGain : sp.panner(finalPan)
    with {
        detune_ratio = i : it.remap(0, max(1, N-1), -detune_range*detune, detune_range*detune) : ba.semi2ratio : if(N>1, _, 1);
        freq = _freq * detune_ratio * ba.semi2ratio(octave+semi+fine+coarse);
        noteOn = gate & (gate'==0);
        pct = m_hsp_phasor(freq, noteOn, phase+no.noise*rand); // todo: use no.rnoise (it's hard to use on Windows)

        centerAmp = it.interpolate_linear(blend, 1, INNERMIN);
        detunedAmp = it.interpolate_linear(blend, 0, OUTERMAX);

        adjustment = 1/sqrt(centerAmp*centerAmp*nCenterVoices + detunedAmp*detunedAmp * nDetunedVoices)
        with {
            nCenterVoices = if((N%2)==1,1,2);
            nDetunedVoices = N-nCenterVoices;
        };

        finalGain = if(N>1,
            if((((N%2)==1) & (i == (N-1)/2)) | (((N%2)==0) & ((i == N/2) | (i+1 == N/2))), centerAmp, detunedAmp) * adjustment,
            1
        );

        finalPan = serum_panning(N, i) + (2*pan-1) : aa.clip(0, 1);
    };
};

oscillator_ui(i, N, warp_mode, wtable, warp_external) = tgroup("[1] Oscillators", hgroup("Osc %i",
    oscillator(N, warp_mode, wtable, freq, gate, octave, semi, fine, coarse, detune, blend, phase, rand, wtpos, warp, pan, gain*vol, warp_external)))
with {

    freq = hslider("freq [style:knob]", 440, .01, 20000, .1);
    gain = hslider("gain [style:knob]", 0, 0, 1, .01);
    gate = hslider("gate [style:knob]", 0, 0, 1, .01);

    octave = hslider("[1] Octave [style:knob]", .5  , 0    , 1   ,  .01);
    semi   = hslider("[2] Semi [style:knob]"  , .5  , 0    , 1   ,  .01);
    fine   = hslider("[3] Fine [style:knob]"  , .5  , 0    , 1   ,  .01);
    coarse = hslider("[4] Coarse [style:knob]", .5  , 0    , 1   ,  .01);
    detune = hslider("[5] Detune [style:knob]", .5  , 0    , 1   ,  .01);
    blend  = hslider("[6] Blend [style:knob]" , .75 , 0    , 1   ,  .01);
    phase  = hslider("[7] Phase [style:knob]" , .5  , 0    , 1   ,  .01);
    rand   = hslider("[8] Rand [style:knob]"  , 1   , 0    , 1   ,  .01);
    wtpos  = hslider("[9] WT Pos [style:knob]", 0   , 0    , 1   ,  .01);
    warp   = hslider("[10] Warp [style:knob]" , 0   , 0    , 1   ,  .01);
    pan    = hslider("[11] Pan [style:knob]"  ,.5   , 0    , 1   ,  .01);
    vol    = hslider("[12] Level [style:knob]", 0   , 0    , 1   ,  .01) + en.adsr(.01, .01, 1, .1, gate);
};

process = oscillator_ui(0, N_VOICES, WARP_MODE, wtable, warp_external)
with {
    N_VOICES = 1;
    WARP_MODE = 5; // compile-time constant (try 4, 5)
    warp_external = 0; // only matters if the warp mode is FM
    wtable(x, y) = sin(y*2*ma.PI);  // sine
    // wtable(x, y) = -1+2*ma.frac(y); // sawtooth
};
