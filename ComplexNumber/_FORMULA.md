# COMPLEX NUMBER FORMULAS

## Note
- These are the formulas used within this module. In some cases, they are chosen by programming convention. In other cases, it might be a bug... oops.
- Formulas are ordered by basic arithmetic operations first, unless another formula within them is not stated before, then this formula will be ordered before it. For example, `Complex Division` needs `Complex Conjugate`, and the `Complex Modulus` to compute it, therefore, those two are ordered before `Complex Division`.

## Formulas
* Let `a = x + y𝒊`, and `b = u + v𝒊` be two complex numbers in its general form, with `x`, `u` be their respective real parts, and `y`, `v` be their respective imaginary part, with an imaginary unit defined as `√(-1) = 𝒊`. From these definitions, one must have the following formulas for complex numbers;

### Complex Addition:
```
a + b
= (x + y𝒊) + (u + v𝒊)
= (x + u) + (y + v)𝒊
```

### Complex Subtraction:
```
a - b
= (x + y𝒊) - (u + v𝒊)
= (x - u) + (y - v)𝒊
```

### Complex Multiplication:
```
a * b
= (x + y𝒊) * (u + v𝒊)
= (x * u) + (x * v𝒊) + (y𝒊 * u) + (y𝒊 * v𝒊)
= (x*u - y*v) + (x*v + y*u)𝒊                                         (𝒊^2 = -1)
```

### Complex conjugate:
```
a = x + y𝒊 -> a' = x - y𝒊
```

### Complex Modulus (Magnitude/Absolute value):
```
a = x + y𝒊
-> |a| = √(x^2 + y^2)                                     (Pythagorean theorem)
```

### Complex Division:
```
a / b                         (b must be a nonzero complex number, b != 0 + 0𝒊)
= a*b' / |b|^2
= (x + y𝒊)*(u - v𝒊) / (u^2 + v^2)
= [(x*u + y*v) + (x*v - y*u)𝒊] / (u^2 + v^2)
= (x*u + y*v) / (u^2 + v^2)  +  (x*v - y*u)𝒊 / (u^2 + v^2)
  ---------- real ---------     ------- imaginary -------
```

### Euler's formula:
```
a = x + y𝒊 = e^(i * x) = exp(𝒊 * x) = cos(x) + 𝒊 sin(x)
```

### cis(theta) trigonometric function: Euler's formula written as a trig function.
```
cis(theta) = cos(theta) + 𝒊 sin(theta) = exp(𝒊 * theta)
```

### Complex argument: Counter-clockwise angle of a complex number from the positive real axis in the complex plane.
```
a = x + y𝒊
arg(a) = arg(x + y𝒊) = atan2(y/x)
```

### Polar form:
```
a = x + y𝒊
= |a| * (cos(arg(a)) + 𝒊 sin(arg(a)))
= |a| * cis(arg(a))
```

### Exponentiation:
```
a^b
= (x + y𝒊)^(u + v𝒊)
= |a|^(u + v𝒊) * cis(arg(a))^(u + v𝒊)                     (de Moivre's formula)
= ???                                          (TBA: idk how this step is done)
= (x^2 + y^2)^(u/2)  *  exp(-v * arg(a))  *  cis(u*arg(a) + v*ln(x^2 + y^2)/2)
  ---- term 1 -----     ---- term 2 ----     ------------ term 3 -------------
```