module loopfree.common;

import std.functional;
import std.range;
import std.traits;
import std.typetuple;

template isCallableWith( alias fun, Args... ) {
    enum isCallableWith = __traits(compiles, fun(Tuple!(Args).init.expand));
}

unittest {

    auto test( int a, float b, string c) {
        return c;
    }

    auto test2( int a, string bs...) {
        return bs[a];
    }

    auto test3( int a = 3) {
        return a;
    }

    static assert(isCallableWith!(test, int, float, string), "Couldn't call with exact types");
    static assert(isCallableWith!(test, int, int, string), "Couldn't call with implicitly convertible types");
    static assert(!isCallableWith!(test, string, bool, int), "Could call with wrong types");

    static assert(isCallableWith!(test2, int, string), "Couldn't call with one variadic argument");
    static assert(isCallableWith!(test2, int), "Couldn't call with zero variadic arguments");
    //static assert(isCallableWith!(test2, int, string, string, string), "Couldn't call with three variadic arguments");

    static assert(isCallableWith!(test3, int), "Couldn't call while supplying optional argument");
    static assert(isCallableWith!(test3), "Couldn't call while not supplying optional argument");

    static assert(isCallableWith!( a => !a, bool), "Couldn't call lambda literal");

    static assert(isCallableWith!( unaryFun!"!a", bool), "Couldn't call output of unaryFun");
    static assert(isCallableWith!( binaryFun!"a + b", int, float), "Couldn't call output of binaryFun");
}



/**
 * Eagerly calls the given function for every element of the range
 */
public auto apply(alias fun, R)(R range)
    if(isInputRange!R)
{
    foreach( e; range ) {
        unaryFun!fun(e);
    }
}

public auto tee(alias fun, R)(R range)
    if( isInputRange!R && isCallableWith!(unaryFun!fun, ForeachType!R) )
{
    return R.map!( (e) { unaryFun!fun(e); return e; } );
}
