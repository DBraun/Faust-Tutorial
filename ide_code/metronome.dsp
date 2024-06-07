import("stdfaust.lib");

// (beat, measure, hypermeasure)
dims = (4, 4, 4);
// dims = (5, 4, 3, 2);

// The product of multiple signals
product(numbers) = rm.parReduce(*, outputs(numbers), numbers);

//----------------metronome--------------------------
// Output a multi-dimensional representation of a metronome where the first output
// channel is the smallest unit of time, the second is the second smallest, and so on.
// This function doesn't hold a state. Instead it takes an integer state `x` and slices
// it into the requested dimension shape.
//
// #### Usage
//
// ```
//    _ : metronome(dims) : _,_,_
// ```
//
// Where:
//
// * `dims`: a list of input dimensions. The first channel represents the number of units in the smallest
//  time division such as the number of beats in a measure. The second channel represents the number of
//  measures in a hypermeasure, and so on.
// * `x`: a single-dimension index integer where `0 <= x <= product(dims)-1`.
//
// #### Example test program
//
// ```
// process = _ : metronome((4,4,4)) : _, _, _;
// ```
//
//-----------------------------------------------------
metronome(dims, x) = x : seq(i, N-1, layer(i))
with {
    N = outputs(dims);
    myOp(dim, x) = x%dim, floor(x/dim);
    layer(i) = si.bus(i), myOp(ba.take(i+1, dims));
};

declare metronome author "David Braun";
declare metronome license "MIT";

metronomeUI(dims) = vgroup("Metronome", par(i, N, row(i)))
with {
    N = outputs(dims);
    _row(i) = seq(j, ba.take(i+1, dims), col(j))
    with {
        col(j, v) = attach(v, (v==j : hbargraph("%k [style:led]", 0, 1)))
        with {
            k = j+1;
        };
    };
    row(0) = hgroup("[0] Beat", _row(0));
    row(1) = hgroup("[1] Measure", _row(1));
    row(2) = hgroup("[2] Hypermeasure", _row(2));
    row(3) = hgroup("[3] Hyper-hypermeasure", _row(2));
};
declare metronomeUI author "David Braun";
declare metronomeUI license "MIT";

freq = hslider("BPM", 120, 60, 360, 1)/60;

process = os.lf_imptrain(freq) : ba.pulse_countup_loop(product(dims)-1, 1) : metronome(dims) : metronomeUI(dims);
// process = _ : metronome((4,4,4)) : _, _, _;