include("pancakerobot.jl")

file = open("extra/inch_flat_s.csv", "w")
write(file, "low, high, distance, time, BLs\n")
close(file)

r1 = collect(range(0.0001, stop=2.0, length=16))
r2 = collect(range(2.0, stop=4.0, length=16))
sf = [(low, high) for (low, high) in zip(r1, r2)]

for (l, h) in sf
    run_sfriction(l, h)
end

using DataFrames
using CSV

df = CSV.read("extra/inch_flat_s.csv", DataFrame)
mat = zeros(16, 5)

for r in 1:nrow(df)
    l = 0.22
    t = 19.796841683855746
    df[r, :][3] -= 0.1118868738412857
    mat[r, :] = [df[r, :][1], df[r, :][2], df[r, :][3], t, (df[r, :][3]/l)/t]
end

df = DataFrame(low=mat[:, 1], high=mat[:, 2], distance=mat[:, 3], time=mat[:, 4], BLs=mat[:, 5])
CSV.write("extra/sfrict_results.csv", df)