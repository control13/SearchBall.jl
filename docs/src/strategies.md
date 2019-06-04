# Strategies

## existing strategies

### test strategy, implemented in `36c93bcee127fb4ffc685fb914a8dcb570439a3e` (04.11.17 10.42), but please checkput strategies/TestStrategy.jl from 54a97dc67f5ceffdd5d6abe2c099eb7e7a43c88d
- one offender, one opponent, static ball
- static ``dt``, fixed ``v``
- no borders

#### lonesome optimizend offender
- if he sees the ball, he goes to it
- if there is no ball, he calculates the tangent on his range radius for the ``dt`` on moves to the intersection point (the best, what he can do in this time to see more from the shadowed area)

#### preventing opponent
- moves a linear combination of towards the offender and orthogonal towards the line of sight from the offender and the ball
- if the offender sees the ball, all movement is the way to the line of sight
- else 70% is the way to the offender and the rest towards the line of sight

### ShowShadow
- calculates the shadowarea for one or more offenders

### CompareShadow
- calculates the initial shadow
- shows the current shadow and amount of the intersection of the init and current shadow, also as heatmap for every position

### GlobalComShadow
- resulting shadow for multiple offenders and multiple opponents in common (assumes global communication and omnidirectional view)

## write own strategies

### Give a robot an order

### draw something in the gui

### show text

### add gui elements for adjusting the strategy
