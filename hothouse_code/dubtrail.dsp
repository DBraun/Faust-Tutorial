import("stdfaust.lib");

bpm = hslider("[0] BPM", 99, 60, 180, 0.5);
feedbackAmt = hslider("[1] Feedback [knob:1]", 0.5, 0, 0.95, .01);
// delayBars = nentry("[2] Delay Length [knob:2][unit:bars][style:menu{'1/32':32;'1/16':16;'1/8':8;'1/4':4;'1/2':2;'1bar':1}]",1,1,32,.0001) : 1/_;
delayBars = nentry("[2] Delay Length [knob:2][unit:bars]",0,0,5,.0001) : pow(2, _-5);
dryWet = hslider("[3] Dry/Wet [knob:3]", 1, 0, 1, .01);
finalGain = hslider("[4] Post-Gain [knob:4][unit:db]", 0, -6, 6, .01) : ba.db2linear;

bar2samp(bars) = bars*(240*ma.SR/(bpm));

MAX_DELAY_BARS = 1;
MAX_DELAY_SAMPS = bar2samp(MAX_DELAY_BARS);

delayLength = bar2samp(delayBars);

myDelay = de.fdelayltv(3, MAX_DELAY_SAMPS, delayLength);

env = en.asr(attack, sustain, release, button("[4] Gate [foot:2]"))
with {
    attack = 0.01;
    sustain = 1;
    release = 0.1;
};

dubTrail(x) = x*env : myDelay : ((+ : _*(1-env))) ~ (myDelay:_*feedbackAmt) :_+x*env : _*finalGain;

// process = dubTrail <: _,_; // mono version for development
process = vgroup("Dub Trail", ef.dryWetMixerConstantPower(dryWet, (dubTrail, dubTrail)));
