include("pancakerobot.jl")

r1 = collect(range(0.0001, stop=1.0, length=16))
r2 = reverse(collect(range(1.0, stop=2.0, length=16)))
cf = [(low, high) for (low, high) in zip(r1, r2)]

for (l, h) in cf
    run_cfriction(l, h)
end

using DataFrames
using CSV
l = 0.22
t = 18.7

df = CSV.read("cfrict_results.csv")
mat = zeros(16, 5)

for r in 1:nrow(df)
    mat[r, :] = [df[r, :][1], df[r, :][2], df[r, :][3], t, (df[r, :][3]/l)/t]
end

df = DataFrame(low=mat[:, 1], high=mat[:, 2], distance=mat[:, 3], time=mat[:, 4], BLs=mat[:, 5])
CSV.write("cfrict_results.csv", df)