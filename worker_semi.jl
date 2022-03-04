using Cxx
using Libdl
using LinearAlgebra
using StatsBase
using Colors
using Random

using BSON: @save, @load
include("pancakerobot.jl")

const ID = parse(Int, ARGS[1])
const ARG_ENV = parse(Int, ARGS[2])
const GENERATIONS = 200
const RATE = [90/10, MAX_PRESS/10, 9/10]
const DIR = "genomes_semi_$(ARG_ENV)/worker_$(lpad(ID, 2, "0"))"
if !isfile("$DIR/checkpoint.txt")
	open("$DIR/checkpoint.txt", "w") do f
		write(f, "0")
	end
end
f = open("$DIR/checkpoint.txt", "r")
const START = parse(Int, read(f, String))
close(f)

Random.seed!(ID)

function clip(array, low, high)
	arr = deepcopy(array)
	for i in 1:size(arr)[1]
		for j in 1:size(arr)[2]
			if arr[i, j] <= low
				arr[i, j] = low
			end
			if arr[i, j] >= high
				arr[i, j] = high
			end
		end
	end
	return Int64.(arr)
end

function wrap(array, low, high)
	arr = deepcopy(array)
	for i in 1:size(arr)[1]
		for j in 1:size(arr)[2]
			if arr[i, j] < low
				arr[i, j] = (high + arr[i, j]) + 1
				#arr[i, j] = low
			end
			if arr[i, j] > high
				arr[i, j] = (arr[i, j] - high) - 1
				#arr[i, j] = high
			end
		end
	end
	return Int64.(arr)
end

function new_genome()
	genome = [90, rand(0:MAX_PRESS), rand(0:8, 10, 2)]
	if ARG_ENV == 0
		genome = [0, rand(0:MAX_PRESS), rand(0:8, 10, 2)]
	elseif ARG_ENV == 15
		genome = [90, rand(0:MAX_PRESS), rand(0:8, 10, 2)]
	end
	return genome
end

function mutate_genome(genome)
	# RATE = [2.5, 250.0, 0.25]
	newg = deepcopy(genome)

	gene = round(RATE[2]*randn() + genome[2])
	if gene > MAX_PRESS gene = MAX_PRESS end
	if gene < 0 gene = 0 end
	newg[2] = gene

	gene = round.(RATE[3] .* randn(10, 2) .+ genome[3])
	gene = wrap(gene, 0, 8)
	newg[3] = gene
	return newg
end

worker = Nothing
fit = Nothing
if START > 0
	@load "$DIR/$(lpad(START, 4, "0")).bson" worker fit
else
	worker = new_genome()
	fit, _ = fitness(worker, ARG_ENV)
	@save "$DIR/$(lpad(START, 4, "0")).bson" worker fit
	f = open("$DIR/checkpoint.txt", "w")
	write(f, "$START")
	close(f)
end

for g in START+1:GENERATIONS
	global worker, fit
	spawn = mutate_genome(worker)
	spawn_fit, _ = fitness(spawn, ARG_ENV)
	if spawn_fit > fit
		worker = spawn
		fit = spawn_fit
	end
	
	@save "$DIR/$(lpad(g, 4, "0")).bson" worker fit
	f = open("$DIR/checkpoint.txt", "w")
	write(f, "$g")
	close(f)
	f = open("$DIR/best.txt", "w")
	write(f, "$fit")
	close(f)
end