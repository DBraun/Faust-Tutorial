import("stdfaust.lib");

declare tapeStop_demo author "David Braun";
declare tapeStop_demo copyright "Copyright (C) 2024 by David Braun <braun@ccrma.stanford.edu>";
declare tapeStop_demo license "MIT-style STK-4.3 license";

tapeStop_demo = hgroup("Tape Stop", ef.tapeStop(2, LAGRANGE_ORDER, MAX_TIME_SAMP, crossfade, gainAlpha, stopAlpha, stopTime, stop))
with {
    LAGRANGE_ORDER = 2;
    MAX_TIME_SEC = 4;
    MIN_TIME_SEC = 0.01;
    MIN_ALPHA = .01;
    MAX_ALPHA = 2;

    MAX_TIME_SAMP = MAX_TIME_SEC : ba.sec2samp;
    msec2samp = _/1000 : ba.sec2samp;

    stop = button("[0] Stop [foot:2]");
    stopTime = hslider("[1] Stop Time [knob:1][style:knob][unit:ms]", 100, MIN_TIME_SEC*1000, MAX_TIME_SEC*1000, 1) : msec2samp;
    stopAlpha = hslider("[2] Stop Alpha [knob:2][style:knob][tooltip:Alpha==1 represents a linear deceleration (constant force). Alpha<1 represents an initially weaker, then stronger force. Alpha>1 represents an initially stronger, then weaker force.]", 1, MIN_ALPHA, MAX_ALPHA, .01);
    gainAlpha = hslider("[3] Gain Alpha [knob:3][style:knob][tooltip:During the tape-stop, lower alpha stays louder longer]", 1, MIN_ALPHA, MAX_ALPHA, .01);
    crossfade = hslider("[4] Crossfade [knob:4][style:knob][unit:ms][tooltip:Crossfade to apply when resuming normal playback.]", 3, 0, 125, 1) : msec2samp;
};

process = tapeStop_demo;
