%builtins output

from starkware.cairo.common.serialize import serialize_word

func mult_dos_nums(num1, num2) -> (prod):
    return(num1 * num2)
end

func main{output_ptr: felt*}():    
    let (prod) = mult_dos_nums(2,2)
    serialize_word(prod)
    return ()
end