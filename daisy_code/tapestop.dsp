import("stdfaust.lib");

LAGRANGE_ORDER = 1;
MAX_TIME_SEC = .3;
MIN_TIME_SEC = 0.01;
MIN_ALPHA = .01;
MAX_ALPHA = 2;
// sec2samp = ba.sec2samp;
sec2samp = _*44100.;
MAX_TIME_SAMP = MAX_TIME_SEC : sec2samp;

tapeStop(C, LAGRANGE_ORDER, MAX_TIME_SAMP, crossfade, gainAlpha, stopAlpha, stopTime, stop) = 
(tapeStopTick(C) ~ _) : !,si.bus(C)
with {
    tapeStopTick(C, _delaySamples) = delaySamples, circuitFinal
    with {
        // Where `stopCounter` goes from 0 to stopTime (or higher)
        // When `stopCounter` is 0, curve's output is 1.
        // When `stopCounter` is stopTime, curve's output is 0.
        curve(alpha) = 1-stopCounter/stopTime : max(0) : pow(_, alpha)
        with {
            // when stop is pulsed, count samples starting at 0
            stopCounter = *(ba.if(stop&(1-stop'),0,1))+1~_ : -(1);
        };
        minDelay = (LAGRANGE_ORDER-1)/2;
        delayFunc(curDel) = par(i, C, de.fdelay(MAX_TIME_SAMP, max(curDel, minDelay)));
        // delayFunc(curDel) = par(i, C, de.fdelayltv(LAGRANGE_ORDER, MAX_TIME_SAMP, max(curDel, minDelay)));

        delaySamples = ba.if(stop&(1-stop'), minDelay, _delaySamples) + delayDelta
        with {
            /*
            Velocity describes the velocity of the read-index in units of samples per sample.
            If the velocity is 1, then the read-index is moving as fast as the write-index
            is moving, and there is no delay. If the velocity is 0, then the read-index is "stuck"
            on a particular location. During a tape-stop, our technique is to animate velocity
            from 1 to 0 according to a curve based on stopAlpha. We discretize the accumulated
            delay with delayDelta. Note that when velocity is zero, then delayDelta is 1. At this
            moment the delay line wrote 1 new sample (as always), but our delayDelta INCREASED by one.
            This means it's playing same sample twice in a row, and the record player is motionless.
            When `stop` triggers by becoming 1, then delaySamples is reset to `minDelay`. At this moment
            we should have already been listening to the circuitNormal which is using `minDelay`.
            Therefore, there isn't a click.
            */
            velocity = curve(stopAlpha);
            delayDelta = 1-velocity;
        };

        circuitNormal = delayFunc(0); // Don't use si.bus(C) because of minDelay
        circuitSlowdown = delayFunc(delaySamples) : par(i, C, _*g)
        with {
            g = curve(gainAlpha);
        };
        circuitFinal = ba.selectmulti(actualCrossfade, (circuitNormal, circuitSlowdown), stop)
        with {
            actualCrossfade = ba.if(stop,0,crossfade); // only crossfade when resuming normal playback
        };
    };
};

tapeStop_demo = hgroup("Tape Stop", tapeStop(2, LAGRANGE_ORDER, MAX_TIME_SAMP, crossfade, gainAlpha, stopAlpha, stopTime, stop))
with {
    msec2samp = _/1000 : sec2samp;

    stop = button("[0] Stop");
    stopTime = hslider("[1] Stop Time [style:knob][unit:ms]", 100, MIN_TIME_SEC*1000, MAX_TIME_SEC*1000, 1) : msec2samp;
    stopAlpha = hslider("[2] Stop Alpha [style:knob][tooltip:Alpha==1 represents a linear deceleration (constant force). Alpha<1 represents an initially weaker, then stronger force. Alpha>1 represents an initially stronger, then weaker force.]", 1, MIN_ALPHA, MAX_ALPHA, .01);
    // gainAlpha = hslider("[3] Gain Alpha [style:knob][tooltip:During the tape-stop, lower alpha stays louder longer]", 1, MIN_ALPHA, MAX_ALPHA, .01);
    // crossfade = hslider("[4] Crossfade [style:knob][unit:ms][tooltip:Crossfade to apply when resuming normal playback.]", 3, 0, 125, 1) : msec2samp;
    gainAlpha = 1;
    crossfade = 3 : msec2samp;

};

// process = tapeStop_demo;

process = 
[
    "Stop": button("Stop [switch:2]"),
    // "Stop": 0,
    "Stop Time": hslider("Stop Time [knob:1]", 50, MIN_TIME_SEC*1000, MAX_TIME_SEC*1000, 1),
    "Stop Alpha": hslider("Stop Alpha [knob:2]", 1, MIN_ALPHA, MAX_ALPHA, .01)
    -> tapeStop_demo
];
