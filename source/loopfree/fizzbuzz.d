module loopfree.fizzbuzz;

import loopfree.common;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;

void fizzbuzz(int n) {
    iota(1, n+1)
        .map!( (n) {
            if( n % 15 == 0) { return "fizzbuzz"; }
            else if( n % 5 == 0) { return "buzz"; }
            else if( n % 3 == 0) { return "fizz"; }
            else { return n.to!string; }
        })
        .apply!writeln;
}


unittest {
    writeln("Testing fizzbuzz");

    fizzbuzz(16);
}
