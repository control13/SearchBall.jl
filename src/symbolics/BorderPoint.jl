using SymPy

@syms d r_off lambda r_opp

# sipler variant
t_x = lambda*(d - r_opp*r_opp/d) # cos(π/2 + asin(r_opp/d)) = -r_opp/d
t_y = lambda*r_opp*sqrt(1 - (r_opp*r_opp)/(d*d)) #  sin(π/2 + asin(r_opp/d)) = sqrt(1 - (r_opp*r_opp)/(d*d))
toff_x = r_off*(r_off - r_opp)/d # cos(π/2 + asin((r_opp - r_off)/d)) = (r_off - r_opp)/d
toff_y = r_off*sqrt(1 - ((r_opp-r_off)/d)^2) # sin(π/2 + asin((r_opp - r_off)/d)) = sqrt(1 - ((r_opp-r_off)/d)^2)

lambda_sol = solve(t_x - toff_x,lambda)[1]
ty_ins = subs(t_y,lambda,lambda_sol)
l = ty_ins - toff_y
sol = solve(l, r_off)
sol[3]

simplify(subs(sol[3],r_opp,1))

using Plots, LaTeXStrings
gr()

f(d::Real, r::Real) = sqrt((d - r)*(d + r)) + r
dist = linspace(2,3,300)
rad = linspace(0,2,300)
surface(dist,rad,f,xlabel=L"d",ylabel=L"r_{opp}",zlabel="way")
