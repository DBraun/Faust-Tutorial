// A modification of https://faustdoc.grame.fr/manual/syntax/#rwtable-primitive
// where if record is OFF, you write the last output value
// to the previously used read index, causing the table to not change.
import("stdfaust.lib");

table(n, s, w, x, r, record) = rwtable(n, s, writeIndex, select2(record, _, x), r) ~ _
with {
    writeIndex = select2(record, r', w);
};

tableSize = 48000; // samples
readIndex = readSpeed/float(ma.SR) : (+ : ma.frac) ~ _ : *(float(tableSize)) : int;
writeIndex = ((+(1) : %(tableSize)) ~ *(record));
readSpeed = hslider("[1] Read Speed [knob:1][style:knob]",1,0.001,10,0.01);
record = button("[0] Record [switch:1]") : int;
looper = table(tableSize,0.0,writeIndex,_,readIndex, record);
process = hgroup("Pod", looper, looper);
