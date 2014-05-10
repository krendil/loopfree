module loopfree.levenshtein;

import std.algorithm;
import std.array;
import std.conv;
import std.functional;
import std.range;
import std.traits;

import loopfree.common;


auto levenshtein(alias sub = "a == b ? 0 : 1", alias ins = "1", alias del = "1", R1, R2)
    (R1 from, R2 to)
    if ( isInputRange!R1 && isInputRange!R2
         && isNumeric!( typeof(binaryFun!sub( ForeachType!R1.init, ForeachType!R2.init)) ))
{
    alias subFun = binaryFun!sub;
    alias insFun = unaryFun!ins;
    alias delFun = unaryFun!del;
    alias RT = typeof(subFun( ForeachType!R1.init, ForeachType!R2.init));
    static assert( isImplicitlyConvertible!( typeof(insFun(ForeachType!R2.init)), RT), "The insertion function produces a different type to the substitution function");
    static assert( isImplicitlyConvertible!( typeof(delFun(ForeachType!R1.init)), RT), "The deletion function produces a different type to the substitution function");

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
        .map!( (tup) { //Args are tuple of to index and char, tuple of from index and char
                    size_t row = tup[1][0];
                    size_t col = tup[0][0];
                    auto fc = tup[0][1];
                    auto tc = tup[1][1];

                    return min3(
                        prevWeight( row - 1, col ) + insFun(tc), //Insert
                        prevWeight( row, col - 1 ) + delFun(fc), //Delete
                        prevWeight( row - 1, col - 1) + subFun(fc, tc) //Substitute
                    );
                } )
        .copy( chain(oddRow, evenRow).cycle )
        ;

    return ((height & 1) ? oddRow : evenRow)[$-1];
}

unittest {
    import std.stdio : writeln;
    import std.string : format; 

    writeln("Testing Levenshtein distance");
    
    string kitten = "kitten";
    string sitting = "sitting";

    auto distance = levenshtein(kitten, sitting);
    assert( distance == 3, "Wrong distance for kitten->sitting, got %s instead of 3".format(distance) );

    import std.uni : toLower;

    assert( levenshtein!( (a, b) {
                if( a == b ) return 0;
                if( a.toLower == b.toLower ) return 0.5;
                return 1;
            })("HELLO", "hello") == 2.5, "Wrong distance with custom sub function");

    float[] from = [ 0.2, 0.5, 0.7 ];
    float[] to   = [ 0.9, 0.1, 0.2, 0.3 ];
    float distance2 = levenshtein!( "abs(a - b)", "abs(a)", "abs(a)" )(from, to);
    assert( distance2 == 1.5f, "Wrong distance with custom sub, ins and del functions");

    string[] strings = [ "This", "may", "get", "kinda", "weird" ];
    size_t[] lengths = [ 1, 4, 2, 3, 5, 5 ];
    size_t distance3 = levenshtein!( "a.length == b ? 0 : 1" )(strings, lengths);
    assert( distance3 == 2, "Wrong distance with different types");
}
