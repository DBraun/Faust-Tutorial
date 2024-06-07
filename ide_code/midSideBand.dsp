import("stdfaust.lib");

// This demo has an interesting use of pattern matching.
// Note that the `width` parameter appears three times in the GUI,
// once for each band.

// use UI elements freely here:
fx_multiband = hgroup("Multiband FX", ms_processors)
with {

    // Crossover frequencies in Hertz
    CROSS(x) = vgroup("[0] Crosses", x);
    cf1 = CROSS(hslider("[1] Cross Low [unit:Hz]", 120, 20, 5000, 1));
    cf2 = CROSS(hslider("[0] Cross High [unit:Hz]", 5000, 20, 18000, 1));

    width = hslider("[0] Width [style:knob][tooltip:At w=0, the output signal is mono ((left+right)/2 in both channels). At w=1, there is no effect (original stereo image). Thus, w between 0 and 1 varies stereo width from 0 to original]", 1, 0, 1, .01);
    ms_processor = ef.stereo_width(width);

    ms_processor_i(0) = vgroup("[2] Low", ms_processor);
    ms_processor_i(1) = vgroup("[3] Mid", ms_processor);
    ms_processor_i(2) = vgroup("[4] High", ms_processor);

    ms_processors = par(i, 2, fi.crossover3LR4(cf1, cf2)) : ro.interleave(3,2) : par(i, 3, (ms_processor_i(i))) :> _, _;
};

process = fx_multiband;
