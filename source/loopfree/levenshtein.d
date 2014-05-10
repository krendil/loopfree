module loopfree.levenshtein;

import std.algorithm;
import std.array;
import std.conv;
import std.functional;
import std.range;
import std.traits;

import loopfree.common;


auto levenshtein(alias sub = "a == b ? 0 : 1", R1, R2)(R1 from, R2 to)
    if ( isInputRange!R1 && isInputRange!R2
         && isNumeric!( typeof(binaryFun!sub( ForeachType!R1.init, ForeachType!R2.init)) ))
{
    alias subFun = binaryFun!sub;
    alias RT = typeof(subFun( ForeachType!R1.init, ForeachType!R2.init));
    RT one = 1.to!RT;

    //When iterating over unicode strings, walkLength may not == length
    auto width = from.walkLength;
    auto height = to.walkLength;

    RT[] oddRow = new RT[](width);
    RT[] evenRow = new RT[](width);

    RT prevWeight( size_t row, size_t col ) {
        if( row == 0 ) return col.to!RT;
        if( col == 0 ) return row.to!RT;
        return (((row & 1) ? oddRow : evenRow)[col-1]).to!RT;
    }

    RT min3( RT a, RT b, RT c) {
        return a < b ? (a < c ? a : c) : (b < c ? b : c);
    }

    iota(1, width+1).zip(from)
        .cartesianProduct(iota(1, height+1).zip(to))
        .apply!( (tup) { //Args are tuple of to index and char, tuple of from index and char
                    size_t row = tup[1][0];
                    size_t col = tup[0][0];
                    auto fc = tup[0][1];
                    auto tc = tup[1][1];

                    RT cost = min3(
                        prevWeight( row - 1, col ) + one, //Insert
                        prevWeight( row, col - 1 ) + one, //Delete
                        prevWeight( row - 1, col - 1) + subFun(fc, tc) //Substitute
                    );

                    ((row & 1) ? oddRow : evenRow)[col-1] = cost;
                } )
        ;

    return ((to.walkLength & 1) ? oddRow : evenRow)[$-1];
}

unittest {
    import std.stdio : writeln;
    import std.string : format; 

    writeln("Testing Levenshtein distance");
    
    string kitten = "kitten";
    string sitting = "sitting";

    auto distance = levenshtein(kitten, sitting);
    assert( distance == 3, "Wrong distance for kitten->sitting, got %s instead of 3".format(distance) );
}
