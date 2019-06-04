using SymPy

@syms px1 py1 lambda1 vx1 vy1 px2 py2 lambda2 vx2 vy2

lx1 = px1 + lambda1*vx1
ly1 = py1 + lambda1*vy1

lx2 = px2 + lambda2*vx2
ly2 = py2 + lambda2*vy2

lx12 = solve(lx1-lx2, lambda2)[1]
l2i = subs(ly2, lambda2, lx12)

sol = solve(ly1-l2i, lambda1)[1]

xi = simplify(subs(lx1, lambda1, sol))
yi = simplify(subs(ly1, lambda1, sol))
