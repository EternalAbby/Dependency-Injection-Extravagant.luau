# COMPLEX NUMBER FORMULAS

## Note

These are formulas that are used within the module. In some edge cases, they are chosen by programming convention. If the result is an unexpected result, it may be a bug... oops.

## Formulas

\* Let `a = x + y𝒊`, and `b = u + v𝒊` be two complex numbers in its general form, with `x`, `u` be their respective real parts, and `y`, `v` be their respective imaginary part, with an imaginary unit defined as `√(-1) = 𝒊`. From these definitions, the following formulas are derived;

### Complex Addition

```txt
a + b
= (x + y𝒊) + (u + v𝒊)
= (x + u) + (y + v)𝒊
```

### Complex Subtraction

```txt
a - b
= (x + y𝒊) - (u + v𝒊)
= (x - u) + (y - v)𝒊
```

### Complex Multiplication

```txt
a * b
= (x + y𝒊) * (u + v𝒊)
= (x * u) + (x * v𝒊) + (y𝒊 * u) + (y𝒊 * v𝒊)
= (x*u - y*v) + (x*v + y*u)𝒊                                         (𝒊^2 = -1)
```

### Complex Division

```txt
a / b                         (b must be a nonzero complex number, b != 0 + 0𝒊)
= a*b' / |b|^2
= (x + y𝒊)*(u - v𝒊) / (u^2 + v^2)
= [(x*u + y*v) + (x*v - y*u)𝒊] / (u^2 + v^2)
= (x*u + y*v) / (u^2 + v^2)  +  (x*v - y*u)𝒊 / (u^2 + v^2)
  ---------- real ---------     ------- imaginary -------
```

### Complex Exponentiation

```txt
a^b
= (x + y𝒊)^(u + v𝒊)
= |a|^(u + v𝒊) * cis(arg(a))^(u + v𝒊)                     (de Moivre's formula)
= ???                                          (TBA: idk how this step is done)
= (x^2 + y^2)^(u/2)  *  exp(-v * arg(a))  *  cis(u*arg(a) + v*ln(x^2 + y^2)/2)
  ---- term 1 -----     ---- term 2 ----     ------------ term 3 -------------
```

### Complex Conjugate

```txt
a = x + y𝒊 -> a' = x - y𝒊
```

### Complex Argument

Counter-clockwise angle of a complex number from the positive real axis in the complex plane.

```txt
a = x + y𝒊
arg(a) = arg(x + y𝒊) = atan2(y/x)
```

### Complex Modulus (Magnitude/Absolute value)

```txt
a = x + y𝒊
-> |a| = √(x^2 + y^2)                                     (Pythagorean theorem)
```

### Euler's Formula

```txt
a = x + y𝒊 = e^(i * x) = exp(𝒊 * x) = cos(x) + 𝒊 sin(x)
```

### cis(theta) Trigonometric Function

Euler's formula written as a trig function. This is how the module evaluates Euler's formulas.

```txt
cis(theta) = cos(theta) + 𝒊 sin(theta) = exp(𝒊 * theta)
```

### Polar Form

```txt
a = x + y𝒊
= |a| * (cos(arg(a)) + 𝒊 sin(arg(a)))
= |a| * cis(arg(a))
```

### Rectangular Form

This is represented as a point on the complex plane.

```txt
a = x + y𝒊
-> a = (x, y)
```
