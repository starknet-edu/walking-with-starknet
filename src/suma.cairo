%builtins output

from starkware.cairo.common.serialize import serialize_word

// @dev Suma dos números y retorna el resultado
// @param num1 (felt): primero número a sumar
// @param num2 (felt): segundo número a sumar
// @return suma (felt): valor de la suma de los dos números
func suma_dos_nums(num1: felt, num2: felt) -> (suma: felt) {
    alloc_locals;
    local sumando = num1+num2;
    return (suma=sumando);
}

func main{output_ptr: felt*}(){
    alloc_locals;
    
    const NUM1 = 1;
    const NUM2 = 10;

    let (suma) = suma_dos_nums(num1 = NUM1, num2 = NUM2);
    serialize_word(suma);
    return ();
}