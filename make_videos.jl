using Cxx
using Libdl
using LinearAlgebra
using StatsBase
using Colors
using Random

using BSON: @save, @load
include("pancakerobot.jl")

fitness((90, 0, inch_matrix), 0, 30, "graphs/inch_flat", true)
fitness((90, 0, inch_matrix), 15, 30, "graphs/inch_hill", true)

fitness((0, MAX_PRESS, roll_matrix), 0, 30, "graphs/roll_flat", true)
fitness((0, MAX_PRESS, roll_matrix), 15, 30, "graphs/roll_hill", true)

# Get the best robot from each sample
for E in [0, 15]
	best_worker = nothing; best_fit = -Inf
	for W in 1:60
		DIR = "genomes_$E/worker_$(lpad(W, 2, "0"))"
		@load "$DIR/$(lpad(200, 4, "0")).bson" worker fit
		if fit > best_fit
			best_fit = fit
			best_worker = deepcopy(worker)
		end
	end
	fitness(best_worker, E, 30, "graphs/genomes_$(E)_BEST")

	best_worker = nothing; best_fit = -Inf
	for W in 1:60
		DIR = "genomes_semi_$E/worker_$(lpad(W, 2, "0"))"
		@load "$DIR/$(lpad(200, 4, "0")).bson" worker fit
		if fit > best_fit
			best_fit = fit
			best_worker = deepcopy(worker)
		end
	end
	fitness(best_worker, E, 30, "graphs/genomes_semi_$(E)_BEST")

	best_worker = nothing; best_fit = -Inf
	for W in 1:60
		DIR = "genomes_closed_$E/worker_$(lpad(W, 2, "0"))"
		@load "$DIR/$(lpad(200, 4, "0")).bson" worker fit
		if fit > best_fit
			best_fit = fit
			best_worker = deepcopy(worker)
		end
	end
	fitness(best_worker, E, 30, "graphs/genomes_closed_$(E)_BEST")
end

# Get some random samples for videos
for E in [0, 15]
	for W in rand(1:60, 10)
		DIR = "genomes_$E/worker_$(lpad(W, 2, "0"))"
		@load "$DIR/$(lpad(200, 4, "0")).bson" worker fit
		fitness(worker, E, 30, "graphs/genomes_$(E)_$W")

		DIR = "genomes_semi_$E/worker_$(lpad(W, 2, "0"))"
		@load "$DIR/$(lpad(200, 4, "0")).bson" worker fit
		fitness(worker, E, 30, "graphs/genomes_semi_$(E)_$W")

		DIR = "genomes_closed_$E/worker_$(lpad(W, 2, "0"))"
		@load "$DIR/$(lpad(200, 4, "0")).bson" worker fit
		fitness(worker, E, 30, "graphs/genomes_closed_$(E)_$W")
	end
end