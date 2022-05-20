%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

struct Vector:
    member elements : felt*
end

struct Matrix:
    member x : Vector
    member y : Vector
end

func main{output_ptr: felt*}():

    # Definiendo un array, mi_array, de felts.
    let (mi_array : felt*) = alloc()

    # Asignando valores a tres elementos de mi_array.  
    assert mi_array[0] = 1
    assert mi_array[1] = 2
    assert mi_array[2] = 3

    # Creando los vectores Vector, por 
    # simplicidad usamos el mismo  mi_array para ambos.
    let v1 = Vector(elements = mi_array)
    let v2 = Vector(elements = mi_array)

    # Definiendo un array de matrices Matrix
    let (matrix_array : Matrix*) = alloc()

    # Llenando matrix_array con instancias de Matrix.
    # Cada instancia de Matrix contiene como members
    # a instancias de Vector.
    assert matrix_array[0] = Matrix(x = v1, y = v2)
    assert matrix_array[1] = Matrix(x = v1, y = v2)

    # Usamos assert para probar algunos valores en
    # nuestra matrix_array.
    assert matrix_array[0].x.elements[0] = 1
    assert matrix_array[1].x.elements[1] = 2

    # ¿Qupe valor crees que imprimirá? Respuesta: 3
    serialize_word(matrix_array[1].x.elements[2])

    return()
end