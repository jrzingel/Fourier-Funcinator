# Test and combine the functions

import Freddie

# Specify function to approximate
f(x) = 2cos(pi*x)+im*sin(x*pi)
n = 5  # number of terms to calculate
L = 1  # what does x need to vary by to display the entire plot

#Freddie.drawsubplots(f, n, L)

path = Freddie.processdrawing("loop.svg"; step=0.1)

series = Freddie.fourier(path, 10)

Freddie.draw(series, frames=500)
#Freddie.drawplot(series)
#Freddie.drawsubplots(series)

#e = Freddie.todesmos(series; dp=5)
#println(e)
