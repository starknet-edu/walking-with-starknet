# **Programming on Ethereum's L2: Cairo Basics pt. 3**

Before starting, I recommend that you prepare your setup for programming in Cairo ❤️ with the [first tutorial](cairo_basics_1.md) and review the [Cairo basics pt. 2](cairo_basics_2.md).

🚀 The future of Ethereum is today and it's already here. Let's learn how to use an ecosystem that:

- It supports dYdX, DeFi that has already made four hundred billion trades and represents about a quarter of all transactions made in ethereum. They have only been around for 18 months and consistently beat Coinbase in trade volume. They reduced the price of transactions from 500 to 1,000 times. They are so cheap that they don't need to charge users for gas 💸.
- From the week of March 7 to 13, 2022, for the first time, it managed to have 33% more transactions than Ethereum 💣.

And it's just the beginning. Say hi on the StarkNet [Discord](https://discord.gg/uJ9HZTUk2Y). 

---

In the third part of the series of basic Cairo tutorials we will delve into concepts introduced in the second session such as builtins, felt and assert and their variations. In addition, we will introduce arrays. With what we learned in this session we will be able to create basic contracts in Cairo 🚀.

## 1. The builtins and their relationship with the pointers

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func mult_two_nums(num1, num2) -> (prod):
    return(num1 * num2)
end

func main{output_ptr: felt*}():    
    let (prod) = mult_dos_nums(2,2)
    serialize_word(prod)
    return ()
end
```

Do you remember that we introduced the `builtins` in the last session along with the implicit arguments?

Each `builtin` gives you the right to use a pointer that will have the name of the `builtin` + “`_ptr`”. For example, the output builtin, which we define `%builtins` output at the beginning of our contract, gives us the right to use the `output_ptr pointer`. The `range_check builtin` allows us to use the `range_check_ptr` pointer. These pointers are often used as implicit arguments that are automatically updated during a function.

In the function to multiply two numbers we use `%builtins output` and then use its pointer when defining `main: func main{output_ptr: felt*}():`.

## **2. More about how interesting (rare?) felts are**

> The felt is pretty much the only data type that exists in Cairo, you can even omit it [its explicit statement] sometimes ([StarkNet Bootcamp - Amsterdam - min 1:14:36](https://www.youtube.com/watch?v=O2zntD0muZs&t=3077s)).
> 

While it is not necessary to be an expert in the mathematical qualities of felts, it is valuable to know how they work. In the last tutorial we introduced them for the first time, now we will know how they affect when we compare values in Cairo.

> The definition of a felt, in terrestrial terms (the exact one is [here](https://3.0.0.33/)): an integer that can become huge (but has limits). For example: `{...,-4,-3,-2,-1,0,+1,+2,+3,...}`. Yes, it includes 0 and negative numbers.
> 

Any value that is not within this range will cause an “overflow”: an error that occurs when a program receives a number, value, or variable outside the scope of its ability to handle ([Techopedia](https://www.techopedia.com/definition/663/overflow-error#:~:text=In%20computing%2C%20an%20overflow%20error,other%20numerical%20types%20of%20variables.)).

Now we understand the limits of the felt. If the value is 0.5, for example, we have an overflow. Where will we experience overflows frequently? In the divisions. The following contract divides 9/3, `asserts` that the result is 3, and prints the result.

**Remember what we saw at the end of the first tutorial about compiling and running our programs.*

```python
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}():
    tempvar x = 9/3
    assert x = 3
    serialize_word(x)
    
    return()
end
```

So far everything makes sense. But what if the result of the division is not an integer like in the following contract?

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}():
    tempvar x = 10/3
    assert x = 10/3
    serialize_word(x)
    
    return()
end
```

To begin with, it prints the beautiful number 🌈 on the console: `1206167596222043737899107594365023368541035738443865566657697352045290673497`. What is this and why does it return it to us instead of an appreciable decimal point?

In the function above `x` is **not** a `floating point`, 3.33, **nor** is it an integer rounded with the result, 3. It is an integer that multiplied by 3 will give us 10 back (looks like this function `3 * x = 10`) or else `x` can be a denominator that returns 3 `(10 / x = 3)`. Let's see this with the following contract:

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}():
    tempvar x = 10/3

    tempvar y = 3 * x
    assert y = 10
    serialize_word(y)
    

    tempvar z = 10 / x
    assert z = 3
    serialize_word(z)
    
    return()
end
```

By compiling and running this contract we get exactly what we were looking for:

```python
Program output:
  10
  3
```

Cairo accomplishes this by coming back by overflowing again. Let's not go into mathematical details. This is somewhat unintuitive but don't worry, we can leave it here.

> Once you're writing contracts with Cairo you don't need to be constantly thinking about this [the particularities of felts when they're in divisions]. But it's good to be aware of how they work ([StarkNet Bootcamp - Amsterdam - min 1:31:00](https://www.youtube.com/watch?v=O2zntD0muZs&t=3077s)).
> 

## 3. Comparing felts 💪

Due to the particularities of felts, comparing between felts is not like in other programming languages (like with `1 < 2`).

In the `starkware.cairo.common.math` library we find functions that will help us compare felts ([link to GitHub repository](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/math.cairo)). For now we will use `assert_not_zero`, `assert_not_equal`, `assert_nn` and `assert_le`. There are more features to compare felts in this library, I recommend you to see the GitHub repository to explore them. [The following code from the StarkNet Bootcamp in Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) is useful to understand what each of the functions we import does (I altered it slightly).

```python
%builtins range_check

from starkware.cairo.common.math import assert_not_zero, assert_not_equal, assert_nn, assert_le

func main{range_check_ptr : felt}():
    assert_not_zero(1)  # is not zero
    assert_not_equal(1, 2)  # they are not the same
    assert_nn(1)  # non-negative
    assert_le(1, 10)  # less than or equal
    
    return ()
end
```

Simple, right? They're just different ways of doing asserts.

But what if we want to compare `10/3 < 10`? We know this to be true, but we also know that `10/3` will give us a large integer; the result of the division is not an integer so it falls outside the range of possible values felts can take. There will be an overflow and the large integer will be generated, which will naturally be greater than 10 or will even turn out to be out of the possible integers that a felt can take (due to how large it is).

In effect, the following function that compares `10/3 < 10` will return an error: `AssertionError: a = 2412335192444087475798215188730046737082071476887731133315394704090581346994` is out of range.

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}():
    assert_lt(10/3, 10) # less than
    
    return ()
end
```

How then do we compare `10/3 < 10`? We have to go back to our high school/college classes. Let's just remove the 3 from the denominator by multiplying everything by 3; we would compare `3*10/3 < 3*10`  which is the same as `10 < 30`. So we are only comparing integers and we forget how eccentric felts are. The following function runs without problem.

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}():
    assert_lt(3*10/3, 3*10)
    
    return ()
end
```

## **4. The dual nature of assert**

As we have seen, `assert` is key to Cairo programming. In the examples above we use it to confirm a statement, `assert y = 10`. This is a common usage in other programming languages like Python. But in Cairo when you try to `assert` something that isn't assigned yet, `assert` works to assign. Take a look at this example adapted from the [StarkNet Bootcamp in Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) that also serves to reinforce what we learned about structs in the [last tutorial](https://mirror.xyz/dashboard/edit/RPaAyK467IwmeSFII4YqfD0EuLjAYeD3ZOptOzXfj9w):

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

struct Vector2d:
    member x : felt
    member y : felt
end

func add_2d(v1 : Vector2d, v2 : Vector2d) -> (r : Vector2d):
    alloc_locals

    local res : Vector2d
    assert res.x = v1.x + v2.x
    assert res.y = v1.y + v2.y

    return (res)
end

func main{output_ptr: felt*}():
    
    let v1 = Vector2d(x = 1, y = 2)
    let v2 = Vector2d(x = 3, y = 4)

    let (sum) = add_2d(v1, v2)

    serialize_word(sum.x)
    serialize_word(sum.y)

    return()
end
```

When running `assert res.x = v1.x + v2.x`, Cairo's prover (more on this later) detects that `res.x` does not exist so it assigns the new value `v1.x + v2.x`. If we were to run `assert res.x = v1.x + v2.x` again, the prover would compare what it finds assigned in `res.x` with what we tried to assign. That is, the use that we already knew.

## 5. Arrays in Cairo

Let's close this tutorial with one of the most important data structures. Arrays contain ordered elements. They are very common in programming. How do they work in Cairo? Let's learn by **creating an array of matrices** 🙉. Yes, the writer has a background in machine learning. The contract below is commented and we will examine only the part of the arrays since the reader already knows the rest.

```python
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

    # Defining an array, my_array, of felts.
    let (my_array : felt*) = alloc()

    # Assigning values to three elements of my_array.  
    assert my_array[0] = 1
    assert my_array[1] = 2
    assert my_array[2] = 3

    # Creating the vectors Vector, for
    # simplicity we use the same my_array for both.
    let v1 = Vector(elements = my_array)
    let v2 = Vector(elements = my_array)

    # Defining an array of Matrix arrays
    let (matrix_array : Matrix*) = alloc()

    # Filling matrix_array with Matrix instances.
    # Each Matrix instance contains Vector 
    # instances as members.
    assert matrix_array[0] = Matrix(x = v1, y = v2)
    assert matrix_array[1] = Matrix(x = v1, y = v2)

    # We use assert to test some values in
    # our matrix_array.
    assert matrix_array[0].x.elements[0] = 1
    assert matrix_array[1].x.elements[1] = 2

    # What value do you think it will print? Answer: 3
    serialize_word(matrix_array[1].x.elements[2])

    return()
end
```

We create an array of felts called `my_array`. This is how it is defined:

```python
let (my_array : felt*) = alloc()
```

It's unintuitive compared to how easy it is in Python and other languages. `my_array : felt*` defines a variable called `my_array` that will contain a pointer ([see past tutorial](https://mirror.xyz/dashboard/edit/RPaAyK467IwmeSFII4YqfD0EuLjAYeD3ZOptOzXfj9w)) to a felt (we haven't defined which felt yet). Why? The Cairo documentation helps us:

> “**Arrays can be defined as a pointer (`felt*`) to the first element of the array.** As the array fills up, the elements occupy contiguous memory cells. The `alloc()` function is used to define a memory segment that expands in size each time a new element is written to the array (Cairo [documentation](https://www.cairo-lang.org/docs/reference/syntax.html#arrays)).”
> 

So, in the case of `my_array`, by placing the `alloc()` we are indicating that the memory segment that the expression `my_array` points to (remember that `my_array` is just the name of a pointer, `felt*`, in memory) will be expanded each time a new element is written to `my_array`.

In fact, if we go to the repo where `alloc()` is, we will see that it returns (`ptr : felt*`). That is, it returns a single-member tuple that is a `felt*` (a pointer to a felt). Because it is a tuple, we receive it with a `let` and with `mi_array : felt*` in parentheses (see [Cairo basics pt. 2](https://mirror.xyz/defilatam.eth/RPaAyK467IwmeSFII4YqfD0EuLjAYeD3ZOptOzXfj9w)). Everything is making sense, right 🙏?

We see that the definition of our matrix array is exactly the same except that instead of wanting a `felt` array we want a `Matrix` one:

```python
let (matrix_array : Matrix*) = alloc()
```

We already passed the complicated 😴. Now let's see how to fill our array with `Matrix` structures. We use `assert` and we can index with [ ] the position of the array that we want to alter or check:

```python
assert matrix_array[0] = Matrix(x = v1, y = v2)
```

What we did was create a `Matrix(x = v1, y = v2)` and assign it to position 0 of our `matrix_array`. Remember that we start counting from 0. Filling our `felt` array is even more trivial: `assert my_array[0] = 1`.

Then we simply call elements inside the `matrix_array` in different ways. For example, with `matrix_array[1].x.elements[2]` we indicate these steps:

- Call the second, `[1]`, element of `matrix_array`. That is, to `Matrix(x = v1, y = v2)`.
- Call `member` `x` of the `Matrix`. That is, a `v1 = Vector(elements = my_array)`.
- Call the member elements of `v1`. That is, to `my_array`.
- Call the third, `[2]`, element of `my_array`. That is, to `3`.

It's not that complicated but it's satisfying enough 🤭.

## 6. Conclusion

Congratulations 🚀. We've delved into the basics of 🏖 Cairo. With this knowledge you can start making simple contracts in Cairo   .

In the following tutorials we will learn more about memory management; the cairo common library; how the Cairo compiler works; and more!

Any comments or improvements please comment with [@espejelomar](https://twitter.com/espejelomar) 🌈.