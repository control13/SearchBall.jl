using Coverage
a = analyze_malloc(".")
map(println, a[end-9:end]);
getbytes(x) = x.bytes
println(sum(getbytes.(a)))
