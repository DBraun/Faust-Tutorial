/*
This is a tutorial written by David Braun:
https://github.com/DBraun
*/

/*
Faust IDE overview:

More information about the online IDE is here: https://github.com/grame-cncm/faustide.
Let's cover just the basics for now.

Click the wrench icon above two hide the left panel. Click it again to show the left panel.
Do the same for the three dots in the upper right to hide and show the right panel.

Turn off the blue "Output is On" button in the lower right so that it becomes white.
Now press the triangle play button next to the wrench icon.
You should see an error at the bottom of the screen saying 
"???? : -1 : ERROR : undefined symbol : process".
This happens because the `tutorial.dsp` file is just a lot code that has been "commented out",
meaning it is inactive. Soon we'll write code so that this error goes away.
Before that, in the left panel, look for "Real-time Compile" and make it checked.
*/

// Now let's create a basic Faust program by "uncommenting" the code below.
// Simply remove the two forward slashes and space before the word "process".
// process = _,_;
// The error should go away and you should see a diagram with two horizontal lines.
// The diagram indicates that the program has 2 inputs and 2 outputs.
// The program doesn't modify the inputs. It simply passes them to the outputs.
// Every Faust program is just a different way of defining `process`.
// Note that we can only define process once.
// This tutorial uses comments to disable all of the definitions of process.
// To follow the tutorial, you basically enable and disable these definitions
// one at a time and see the results in the SVG diagram.
// Brief note on code comments:
// There are two kinds of comments in Faust.
// The first kind is a double slash, like what you're reading right now.
// The second is /*some comment*/ which is good for multi-line comments, like below
/*
This
is
a
long
comment!
*/
// Double-slash comments can be easily toggled.
// Highlight one or more lines with your mouse and then press command-/ to toggle them.
// Practice this with the definition of process about 22 lines above.
// Now leave that definition of process above enabled so that we can listen to it.

/*
In the right panel, enable output by toggling the button we disabled earlier so that it's blue.
Then look for the white-on-gray waveform in the right panel.
Look for the Loop button and toggle it on.
Look for the Play/Pause button and press it.
You should see an animated waveform in the "Input Analyzer".
However, you shouldn't hear anything yet. There's one more step!
Now, press the play button next to the wrench.
You should hear a marimba audio file repeating.
Use the horizontal slider directly below the Loop button to control the volume of the input.
Locate the "Output Analyzer" in the right panel and play with its modes.
In the lower section of the IDE, there are now 3 tabs: "Diagram", "Plot", and "DSP".
Press the "Popup" next to the DSP tab. This will open a window with the user interface
for the current DSP.
However, the current DSP doesn't have any parameters, so it's an uninteresting panel.
Now click the X next to the DSP panel. The output analyzer will disappear.

As you write code going forward, Real-time compile should be enabled.
This will help us find coding errors and SVG diagrams of the current code.
However, to hear audio again, you will have to click the Play button next to the wrench.
That's all you need to know about the IDE for now! We can move on to discussing Faust!
*/

// FAUST is a functional programming language for audio processing.
// Note that everything in Faust is a function. For example, consider this code:
// foo = 0;
// process = foo;

// It looks like "foo" is a variable, but it is really a function.
// It's a function that generates an infinite stream of zeros.
// Here's another:
// foo = sin;
// process = foo;

/*
In this case, foo is a function that takes a single channel of input and performs the trigonometric sine function on it.

sin is a built-in mathematical operator. We can also use common math operators like / + * -.
While using those, let's also introduce the identity operator, which is a single underscore.
It can also be called "wire".
It represents both one channel of input and one channel of output.
*/

// process = _;
// process = _+1;
// process = (_+1)*(_-1)+1;
// foo = _+1;
// bar = _-1;
// process = foo;
// process = foo(_);

// If foo and bar are defined like above, then these two are equivalent:
// process = foo*bar+1;
// process = foo(_)*bar(_)+1;

// How does one clamp a number to be greater than or equal to zero?
// This is called a "rectifier".
// We'll write the same function in three equivalent ways.
// They all take one input and produce the maximum of it and 0.
// We can say that these functions have one implicit argument each.
// process = rectifier;
// rectifier = max(0);
// rectifier = max(0, _);
// rectifier = max(_, 0); // different diagram but equivalent code.

// We can also refactor the code so that the argument is explicit:
// rectifier(x) = max(0, x);
// rectifier(x) = max(x, 0);

// Explicit arguments are generally preferred, but sometimes it's easier
// to use implicit arguments. For example, I wrote a Kalman filter in Faust
// (https://faustlibraries.grame.fr/libs/filters/#fikalman) that used
// implicit arguments. It would have been difficult otherwise.

// Note that in Faust, functions can be defined in any order! This is generally
// true for functional programming languages.

/*
The first example `max(0)` is an example of a partial application:
https://en.wikipedia.org/wiki/Partial_application
If you're not familiar with this concept, it's ok!
It will become second nature to you with Faust,
and this tutorial will cover it more later
*/

// Let's practice making functions.
// process = foo;
// Note that these are equivalent:
// foo(x, y) = x + y + _;  // two explicit arguments and one implicit argument
// foo(x, y, z) = x + y + z;  // three explicit arguments

// Takeaway: you can't just rely on the number of arguments to 
// determine the arity of a function.

/*
Let's dive into the core operators of Faust.
These are the essence of the "Block diagram algebra" of Faust.

These are the 5 "core" operators:

    ,    parallel
    :    sequence
    :>   merge
    <:   split
    ~    recurse

Let's show them one by one.
*/

/*
, parallel

Parallel takes any two functions and places them side by side.
The resulting number of inputs is the sum of the two functions' inputs.
The resulting number of outputs is the sum of the two functions' outputs.

process = A, B;

The number of inputs will be inputs(A) + inputs(B).
the number of outputs will be outputs(A) + outputs(B).
*/

// Uncomment the lines below, but only keep one active at a time.
// process = 0;
// process = 0, 0;
// process = _, 0;
// process = 0, _;
// process = abs;
// process = sin, tan;
// process = sin, floor, atan;
// process = sin(3.141593)*sqrt(1^2), tan(1+1-2);

/*
: sequence

The sequence operator "chains" or connects two functions.

process = A : B;

This requires that outputs(A) == inputs(B).

In the resulting function,
the number of inputs will be inputs(A).
The number of outputs will be outputs(B).

*/

// Examples:
// process = _ : _;
// process = _ : _ : _;
// process = _, _ : _, _;
// process = max(0) : min(1);
// process = _*4-1 : max(0);
// process = 0, 0 : sin, tan;
// process = 0, 1 : atan2;
// process = (0, 1) : atan2;
// process = (0), (1) : atan2;
// process = _, 1 : atan2;
// process = _ : 0, _;

// Now let's sequence while using functions.
// foo = 0, 0;
// bar = sin, tan;
// baz = floor, abs;
// process = foo : bar : baz;
// // which is equivalent to
// process = baz(bar(foo));

// If you're a programmer, chances are you've written code like
// `result = baz(bar(foo))`
// Isn't it nice to be able to write it as foo : bar : baz?

// More examples:
// foo = 0, 0;
// bar = sin, tan;
// baz = floor, abs;
// process = foo, bar, foo : baz, bar, baz;
// process = baz(foo), bar(bar), baz(foo);

// Note that we can do this
// foo = +;
// process = foo, foo;
// and we can do this:
// process = +, +;

/*
Time for the next operator, "merge", which is colon-greater-than.

:> merge

Merge is a variation of sequence where the outputs of A are a positive
integer multiple of inputs of B.

process = A :> B;

This requires that outputs(A) == k * inputs(B) for some integer k > 0.

In the resulting function,
the number of inputs will be inputs(A).
The number of outputs will be outputs(B).
*/

// Example:
// foo = 0, 0;
// bar = sin, tan;
// baz = floor, abs;
// process = bar, baz :> bar;
// process = foo, bar, baz :> bar;
// process = _,_ :> _;  // simple addition
// process = _,_,_,_ :> _, _;  // stereo addition

/*
<: split

Split is a variation of sequence where the inputs of B are a positive
integer multiple of outputs of A.

process = A <: B;

This requires that outputs(A) * k == inputs(B) for some integer k > 0.

In the resulting function,
the number of inputs will be inputs(A).
The number of outputs will be outputs(B).
*/

// Example
// foo = 0, 0;
// bar = sin, tan;
// baz = floor, abs;
// process = bar <: baz, baz;
// process = _ <: _,_;
// process = _,_ <: _,_,_,_;

// To summarize, sequence, merge, and split,
// all have something in common:
// In the resulting function,
// the number of inputs will be inputs(A).
// The number of outputs will be outputs(B).

/*
~ recurse

process = A ~ B;

Recurse makes feedback loops possible.
Each input of B is connected to the corresponding output of A via an implicit 1-sample delay.
Each output of B is connected to the corresponding input of A.

Requirements
* outputs(A) >= inputs(B) >= 1
* inputs(A) >= outputs(B) >= 1

Properties:
1. The number of inputs will be inputs(A) - outputs(B).
2. The number of outputs will be outputs(A).

I promise it's useful to think through these properties as you learn and use recurse.
To think through what is A~B, I like to start by thinking that the output circuit
will be similar to A because it will have the same number of outputs as A (property 2).
Then I think to myself B has some number of inputs (let's say N). B will take the first
N outputs of A. Then B's M outputs will be plugged into A's first M inputs, causing
property 1.
*/

// Here is a timer that goes up by one every sample, so don't listen to this!
// A = _;
// B = _+1;
// process = A ~ B;

// More examples:
// foo = sin, atan2;
// bar = abs, floor;
// process = foo;  // 3 inputs, 2 outputs
// process = bar;  // 2 inputs, 2 outputs
// process = foo ~ bar;
// process = foo ~ (bar : bar);
// process = foo ~ _;
// process = foo ~ (_<:_,_);
// process = foo ~ (_, _);

/*
We made it through the 5 operators!
Let's practice.
*/

// The following three are all equivalent:
// process = floor : atan2(_, 2);
// process = atan2(floor, 2);
// process = atan2(floor(_), 2);

// Note that some operators have implicit wires.
// Personally, I don't like this style.
// process = /(2); // this is valid
// but in my opinion, please just write
// process = _/2;
// Similarly, although you can write this:
// process = +2 : *(4);
// // please just write:
// process = _+2 : _*4;
// // or even better:
// process = (_+2)*4;
// Don't feel obligated to use tons of sequence operators.

// Now we can revisit the recurse operator:

// Recursive one-pole filter:
// The next output is the current input + 0.1 times the last output.
// "Difference equation":
// y(n) = x(n) + 0.1*y(n-1)

// A = +;
// B = _*0.1;
// process = A ~ B;

// Here's a stereo version:
// A = _, _, _, _ :> _, _;
// B = _*.1, _*.1;
// process = A ~ B;

// Here's another way to do stereo.
// A = +;
// B = _*0.1;
// foo = A~B;
// process = foo, foo;

/*
Next, let's learn about three ways to delay signals.

mem
'
@
*/

// These all delay a signal by exactly one sample.
// process = mem;
// process = _';
// process = @(1);

// When we use the recursive operator, this kind of one-sample delay is created automatically.

// Long delays are possible too:
// process = _ <: _, @(5000), @(6000) :> _;
// process = _, _ <: _, _, @(5000), @(6000) :> _, _;

// The faust compiler is very smart, so the first example above only uses ONE delay line
// with a maximum length of 6000 samples.
// The second example uses one delay line with a max length of 5000 and another delay line
// with a max delay line of 6000 samples. This is because the input signals are different,
// and the delay can't be shared.

// Note that this is not possible:
// process = _@(_);
// Faust must be able to calculate the bounds of the maximum of the delay.
// and in this case _ is unbounded.
// But this is ok:
// process = _, min(5000, max(0)) : _@(_);
// because the delay amount is in the bounds of 0 to 5000.

/*
Next, let's show the usage of !, which is the "cut" primitive.

It consumes one channel of input and produces 0 output channels.
*/

// Examples:
// process = 1, 2 : !, _;
// process = !, _, _, !;
// process = _, _ <: !, _, _, !;  // swap 2 channels
// foo = _, _ <: !, _, _, !;
// process = foo;
// process = foo : foo : foo;

/*
Let's review what we've learned with a few more examples.
*/

// These are equivalent:
// process(x, y) = sin(x), floor(y);
// process = sin, floor;

// These are equivalent:
// process(x) = sin(x), floor(x);
// process = _ <: sin, floor;

// // same as previous clever usage of ! to swap channels
// swap(x, y) = y, x;
// process = swap;

/*
In Faust, when writing a new function, there is a best practice for choosing the order of arguments.

foo(N, par1, par2, x) = .......

Compile-time constants should come first and be ALL CAPS. These don't necessarily need to be floats or integers.
They can be mathematical expressions that lead to constants.

The next set of arguments should be ones which you are likely to use in a partial application:
https://en.wikipedia.org/wiki/Partial_application

Typically, these arguments are not signals that you would want to listen to.

For example, the cutoff frequency of a filter fits in this category, whereas the signal
that you want to filter would fit in the last category.

The last category should be arguments that you are less likely to use in a partial application.
Typically, these are signals that you'd listen to.
*/

// Let's demonstrate this by showing a BAD example.
// import("stdfaust.lib");
// myFilter(x, cutoff) = fi.lowpass(1, cutoff, x);
// process = myFilter;

/*
Don't pay attention to the implementation of myFilter.
Just look at the order of its arguments.
It's meant to be a lowpass filter that takes a signal to be filtered and a cutoff frequency.
We put the signal first and the cutoff second, but this is bad practice.
What if we want to have a stereo filter where the left channel has a cutoff of 10 kHz,
and the right has a cutoff of 12 kHz? We'd have to do this:
*/

// import("stdfaust.lib");
// myFilter(x, cutoff) = fi.lowpass(1, cutoff, x);
// process = myFilter(_, 10000), myFilter(_, 12000);

// But what if we had set the args of myFilter differently?
// import("stdfaust.lib");
// myFilter(cutoff, x) = fi.lowpass(1, cutoff, x);
// process = myFilter(10000), myFilter(12000);

// Much better! Note that the following which removes `x` is equivalent:
// import("stdfaust.lib");
// myFilter(cutoff) = fi.lowpass(1, cutoff);
// process = myFilter(10000), myFilter(12000);

// More info on coding best practices here:
// https://faustlibraries.grame.fr/contributing

// Let's learn about using the `with` expression:
// The with construction allows to specify a local environment: a private list of definition that will be used to evaluate the left hand expression.
// The following is a simple and common use of "with": unit conversion.
// import("stdfaust.lib");
// volumeControl(decibels) = _*gain
// with {
//     gain = ba.db2linear(decibels); // some call this decibels to amplitude.
// };
// process = volumeControl(-6); // decrease a signal by 6 decibels.

/*
When you make a function involving recursion, you should remember that the first
arguments will be replaced by the outputs of the `B` expression in the recursion.

Let's demonstrate this and by introducing the `select2` primitive.

The select2 primitive is a "two-ways selector" that can be used to select between 2 signals.
_,_ : select2(s) : _,_
Where:
s: the selector (0 for the first signal, 1 for the second one)

We'll make a counter that goes up one whenever a trigger signal is positive.
*/
// import("stdfaust.lib");
// tick(state, t) = select2(t, state, state+1);
// process =  os.lf_imptrain(1) : (tick~_);

/*
Note that the `state` argument in `tick` came first because we anticipated that it would
be replaced due to the use of ~.
*/

// It can sometimes be more challenging to write the same code without using
// an explicit state argument. But note that this is one fewer line of code.
// import("stdfaust.lib");
// tick(t) = (_ <: select2(t, _, _+1)) ~ _;
// process =  os.lf_imptrain(1) : tick;

// Let's revisit the earlier one-pole filter example with this "Difference equation":
// y(n) = x(n) + 0.1*y(n-1)

// A = +;
// B = _*0.1;
// process = A ~ B;

// There's actually an extremely short implementation:
// onePoleFilter(pole) = +~*(pole);
// process = onePoleFilter(.1);

// The code above is pretty inscrutable, so let's refactor it:
// tick(pole, prev_y, x) = pole*prev_y+x;
// onePoleFilter(pole) = tick(pole)~_;
// process = onePoleFilter(0.1);
// The code above has the advantage of naming arguments.
// You might be able to see that tick(pole) produces something, which feeds back into the `prev_y` argument.

// Let's use the "with" syntax to make a local scope.
// onePoleFilter(pole) = tick(pole)~_
// with {
//     tick(pole, prev_y, x) = prev_y*pole+x;
// };
// process = onePoleFilter(0.1);

// The previous can be simplified to this:
// onePoleFilter(pole) = tick~_
// with {
//     tick(prev_y, x) = prev_y*pole+x;
// };
// process = onePoleFilter(0.1);

/*
Let's use the letrec syntax.
Suppose we have several mutually recursive signals A, B, C, and D.
Let each signal be a sawtooth oscillator which takes one input and has one output.
We want the output of oscillators B and C to go to oscillator A.
We want the output of oscillators A and D to go to oscillator B.
We want the output of oscillators B and D to go to oscillator C.
We want the output of oscillators A and C to go to oscillator D.
*/

// import("stdfaust.lib");
// // An over-simplified implementation of Sam Pluta's "Photokeratitis".
// process = a, b, c, d :> _*.1
// letrec {
//     'a = b + c : osc;
//     'b = a + d : osc;
//     'c = b + d : osc;
//     'd = a + c : osc;
// }
// with {
//     osc(v) = os.sawtooth(freq)
//     with {
//         freq = v : it.remap(-2, 2, 440, 5000);
//     };
// };

/*
Here's another tutorial on recursion that leads up to the letrec syntax.
https://www.dariosanfilippo.com/posts/2020/11/28/faust_recursive_circuits.html
*/

// Let's use a few more built-ins:
// First, the `par` built-in
// bus(N) = par(i, N, _);
// process = bus(1);
// process = bus(2);
// process = bus(4) :> bus(2);

// foo = sin, floor;
// process = par(i, 3, foo);

// foo(i) = _*(i+1);
// process = par(i, 3, foo(i));

// `seq` is similar.
// foo = sin, floor;
// process = seq(i, 3, foo);

// `sum`, and `prod` are similar, but the number of outputs in `foo` must be 1.
// foo = _ <: sin, floor :> _;
// process = sum(i, 3, foo);
// process = prod(i, 3, foo);

// One more par example:
// bar(i, x) = (i+1)*sqrt(x);
// process = par(i, 3, bar(i));

/*
Using inputs(FX) and outputs(FX);

You may have noticed that arguments to functions don't necessarily have one input or one output.
They can have multiple. In the recent examples, `foo` had 2 inputs and 2 outputs, and yet
we passed it to `par(i, 3, foo)`.
We can sometimes use inputs(FX) and outputs(FX) to get compile-time constants of that function's number
of inputs and outputs.
*/

// Example:
// import("stdfaust.lib");
// autoBusGain(decibels, FX) = par(i, N, _*gain)
// with {
//     N = outputs(FX);
//     gain = ba.db2linear(decibels);
// };
// oscillators = os.osc(440), os.osc(880), os.osc(880);
// process = autoBusGain(-24, oscillators);

/*
Let's demonstrate pattern matching.
*/

// foo(0) = sin;
// foo(1) = floor;
// foo(2) = abs;
// foo(x) = tan;
// process = par(i, 4, foo(i));

// Earlier definitions take precedent:
// foo(1) = 777;
// foo(x) = x;
// process = par(i, 3, foo(i));

// So you may not want to do
// foo(x) = x;
// foo(1) = 777; // doesn't show up!
// process = par(i, 3, foo(i));

// Fibonacci sequence with pattern matching:
// This method is bad for large `n`: https://understanding-recursion.readthedocs.io/en/latest/10%20Fibonacci%201.html
// fib(0) = 1;
// fib(1) = 1;
// fib(n) = fib(n-1)+fib(n-2);
// process = par(i, 6, fib(i));

// You can do some clever things with pattern matching:
// import("stdfaust.lib");
// repeat(1, FX) = FX;
// repeat(n, FX) = FX <: si.bus(N), repeat(n-1, FX) :> si.bus(N)
// with {
//     N = outputs(FX);
// };
// foo = @(500), @(600);
// process = si.bus(2) <: si.bus(2), repeat(3, foo) :> si.bus(2);

// Another
// import("stdfaust.lib");
// N = 4;
// C = 2;
// fx(i) = i+1, par(j, C, @(i*5000));
// process = 0, si.bus(C) : si.repeat(N, fx) : !, par(i, C, _*.2/N);

/*
GUI example.
Remember to discuss:
* hslider/vslider
* [style:knob]
* [unit:dB]
* [tooltip:Some info]
* si.smoo and si.smooth(tau2pole(.1))
* hgroup/vgroup
*/

// import("stdfaust.lib");
// filterBank(N) = hgroup("Filter Bank",seq(i,N,oneBand(i)))
// with {
//     oneBand(j) = vgroup("[%2j]Band %a",fi.peak_eq(l,f,b))
//     with {
//         a = j+1; // just so that band numbers don't start at 0
//         initFreq = (8000*a/N);
//         l = vslider("[2] Level [unit:dB]",0,-70,12,0.01) : si.smoo;
//         f = hslider("[1] Freq [style:knob]",initFreq,20,20000,0.01) : si.smoo;
//         b = f/hslider("[0] Q [style:knob]",1,1,10,0.01) : si.smoo;
//     };
// };
// declare filterBank author "Dr. Faustus";
// declare filterBank license "MIT";
// process = filterBank(12);

/*
Let's go over polyphony:
https://faustdoc.grame.fr/manual/midi/#midi-polyphony-support
Enable the code below and also set Poly Voices in the left panel to 1 or more.
*/

// declare options "[midi:on][nvoices:12]";
// import("stdfaust.lib");
// freq = hslider("freq [hidden:1]",200,50,1000,0.01);
// gain = hslider("gain [hidden:1]",0.5,0,1,0.01);
// gate = button("gate [hidden:1]");
// envGain = en.adsr(0.01,0.01,0.8,0.1,gate)*gain;
// process = os.sawtooth(freq)*envGain <: _,_;
// effect = dm.zita_light;

/*
Let's make a polyphony example with a modulated lowpass filter.
*/

// declare options "[midi:on][nvoices:12]";
// import("stdfaust.lib");
// freq = hslider("freq[hidden:1]",200,50,1000,0.01);
// gain = hslider("gain[hidden:1]",0.5,0,1,0.01);
// gate = button("gate[hidden:1]");
// envGain = en.adsr(0.01,0.01,0.8,0.1,gate)*gain;
// process = os.sawtooth(freq)*envGain : filter <: _,_;
// effect = dm.zita_light;

// filter = hgroup("Cutoff", fi.lowpass(5, cutoffHz))
// with {
//     env = hgroup("[2] Env", en.adsr(a,d,s, r, gate))
//     with {
//         a = hslider("[0] Attack [style:knob]", 0, 0, 1, .01) : si.smoo;
//         d = hslider("[1] Decay [style:knob]", 0.1, 0, 1, .01) : si.smoo;
//         s = hslider("[2] Sustain [style:knob]", 0, 0, 1, .01) : si.smoo;
//         r = hslider("[3] Release [style:knob]", 0, 0, 1, .01) : si.smoo;
//     };
//     cutoffBase = hslider("[0] Base [style:knob]",0.5,0,1,0.01) : si.smoo;
//     cutoffMod = hslider("[1] Modulation [style:knob]",0.0,0,1,0.01) : si.smoo;
//     cutoffHz = cutoffBase+cutoffMod*env : aa.clip(0, 1) : perceptualHz;
// };

// CUT_MIN = 20;
// CUT_MAX = 20000;

// // take a value `v` between 0 and 1 and map it to Hz, but based on a linear semitone scale.
// perceptualHz(v) = v : it.remap(0, 1, ba.hz2midikey(CUT_MIN), ba.hz2midikey(CUT_MAX)) : ba.midikey2hz;

/*
Next, let's go over the usage of .lib and .dsp files
.lib files should be used with
foo = library("foo.lib")

or less commonly with
import("foo.lib");

.dsp files can be used with
foo = component("foo.dsp");
process = foo;

It's also possible to override some expressions with a component.

foo = component("foo.dsp")[N = 2; SOMETHING = 3;];
process = foo;
*/

/*
Let's go over waveforms, soundfiles, and rdtable/rwtable 
First, we'll show the waveform and rdtable primtives.
*/
// import("stdfaust.lib");
// freq = hslider("freq",440,50,2000,0.01);
// wave = waveform{0,.5,1,.5,0,-.5,-1,-.5};
// // wave = waveform{0,1,0,-1};
// S = wave : _,!;  // The length of the waveform
// index = os.phasor(S, freq);
// // Turn off audio for the process below:
// process = wave : _, _;  // produces the length and the raw waveform data.

// The three below are equivalent.
// process = rdtable(wave);
// process(i) = rdtable(wave, i);
// process(i) = i : rdtable(wave);

// Basic example (without even linear interpolation)
// process = index : rdtable(wave);

// Now let's use Lagrange interpolation.
// N = 1;
// process = it.frdtable(N, S, (wave:!,_), index);
// process = it.frdtable(N, S, os.sinwaveform(S), index);

// Let's use the soundfile primtive.
// import("stdfaust.lib");
// sound = soundfile("sine[url:{'sine.wav'}]",1);
// // process = 0, _ : sound; // the inputs are the sound number and the read position index
// sf_channels = outputs(sound)-2;
// sf_size = sound(0,0) : _, !, si.block(sf_channels);
// sf_rate = sound(0,0) : !, _, si.block(sf_channels);
// freq = hslider("freq",440,50,2000,0.01);
// process = os.phasor(sf_size, freq) : sound(0) : !,!,si.bus(sf_channels);
// // Note: suppose your soundfile is a clip of audio, not a wavecycle.
// // Then you may want to adjust the playback speed based on the ratio of ma.SR to sf_rate.
// import("stdfaust.lib");
// declare soundfiles "http:/localhost:8000";
// sound = soundfile("mysound[url:{'Sovreign Break.wav'}]",2);
// // sound = soundfile("mysound[url:{'sine.wav';'saw.wav';'square.wav'}]",1);
// part = 0;
// process = so.loop(sound, part);

/*
Let's use a wavetable synth
*/

// import("stdfaust.lib");
// declare options "[midi:on][nvoices:8]";

// // `sf` is a soundfile primitive
// wavetable(sf, idx) = it.lagrangeN(N, f_idx, par(i, N + 1, table(i_idx - int(N / 2) + i)))
// with {
//     N = 3; // lagrange order
//     SFC = outputs(sf); // 1 for the length, 1 for the SR, and the remainder are the channels
//     S = 0, 0 : sf : ba.selector(0, SFC); // table size
//     table(j) = int(ma.modulo(j, S)) : sf(0) : !, !, si.bus(SFC-2);
//     f_idx = ma.frac(idx) + int(N / 2);
//     i_idx = int(idx);
// };

// // A user may want to replace this dynamically with a component.
// wavetables = vgroup("soundfiles", 
//     wavetable(soundfile("sine[url:{'sine.wav'}]",1)),
//     wavetable(soundfile("triangle[url:{'triangle.wav'}]",1)),
//     wavetable(soundfile("square[url:{'square.wav'}]",1)),
//     wavetable(soundfile("pwm[url:{'pwm.wav'}]",1)),
//     wavetable(soundfile("saw[url:{'saw.wav'}]",1))
// );

// NUM_TABLES = outputs(wavetables);

// //----------------multiwavetable-----------------------------
// // All wavetables are placed evenly apart from each other.
// //
// // Where:
// // * `wt_pos`: wavetable position from [0-1].
// // * `ridx`: read index. floating point [0 - (S-1)]
// multiwavetable(wt_pos, ridx) = si.vecOp((wavetables_output, coeff), *) :> _
// with {
//     wavetables_output = ridx <: wavetables;
//     coeff = par(i, NUM_TABLES, max(0, 1-abs(i-wt_pos*(NUM_TABLES-1))));
// };

// S = 2048; // the length of the wavecycles, which we decided when creating the WAV files.

// wavetable_synth = hgroup("Wavetable Synth", 
//     multiwavetable(wtpos, ridx)*env1*gain <: _, _
// )
// with {
//     freq = hslider("freq [style:knob]", 200 , 50  , 1000, .01 );
//     gain = hslider("gain [style:knob]", .5  , 0   , 1   , .01 );
//     gate = button("gate");

//     wtpos = hslider("WT Pos [style:knob]", 0   , 0    , 1   ,  .01);

//     ridx = os.hsp_phasor(S, freq, ba.impulsify(gate), 0);
//     env1 = en.adsr(.01, 0, 1, .1, gate);
// };

// process = wavetable_synth;

/*
Another wavetable synth:
Try `serum_oscillator.dsp` included with this tutorial.
*/

/*
Essential faust libraries functions:
* aa.clip
* Conversion tools:
* * ba.sec2samp and ba.samp2sec
* * ba.db2linear and ba.linear2db
* * ba.midikey2hz and ba.hz2midikey
* * ba.semi2ratio and ba.ratio2semi
* ba.if
* ba.selector
* ba.bpf
* si.bus
* ro.interleave
* de.fdelayltv
* en.adsr
* en.adsr_bias
* fi.lowpass and fi.highpass
* fi.low_shelf and fi.high_shelf
* fi.peak_eq
* fi.crossover3LR4
* it.interpolate_linear
* it.remap
* mi.stereo_width
* ef.dryWetMixer
* no.noise
* os.osc
* os.sawtooth
* si.bus 
* si.block
*/

/*
Let's demonstrate the importance of non-linear scaling of parameters such as cutoff frequencies.
*/

// import("stdfaust.lib");
// CUT_MIN = 20;
// CUT_MAX = 20000;

// // take a value `v` between 0 and 1 and map it to Hz, but based on a linear semitone scale.
// perceptualHz(v) = v : it.remap(0, 1, ba.hz2midikey(CUT_MIN), ba.hz2midikey(CUT_MAX)) : ba.midikey2hz;

// // 10th order lowpass (very steep rolloff in dB-per-octave)
// lowpass = fi.lowpass(10);

// // perceptual example:
// process = os.sawtooth(100) : lowpass(cutoff) <: _,_
// with {
//     cutoff = hslider("Cutoff", 0.5, 0, 1, .01) : si.smoo : perceptualHz;
// };

// // This version is worse because the cutoff is used linearly
// // process = os.sawtooth(100) : lowpass(cutoff) <: _,_
// // with {
// //     cutoff = hslider("Cutoff", CUT_MIN, CUT_MIN, CUT_MAX, .01) : si.smoo;
// // };

/*
More topics:
* foreign functions
* route primitive
* environment expression
*/
