%lang starknet

@external
func up() {
    %{ declare("./build/main.json") %}
    return ();
}

@external
func down() {
    %{ assert False, "Not implemented" %}
    return ();
}