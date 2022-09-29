%builtins output

from starkware.cairo.common.serialize import serialize_word

// @dev Multiplica dos números y retorna el resultado
// @param num1 (felt): primero número a multiplicar
// @param num2 (felt): segundo número a multiplicar
// @return prod (felt): valor de la multiplicación de los dos números
func mult_dos_nums(num1, num2) -> (prod : felt){
    return(prod = num1 * num2);
}

func main{output_ptr: felt*}(){
    let (prod) = mult_dos_nums(2,2);
    serialize_word(prod);
    return ();
}