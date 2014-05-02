module loopfree.tortoisehare;

import std.algorithm;
import std.array;
import std.range;

class List(E) {
    E head;
    List!E tail;

    public this(E head, List!E tail) {
        this.head = head;
        this.tail = tail;
    }

    public ListNodeRange!E opSlice() {
        return ListNodeRange!E(this);
    }
}

List!E cons(E)(E head, List!E tail) {
    return new List!E(head, tail);
}

struct ListNodeRange(E) {
    List!E front;

    bool empty() {
        return front is null;
    }

    void popFront() {
        front = front.tail;
    }
}

bool hasLoop(E)(List!E list) {
    return zip(list[], list[].stride(2))
        .dropOne
        .canFind!( (pair) => (pair[0] is pair[1]) );
}

unittest {
    import std.stdio : writeln;

    writeln("Testing tortoise and hare algorithm.");
    
    auto end = 3.cons!int(null);
    auto start = 1.cons(2.cons(end));
    end.tail = start;

    static assert(isInputRange!(ListNodeRange!int));
    assert( start.hasLoop(), "Loop not detected." );

    auto start2 = 1.cons(2.cons(3.cons!int(null)));
    assert( !start2.hasLoop(), "Loop erroneously detected." );

}
