//--------------toGrayCode------------------
// Turn a natural number with a fixed
// upper limit of bits into a gray code bus.
//
// #### Usage
// ```
// _ : int : toGrayCode(N) : si.bus(N)
// ```
//
// Where
// * `N`: Number of bits
//-------------------------------------------
toGrayCode(N) = _toGray <: par(i, N, getNthBit(i))
with {
    _toGray(x) = x xor (x >> 1);
    getNthBit(n) = int((_ >> n) & 1);
};

process = toGrayCode(3, 7);
