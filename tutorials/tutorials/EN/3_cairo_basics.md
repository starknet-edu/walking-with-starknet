
# Programming on Ethereum L2 (pt. 3): Cairo basics 2

Before starting, I recommend that you prepare your computer to code in Cairo ❤️ with the [first tutorial](1_installation.md), and review the [Cairo Basics pt. 1](2_cairo_basics.md). 

This is the third tutorial in a series focused on developing smart contracts with Cairo and StarkNet.

🚀 The future of Ethereum is today and it's already here. And it's just the beginning.

---

In the third part of the series of basic Cairo tutorials we will delve into concepts introduced in the [second session](2_cairo_basics.md) such as `builtin`, `felt` and `assert` and their variations. In addition, we will introduce arrays. With what we have learned in this session we will be able to create basic Cairo 🚀 contracts.

## 1. Builtins and their relationship with pointers

In the following program we are multiplying two numbers. The entire code is available at [src/multiplication.cairo](../../../src/multiplication.cairo). There you will find the code correctly commented.

```rust
%builtins output

from starkware.cairo.common.serialize import serialize_word

func mult_two_nums(num1, num2) -> (prod : felt){
    return(prod = num1 * num2);
}

func main{output_ptr: felt*}(){
    let (prod) = mult_two_nums(2,2);
    serialize_word(prod);
    return ();
}
```

Remember that we introduced the `builtins` in the last session along with the implicit arguments? 

Each `builtin` gives you the right to use a pointer that will have the name of the `builtin` + “`_ptr`”. For example, the output builtin, which we define as `%builtins output` at the beginning of our contract, gives us the right to use the `output_ptr` pointer. The `range_check` `builtin` allows us to use the `range_check_ptr` pointer. These pointers are often used as implicit arguments that are automatically updated during a function.

In the function to multiply two numbers we use `%builtins output` and then use its pointer when defining main: `func main{output_ptr: felt*}():`.

## 2. More about how interesting (rare?) felts are

> The felt is the only data type that exists in Cairo, you can even omit it [its explicit declaration] (StarkNet Bootcamp - Amsterdam - min 1:14:36).

Although it is not necessary to be an expert in the mathematical qualities of felts, it is valuable to know how they work. In the last tutorial we introduced them for the first time, now we will know how they affect when we compare values in Cairo.

> The definition of a felt, in terrestrial terms (the exact one is here): an integer that can become huge (but has limits). For example: {...,-4,-3,-2,-1,0,+1,+2,+3,...}. Yes, it includes 0 and negative numbers.

Any value that is not within this range will cause an “overflow”: an error that occurs when a program receives a number, value, or variable outside the scope of its ability to handle ([Techopedia](https://www.techopedia.com/definition/663/overflow-error#:~:text=In%20computing%2C%20an%20overflow%20error,other%20numerical%20types%20of%20variables.)).

Now we understand the limits of the felt. If the value is 0.5, for example, we have an overflow. Where will we experience overflows frequently? In the divisions. The following contract (full code is in [src/division1.cairo](../../../src/division1.cairo)) divides 9/3, check with `assert` that the result is 3, and print the result.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}(){
    tempvar x = 9/3;
    assert x = 3;
    serialize_word(x);

    return();
}

```

So far everything makes sense. But what if the result of the division is not an integer like in the following contract (the code is in [src/division2.cairo](../../../src/division2.cairo))?

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}(){
    tempvar x = 10/3;
    assert x = 10/3;
    serialize_word(x);

    return();
}

```

To begin with, it prints the beautiful number 🌈 on the console: `1206167596222043737899107594365023368541035738443865566657697352045290673497`. What is this and why does it return it to us instead of a sizable decimal point?

In the function above `x` **not** is a `floating point`, 3.33, **ni** is an integer rounded to the result, 3. It is an integer that multiplied by 3 will give us 10 back (it looks like this function `3 * x = 10`) or `x` can also be a denominator that returns 3 (`10 / x = 3`). Let's see this with the following contract:

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}(){
    tempvar x = 10/3;

    tempvar y = 3 * x;
    assert y = 10;
    serialize_word(y);

    tempvar z = 10 / x;
    assert z = 3;
    serialize_word(z);

    return();
}
```

By compiling and running this contract we get exactly what we were looking for:

```python
Program output:
  10
  3
```

Cairo accomplishes this by coming back by overflowing again. Let's not go into mathematical details. This is somewhat unintuitive but don't worry, we can leave it here.

> Once you're writing contracts with Cairo you don't need to be constantly thinking about this [the particularities of the felts when they are in divisions]. But it's good to be aware of how they work (StarkNet Bootcamp - Amsterdam - min 1:31:00).
>

## **3. Comparing felts 💪**

Due to the particularities of felts, comparing between felts is not like in other programming languages (like with `1 < 2`).

In the `starkware.cairo.common.math` library we find functions that will help us compare felts ([link to GitHub repository](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/math.cairo)). For now we will use `assert_not_zero`, `assert_not_equal`, `assert_nn` and `assert_le`. There are more features to compare felts in this library, I recommend you to see the GitHub repository to explore them. The [following code from the StarkNet Bootcamp in Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) it serves to understand what each of the functions that we import does (I altered it slightly). The complete code is in [src/asserts.cairo](../../../src/asserts.cairo).

```python
%builtins range_check

from starkware.cairo.common.math import assert_not_zero, assert_not_equal, assert_nn, assert_le

func main{range_check_ptr : felt}(){
    assert_not_zero(1);  // not zero
    assert_not_equal(1, 2);  // not equal
    assert_nn(1); // non-negative
    assert_le(1, 10);  // less or equal
    
    return ();
}
```

Simple, right? They're just different ways of doing asserts.

But what if we want to compare `10/3 < 10`? We know this to be true, but we also know that the result of the division `10/3` is not an integer, so it falls outside the range of possible values that felts can take. There will be an overflow and a value will be generated that will turn out to be out of the possible integers that a felt can take (because of how big it is).

In effect, the following function that compares `10/3 < 10` will return an error: `AssertionError: a = 2412335192444087475798215188730046737082071476887731133315394704090581346994 is out of range.`

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}(){
    assert_lt(10/3, 10); // less than

    return ();
}
```

How then do we compare `10/3 < 10`? We have to go back to our high school/college classes. Let's just remove the 3 from the denominator by multiplying everything by 3; we would compare `3*10/3 < 3*10` which is the same as `10 < 30`. This way we are only comparing integers and forget about how eccentric the felt is. The following function runs without a problem.

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}(){
    assert_lt(3*10/3, 3*10);

    return ();
}
```
## 4. The dual nature of assert

As we have seen, `assert` is key to programming in Cairo. In the examples above we use it to confirm a statement, `assert y = 10`. This is a common usage in other programming languages like Python. But in Cairo when you try to `assert` something that isn't assigned yet, `assert` works to assign. Check out this example adapted from [StarkNet Bootcamp Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) which also helps us to consolidate what we learned about structs in the [past tutorial](2_cairo_basics.md). The complete code is in [src/vector.cairo](../../../src/vector.cairo).

```python
 %builtins output

from starkware.cairo.common.serialize import serialize_word

struct Vector2d{
    x : felt,
    y : felt,
}

func add_2d(v1 : Vector2d, v2 : Vector2d) -> (r : Vector2d){
    alloc_locals;

    local res : Vector2d;
    assert res.x = v1.x + v2.x;
    assert res.y = v1.y + v2.y;

    return (r=res);
}

func main{output_ptr: felt*}(){
    
    let v1 = Vector2d(x = 1, y = 2);
    let v2 = Vector2d(x = 3, y = 4);

    let (sum) = add_2d(v1, v2);

    serialize_word(sum.x);
    serialize_word(sum.y);

    return();
}
```

Running `assert res.x = v1.x + v2.x`, Cairo's prover (more on this later) detects that `res.x` does not exist, so it assigns the new value `v1.x + v2.x` to it. If we were to run `assert res.x = v1.x + v2.x` again, the prover would indeed compare what it finds assigned in `res.x` with what we tried to assign.If we were to run `assert res.x = v1.x + v2.x` again, the prover would indeed compare what it finds assigned in `res.x` with what we tried to assign. That is, the use that we already knew.

## 5. Arrays in Cairo

Let's close this tutorial with one of the most important data structures. Arrays contain ordered elements. They are very common in programming. How do they work in Cairo? Let's learn **creating an array of matrices 🙉**. Yes, the write has a background in machine learning. The contract below is commented (it can be found in [src/matrix.cairo](../../../src/matrix.cairo)) and we will examine only the part of the arrays since the reader already knows the rest.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

struct Vector{
    elements : felt*,
}

struct Matrix{
    x : Vector,
    y : Vector,
}

func main{output_ptr: felt*}(){

    // Defining an array, my_array, of felts.
    let (my_array : felt*) = alloc();

    // Assigning values to three elements of my_array.  
    assert my_array[0] = 1;
    assert my_array[1] = 2;
    assert my_array[2] = 3;

    // Creating the vectors Vector, by
    // simplicity we use the same my_array for both.
    let v1 = Vector(elements = my_array);
    let v2 = Vector(elements = my_array);

    // Defining an array of Matrix matrices
    let (matrix_array : Matrix*) = alloc();

    // Filling matrix_array with Matrix instances.
    // Each instance of Matrix contains as members
    // Vector instances.
    assert matrix_array[0] = Matrix(x = v1, y = v2);
    assert matrix_array[1] = Matrix(x = v1, y = v2);

    // We use assert to test some values in
    // our matrix_array.
    assert matrix_array[0].x.elements[0] = 1;
    assert matrix_array[1].x.elements[1] = 2;

    // What value do you think it will print? Answer: 3
    serialize_word(matrix_array[1].x.elements[2]);

    return();
}
```

We create an array of felts called `my_array`. This is how it is defined:

```
let (my_array : felt*) = alloc();
```

It's unintuitive compared to how easy it is in Python and other languages. `my_array : felt*` defines a variable called `my_array` which will contain a pointer (see [past tutorial](2_cairo_basics.md) to a felt (we haven't defined which felt yet). Why? The Cairo documentation helps us:

> “Arrays can be defined as a pointer (felt*) to the first element of the array. As the array fills up, the elements occupy contiguous memory cells. The alloc() function is used to define a memory segment that expands in size each time a new element is written to the array (Cairo documentation)."
>

So, in the case of `my_array`, by placing the `alloc()` we are indicating that the memory segment pointed to by the `my_array` expression (remember that `my_array` is just the name of a pointer, `felt*`, in memory) will be expanded each time a new element is written to `my_array`.

In fact, if we go [to the repo](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/alloc.cairo) where `alloc()` is located we will see that it returns `(ptr : felt*)`. That is, it returns a single-member tuple that is a `felt*` (a pointer to a `felt`). Because it is a tuple, we receive it with a `let` and with `my_array : felt*` in parentheses (see [Cairo basics pt. 2](2_cairo_basics.md)). Everything is making sense, right 🙏?

We see that the definition of our array of matrices is exactly the same except that instead of wanting an array of `felt` we want one of `Matrix`:

```python
let (matrix_array : Matrix*) = alloc();

```
We already passed the complicated 😴. Now let's see how to fill our array with `Matrix` structures. We use `assert` and we can index with `[]` the position of the array that we want to alter or revise:

```
assert matrix_array[0] = Matrix(x = v1, y = v2);
```
What we did was create a `Matrix(x = v1, y = v2)` and assign it to position 0 of our `matrix_array`. Remember that we start counting from 0. Filling our `felt` array is even more trivial: `assert my_array[0] = 1`. 

Then we simply call elements inside the `matrix_array` in different ways. For example, with `matrix_array[1].x.elements[2]` we indicate these steps:

1. Call the second, `[1]`, element of `matrix_array`. That is, to `Matrix(x = v1, y = v2)`.
2. Call the `member` `x` of `Matrix`. That is, to `v1 = Vector(elements = my_array)`.
3. Call the `member` `elements` of `v1`. That is, to `my_array`.
4. Call the third, `[2]`, element of `my_array`. That is, to `3`.

It's not that complicated but it's satisfying enough 🤭.

## **6. Conclusion**

Congratulations 🚀. We've delved into the basics of 🏖 Cairo. With this knowledge you can start making simple contracts in Cairo 🥳. 

In the following tutorials we will learn more about memory management; the cairo common library; how the Cairo compiler works; and more!

Any comments or improvements please comment with [@espejelomar](https://twitter.com/espejelomar) or make a PR 🌈.