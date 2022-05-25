using LinearAlgebra
using Colors
using StatsBase
using HypothesisTests
using Random

using BSON: @load

values_hill = []
for i in 1:60
	global values_hill
	DIR = "genomes_roll_hill/"
	@load "$DIR/worker_$(lpad(i, 2, "0"))_results.bson" results
	fit = results[end][3]
	push!(values_hill, fit)
end

values_15 = []
for i in 1:60
	global values_hill
	DIR = "genomes_15/"
	@load "$DIR/worker_$(lpad(i, 2, "0"))_results.bson" results
	fit = results[end][3]
	push!(values_15, fit)
end

x = values_hill
y = values_15
nx, ny = length(x), length(y)
xbar = StatsBase.mean(x)-StatsBase.mean(y)
varx, vary = StatsBase.var(x), StatsBase.var(y)
stderr = sqrt(varx/nx + vary/ny)
t = (xbar-0)/stderr
df = (varx / nx + vary / ny)^2 / ((varx / nx)^2 / (nx - 1) + (vary / ny)^2 / (ny - 1))
test = UnequalVarianceTTest(nx, ny, xbar, df, stderr, t, 0)
@show mean(x), mean(y)
@show pvalue(test)