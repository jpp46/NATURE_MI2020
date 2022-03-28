using Cxx
using Libdl
using LinearAlgebra
using StatsBase
using Colors
using Random

using BSON: @save, @load
include("pancakerobot.jl")

#fitness((90, 0, inch_matrix), 0, 30, "graphs/inch_flat", true)
#fitness((90, 0, inch_matrix), 15, 30, "graphs/inch_hill", true)

#fitness((0, MAX_PRESS, roll_matrix), 0, 30, "graphs/roll_flat", true)
#fitness((0, MAX_PRESS, roll_matrix), 15, 30, "graphs/roll_hill", true)

#= Get the best robot from each sample
for E in [0, 15]
	best_worker = nothing; best_fit = -Inf
	for W in 1:60
		File = "genomes_$E/worker_$(lpad(W, 2, "0"))_results.bson"
		@load File results
		g, worker, fit, rng = results[end]
		if fit > best_fit
			best_fit = fit
			best_worker = deepcopy(worker)
		end
	end
	fitness(best_worker, E, 30, "graphs/genomes_$(E)_BEST")

	best_worker = nothing; best_fit = -Inf
	for W in 1:60
		File = "genomes_semi_$E/worker_$(lpad(W, 2, "0"))_results.bson"
		@load File results
		g, worker, fit, rng = results[end]
		if fit > best_fit
			best_fit = fit
			best_worker = deepcopy(worker)
		end
	end
	fitness(best_worker, E, 30, "graphs/genomes_semi_$(E)_BEST")

	best_worker = nothing; best_fit = -Inf
	for W in 1:60
		File = "genomes_closed_$E/worker_$(lpad(W, 2, "0"))_results.bson"
		@load File results
		g, worker, fit, rng = results[end]
		if fit > best_fit
			best_fit = fit
			best_worker = deepcopy(worker)
		end
	end
	fitness(best_worker, E, 30, "graphs/genomes_closed_$(E)_BEST")
end=#

# Get some random samples for videos
for E in [0, 15]
	for W in rand(1:60, 10)
		File = "genomes_$E/worker_$(lpad(W, 2, "0"))_results.bson"
		@load File results
		g, worker, fit, rng = results[end]
		fitness(worker, E, 30, "graphs/genomes_$(E)_$W")

		File = "genomes_semi_$E/worker_$(lpad(W, 2, "0"))_results.bson"
		@load File results
		g, worker, fit, rng = results[end]
		fitness(worker, E, 30, "graphs/genomes_semi_$(E)_$W")

		File = "genomes_closed_$E/worker_$(lpad(W, 2, "0"))_results.bson"
		@load File results
		g, worker, fit, rng = results[end]
		fitness(worker, E, 30, "graphs/genomes_closed_$(E)_$W")
	end
end