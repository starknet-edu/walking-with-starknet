%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}() {
    tempvar x = 10 / 3;

    tempvar y = 3 * x;
    assert y = 10;
    serialize_word(y);

    tempvar z = 10 / x;
    assert z = 3;
    serialize_word(z);

    return ();
}
