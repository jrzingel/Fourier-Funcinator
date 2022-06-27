# Test and combine the functions

import Fourier
using Plots

# Specify function to approximate
f(x) = 2cos(pi*x)+im*sin(x*pi)
n = 5  # number of terms to calculate
L = 1  # what does x need to vary by to display the entire plot

#anim = Fourier.animatemath(f, n, L)
#Fourier.render(anim, 15)


path = Fourier.processdrawing("james.svg"; step=0.1)

plot(path[:, 1], path[:, 2])


series = Fourier.fourier(path, 30)
Fourier.draw(series)

e = Fourier.todesmos(series; dp=5)
println(e)

#anim = Fourier.makeanimation(series)
#Fourier.render(anim, 10)