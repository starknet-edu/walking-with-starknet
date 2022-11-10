# Programming on Ethereum L2 (pt. 2): Cairo Basics 1

Before starting, I recommend that you prepare your machine to program in Cairo ❤️ with the [past tutorial](1_installation.md).

This is the second tutorial in a series focused on developing smart contracts with Cairo and StarkNet. I recommend that you do the previous tutorial before moving on to this one.

🚀 The future of Ethereum is today and it's already here. And it's just the beginning.

---

## 1. Add two numbers

To learn the basics of Cairo we will create together a function to add two numbers 🎓. The code is very simple but it will help us to better understand many concepts of Cairo. We will be strongly based on the [Cairo documentation](https://www.cairo-lang.org/docs/). The documentation is excellent, as of today it is not ready to serve as a structured tutorial for beginners. Here we seek to solve this 🦙.

Here is our code to add two numbers. You can paste it directly into your code editor or IDE. In my case I am using VSCode with the Cairo extension.

Don't worry if you don't understand everything that's going on at this point. But [@espejelomar](https://twitter.com/espejelomar) will worry if by the end of the tutorial you don't understand every line of this code. Let me know if so because we will improve 🧐. Cairo is a low-level language so it will be more difficult than learning Python, for example. But it will be worth it 🥅. Eyes on the goal.

Let's see line by line and with additional examples what we are doing. The entire program to add the two numbers is available in [src/sum.cairo](../../../src/sum.cairo). There you will find the code correctly commented.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

// @dev Add two numbers and return the result
// @param num1 (felt): first number to add
// @param num2 (felt): second number to add
// @return sum (felt): value of the sum of the two numbers
func sum_two_nums(num1: felt, num2: felt) -> (sum: felt) {
    alloc_locals;
    local sum = num1+num2;
    return (sum=sum);
}

func main{output_ptr: felt*}(){
    alloc_locals;
    
    const NUM1 = 1;
    const NUM2 = 10;

    let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2);
    serialize_word(sum);
    return ();
}
```

## 2. The builtins

At the beginning of our program in Cairo we write `%builtins output`. Here we are telling the Cairo compiler that we will use the `builtin` called `output`. The definition of `builtin` is quite technical and beyond the scope of this first tutorial ([here it is](https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#builtins) in the documentation). For now, it suffices for us to point out that we can summon Cairo's special abilities through the builtins. If you know C++ surely you already found the similarities.

> The builtin output is what allows the program to communicate with the outside world. You can think of it as the equivalent of `print()` in Python or `std::cout` in C++ ([Cairo documentation](https://www.cairo-lang.org/docs/hello_cairo/intro.html#writing-a-main-function)).
>

The interaction between `builtin` `output` and the `serialize_word` function, which we previously imported, will allow us to print to the console. In this case with `serialize_word(sum)`. Don't worry, we'll take a closer look at it later.

## 3. Importing

Cairo is built on top of Python so importing functions and variables is exactly the same. The `from starkware.cairo.common.serialize import serialize_word` line is importing the `serialize_word` function found in `starkware.cairo.common.serialize`. To see the source code of this function, just go to the Github repository of `cairo-lang` ([link](https://github.com/starkware-libs/cairo-lang)). For example, the serialize function is found [here](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/serialize.cairo) within the repository. This will be useful for finding bugs in the code or understanding Cairo more thoroughly.

> Multiple functions from the same library can be separated by commas. Functions from different libraries are imported on different lines. Cairo looks for each module in a default directory path and any additional paths specified at compile moment (Cairo documentation).

This is how several functions are imported from the same library: `from starkware.cairo.common.math import (assert_not_zero, assert_not_equal)`.

## 4. The field elements (felt)

In Cairo, when the type of a variable or argument is not specified, it is automatically assigned the type `felt`. The [Cairo documentation](https://www.cairo-lang.org/docs/hello_cairo/intro.html#the-primitive-type-field-element-felt) goes into technical detail about what is a `felt`. For the purposes of this tutorial, suffice it to say that a `felt` works as an integer. In the divisions we can notice the difference between the `felt` and the integers. However, quoting the documentation:

> In most of your code (unless you intend to write very algebraic code), you won't have to deal with the fact that the values in Cairo are felts and you can treat them as if they were normal integers.

## 5. The structs (Cairo dictionaries?)

In addition to `felt`, we have other structures at our disposal (more details in the [documentation](https://www.cairo-lang.org/docs/reference/syntax.html#type-system)).

We can create our own structure, Python dictionary style:

```python
struct MyStruct{
    first_member : felt,
    second_member : felt,
}

```
We define a new data type called `MyStruct` with the properties `first_member` and `second_member`. We set the `type` of both properties to be `felt` but we may as well have put in other types. When we create a `struct` it is mandatory to add the `type`.

We can create a variable of type `MyStruct`: `Name = (first_member=1, second_member=4)`. Now the variable `Name` has `type` `MyStruct`.

With `Name.first_member` we can access the value of this argument, in this case it is 1.

## **6. Tuples

Tuples in Cairo are pretty much the same as tuples in Python:

> A tuple is a finite, ordered, unalterable list of elements. It is represented as a comma-separated list of elements enclosed in parentheses (for example, (3, x)). Its elements can be of any combination of valid types. A tuple containing only one element must be defined in one of two ways: the element is a named tuple or it has a trailing comma. When passing a tuple as an argument, the type of each element can be specified per element (for example, my_tuple : (felt, felt, MyStruct)). Tuple values can be accessed with a zero-based index in parentheses [index], including access to nested tuple elements as shown below (Cairo documentation).

The Cairo documentation is very clear in its definition of tuples. Here your example:

```python
# A tuple with three elements
local tuple0 : (felt, felt, felt) = (7, 9, 13)
local tuple1 : (felt) = (5,)  # (5) is not a valid tuple.

# A named tuple does not require a trailing comma
local tuple2 : (a : felt) = (a=5)

# Tuple that contains another tuple.
local tuple3 : (felt, (felt, felt, felt), felt) = (1, tuple0, 5)
local tuple4 : ((felt, (felt, felt, felt), felt), felt, felt) = (
    tuple3, 2, 11)
let a = tuple0[2]  # let a = 13.
let b = tuple4[0][1][2]  # let b = 13.

```

## 7. The structure of functions and comments

The definition of a function in Cairo has the following format:

```python
func function(arg1: felt, arg2) -> (retornado: felt){
  // Function body
  let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2);
  return(returned=sum);
}

```

- **Define the scope of the function**. We start the function with `func`. The scope of our function is defined with curly braces {}. 
- **Arguments and names**. We define the arguments that the function receives in parentheses next to the name that we define for our function, `function` in this case. The arguments can carry their type defined or not. In this case `arg1` must be of type `felt` and `arg2` can be of any type.
- **Return**. We necessarily have to add `return()`. Although the function is not returning something. In this case we are returning a variable called `returned` so we put `return(returned=sum)` where sum is the value that the `returned` variable will take.
- **Comments**. In Cairo we comment with `//`. This code will not be interpreted when running our program.

As with other programming languages. We will need a `main()` function that orchestrates the use of our program in Cairo. It is defined exactly the same as a normal function only with the name `main()`. It can come before or after the other functions we create in our program.

## 8. Interacting with pointers: part 1

> A pointer is used to indicate the address of the first felt of an element in memory. The pointer can be used to access the element efficiently. For example, a function can accept a pointer as an argument and then access the element at the pointer's address (Cairo documentation).

Suppose we have a variable named `var`:

- `var*` is a pointer to the memory address of the `var` object.
- `[var]` is the value stored at address `var*`.
- `&var` is the address to the `var` object.
- `&[x]` is `x`. Can you see that `x` is a address?

# 9. Implicit arguments

Before explaining how implicit arguments work, a rule: If a `foo()` function calls a function with an implicit argument, `foo()` must also get and return the same implicit argument.

With that said, let's see what a function with an implicit argument looks like. The function is serialize_word which is available in the `starkware.cairo.common.serialize` library and we use it in our initial function to add two numbers.

```python
%builtins output

// Appends a single word to the output pointer, and returns the pointer to the next output cell.
func serialize_word{output_ptr: felt*}(word) {
    assert [output_ptr] = word;
    let output_ptr = output_ptr + 1;
    return ();
}
```

This will be a bit confusing, be prepared. In this and many other cases, it receives `output_ptr`, which is a pointer to a felt type. When we declare that a function receives an implicit argument, the function will automatically return the value of the implicit argument on termination of the function. If we didn't move the value of the implicit argument then it would automatically return the same value it started with. However, if during the function the value of the implicit argument is altered then the new value will be automatically returned. 

In the example with the `serialize_word` function we define that we are going to receive an implicit argument called `output_ptr`. In addition, we also receive an explicit argument called `value`. At the end of the function we will return the value that `output_ptr` has at that moment. During the function we see that `output_ptr`increases by 1: `let output_ptr = output_ptr + 1`. Then the function will implicitly return the new value of `output_ptr`.

Following the rule defined at the beginning, any function that calls `serialize_word` will also have to receive the implicit `output_ptr`. For example, part of our function to add two numbers goes like this:

```python
func main{output_ptr: felt*}():
    alloc_locals

    const NUM1 = 1
    const NUM2 = 10

    let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2)
    serialize_word(word=sum)
    return ()
end
```

We see that we call `serialize_word` so we necessarily have to also ask for the implicit argument `output_ptr` in our `main` function. This is where another property of implicit arguments comes into play, and perhaps why they are called that. We see that when calling `serialize_word` we only pass the explicit `word` argument. The implicit argument `output_ptr` is automatically passed 🤯! Be careful, we could also have made the implicit argument explicit like this: `serialize_word{output_ptr=output_ptr}(word=a)`. Do we already know how to program in Cairo? 🙉

So the implicit argument is implicit because:

1. Inside the implicit function, the final value of the implicit argument is automatically returned.
2. When the implicit function is called, we do not need to indicate that we are going to pass the implicit argument. The default value is automatically included.

## 10. Locals

We are almost ready to understand 100% what we did in our function that adds two numbers. I know, it's been a rocky road 🙉. But there is a rainbow at the end of the tutorial 🌈.

Thus we define a local variable: `local a = 3`.

> Any function that uses a local variable must have an `alloc_locals` declaration, usually at the beginning of the function. This statement is responsible for allocating memory cells used by local variables within the scope of the function (Cairo [documentation](https://www.cairo-lang.org/docs/reference/syntax.html#locals)).
>

As an example, look at this part of our function that adds two numbers:

```python
func sum_two_nums(num1: felt, num2: felt) -> (sum):
    alloc_locals
    local sum = num1+num2
    return(sum)
end

```

It's very simple 💛.

Since we don't want it to be so easy, let's talk from memory. Cairo stores the local variables relative to the frame pointer (`fp`) (we'll go into more detail about the `fp` in a later tutorial). So if we needed the address of a local variable, `&sum` would not suffice as it would give us this error: `using the value fp directly requires defining a variable __fp__`. We can get this value by importing `from starkware.cairo.common.registers import get_fp_and_pc`. `get_fp_and_pc` returns a tuple with the current values of `fp` and `pc`. In the most Python style, we will indicate that we are only interested in the value of `fp` and that we will store it in a variable `__fp__`: `let (__fp__, _) = get_fp_and_pc()`. Done now we could use `&sum`. In another tutorial we will see an example of this.

## **11. Constants

Very simple. Just remember that they must give an integer (a field) when we compile our code. Create a constant:

```python
const NUM1 = 1

```

## **12. References

This is the format to define one:

```python
let ref_name : ref_type = ref_expr

```

Where `ref_type` is a type and `ref_expr` is a Cairo expression. Placing the `ref_type` is optional but it is recommended to do so.

A reference can be reassigned (Cairo [documentation](https://www.cairo-lang.org/docs/reference/syntax.html#references)):

```python
let a = 7  // a is initially bound to expression 7.
let a = 8  // a is now bound to expression 8.

```
In our addition of two numbers we create a reference called `sum`. We see that we assign to `sum` the `felt` that the function `sum_two_nums` returns.

```python
let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2)

```

## 13. Compile and run 𓀀

You already know how to do funtions in Cairo! Now let's run our first program.

The tools that StarkNet offers to interact with the command line are many 🙉. We won't go into detail until later. For now, we will only show the commands with which we can run the application that we created in this tutorial 🧘‍♀️. But don't worry, the commands to run other applications will be very similar.

`cairo-compile` allows us to compile our code and export a json that we will read in the next command. If ours is called `src/sun.cairo` (because it is located in the `src` directory as in this repository) and we want the json to be called `build/sum.json` (because it's in the `build` directory like this repository) then we would use the following code:

```
cairo-compile src/sum.cairo --output build/sum.json`
```

Simple, right? ❤️

Ok now let's run our program with `cairo-run`.

```
cairo-run --program=build/sum.json --print_output --layout=small
```

The result should correctly print an 11 in our terminal.

Here the details:

We indicate in the `--program` argument that we want to run the `build/sum.json` that we generated earlier.

With `--print_output` we indicate that we want to print something from our program to the terminal. For example, in the next tutorial we will use the builtin (we will study them later) output and the serialize_word function to print to the terminal.

`--layout` allows us to indicate the layout to use. Depending on the builtins we use, it will be the layout to use. Later we will be using the output builtin and for this we need the small layout. If we will not use any builtin then we can leave this argument empty so we would use the default layout, the plain layout.

## **14. Conclusion**

Congratulations 🚀. We have learned the basics of 🏖 Cairo. With this knowledge you could identify what is done in each line of our function that adds two integers 🥳. In the following tutorials we will learn more about pointers and memory management; the cairo common library; how the Cairo compiler works; and more!

Any comments or improvements please comment with [@espejelomar](https://twitter.com/espejelomar) or make a PR 🌈.