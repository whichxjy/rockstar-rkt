# #lang rockstar

Implementation of [Rockstar](https://codewithrockstar.com) in Racket.

## About Rockstar

According to its creator, Dylan Beattie:

> Rockstar is a dynamically typed computer programming language, designed for creating programs that are also song lyrics. Rockstar is heavily influenced by the lyrical conventions of 1980s hard rock and power ballads.

You can find the Rockstar programming language specification [here](https://codewithrockstar.com/docs).

## Quick Start

1. [Download and install Racket](https://download.racket-lang.org/), which includes DrRacket.

2. Install [rockstar](https://pkgd.racket-lang.org/pkgn/package/rockstar) using raco on the command line:

```
raco pkg install rockstar
```

3. Launch DrRacket and create a new file:

```racket
#lang rockstar

Say "Hello World"
```

4. Click the `Run` button, and you'll see the result:

```
Hello World
```

## Update

```
raco pkg update --update-deps rockstar
```

## Try This

```
#lang rockstar

Midnight takes your heart and your soul
While your heart is as high as your soul
Put your heart without your soul into your heart

Give back your heart

If midnight taking 50, and 40 is 10
Shout "Foo"

Else whisper "Bar"
```

## Implementation

- [x] File format

- [x] Comments

- [ ] Variables

    - [x] Simple variables

    - [x] Common variables

    - [x] Proper variables

    - [ ] Pronouns

- [x] Types

    - [x] Mysterious

    - [x] Null

    - [x] Boolean
    
    - [x] Number

    - [x] String

- [x] Literals and Assignment

- [x] Single Quotes

- [x] Increment and Decrement

- [x] Operators

- [x] Compound Assignment Operators

- [x] List Arithmetic

- [ ] Poetic Literals

- [x] Comparison

- [x] Logical Operations

- [x] Input & Output

- [x] Flow Control and Block Syntax

    - [x] Conditionals

    - [x] Loops

- [x] Functions (may exist bugs)

## See Also

[Why Racket? Why Lisp?](https://practicaltypography.com/why-racket-why-lisp.html)

[Beautiful Racket](https://beautifulracket.com/)