# Test and combine the functions

import Fourier

# Specify function to approximate
f(x) = 2cos(pi*x)+im*sin(x*pi)
n = 5  # number of terms to calculate
L = 1  # what does x need to vary by to display the entire plot

#Fourier.drawsubplots(f, n, L)


path = Fourier.processdrawing("james.svg"; step=0.1)


series = Fourier.fourier(path, 30)

Fourier.createvideo(series)
#Fourier.draw(series)
Fourier.drawsubplots(series)

#e = Fourier.todesmos(series; dp=5)
#println(e)
