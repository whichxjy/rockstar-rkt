# #lang rockstar

Implementation of [Rockstar]((https://codewithrockstar.com)) in Racket.

## Quick Start

1. [Download and install Racket](https://download.racket-lang.org/), which includes DrRacket.

2. Install `rockstar` using raco on the command line:

```
raco pkg install rockstar
```

3. Launch DrRacket and create a new file:

```racket
#lang rockstar

Say "Hello World"
```

4. Click the `Run` button, you'll see the result:

```
Hello World
```

## Update

```
raco pkg update --update-deps rockstar
```

## Try it

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

## See also

[Why Racket? Why Lisp?](https://practicaltypography.com/why-racket-why-lisp.html)

[Beautiful Racket](https://beautifulracket.com/)