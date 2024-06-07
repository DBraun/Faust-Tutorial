import("stdfaust.lib");
// process = os.osc(200) <: tranceGate(
//     (1, 0, 0, 0,
//      1, 0, 0, 0,
//      1, 0, 0, 1,
//      0, 0, 1, 0), x)
// with {
//     x = os.lf_sawpos(.5);
// };

process = os.osc(200) <: tranceGate(
    grid(4, 4, x), x)
with {
    x = os.lf_sawpos(.5);
};

tranceGate(vals, x) = _*g,_*g
with {
    N = outputs(vals);
    i = floor(x*N) : aa.clip(0, N-1);

    g = vals : ba.selectn(N, i) : en.adsr(a, d, s, r);
    a = hslider("attack", 0.01, 0, 1, .01);
    d = hslider("decay", .01, 0, 1, .01);
    s = hslider("sustain", 1, 0, 1, .01);
    r = hslider("release", .01, 0, 1, .01);
};

grid(ROWS, COLS, x) = par(r, ROWS, par(c, COLS, entry(r, c)))
with {
    N = ROWS*COLS;
    i = floor(x*N) : aa.clip(0, N-1);
    c = i % COLS;
    r = floor(i/COLS);

    entry(row, col) = attach(b, (((row==r) & (col==c)) : led))
    with {
        b = checkbox("h: R%row/(%col,%row)");
        led = hbargraph("h: R%row/L(%col,%row) [style:led]", 0, 1);
    };
};