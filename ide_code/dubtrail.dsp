import("stdfaust.lib");

bpm = hslider("[0] BPM", 99, 60, 180, 0.5);
feedbackAmt = hslider("[1] Feedback [knob:1]", 0.5, 0, 0.95, .01);
delayBars = nentry("[2] Delay Length [knob:2][unit:bars][style:menu{'1/32':1/32;'1/16':0.0625;'1/8':.125;'1/4':.25;'1/2':0.5;'1bar':1}]",0,0,770,1);
dryWet = hslider("[3] Dry/Wet [knob:3]", 1, 0, 1, .01);

bar2samp(bars) = bars*(240*ma.SR/(bpm));

MAX_DELAY_BARS = 1;
MAX_DELAY_SAMPS = bar2samp(MAX_DELAY_BARS);

delayLength = bar2samp(delayBars);

myDelay = de.fdelayltv(3, MAX_DELAY_SAMPS, delayLength);

env = en.asr(.01, 1, .1, button("[4] Gate [foot:2]"));

dubTrail(x) = x*env : myDelay : ((+ : _*(1-env))) ~ (myDelay:_*feedbackAmt) :_+x*env;

// process = dubTrail <: _,_; // mono version for development
process = vgroup("Dub Trail", ef.dryWetMixer(dryWet, (dubTrail, dubTrail)));
