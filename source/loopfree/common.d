module loopfree.common;

import std.range;
import std.functional;

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
