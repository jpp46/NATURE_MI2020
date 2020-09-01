using Statistics
using BSON: @load

function normalize(x, minx, maxx)
    return (x .- minx)./(maxx.-minx)
end

function get_data(folder)
	data = Matrix{Float64}(undef, 61, 201)
	for i in 0:60
		DIR = "$folder/worker_$(lpad(i, 2, "0"))"
		for j in 0:200
			@load "$DIR/$(lpad(j, 4, "0")).bson" worker fit
			data[i+1, j+1] = fit
		end
	end
	return data
	m = mean(data, dims=1)
	v = var(data, dims=1)
	return m, v
end

function write_data(name, t, m, v)
	f = open("data/mean_results.dat", t)
	write(f, "# $name\n")
	write(f, "x, mean, min, max\n")
	for i in 1:length(m)
		write(f, "$(i-1), $(m[i]), $(m[i]-v[i]), $(m[i]+v[i])\n")
	end
	write(f, "\n\n\n")
	close(f)
end

data_0 = get_data("genomes_0")
data_semi_0 = get_data("genomes_semi_0")
data_closed_0 = get_data("genomes_closed_0")
maxx = maximum([maximum(data_0), maximum(data_semi_0), maximum(data_closed_0)])
minx = minimum([minimum(data_0), minimum(data_semi_0), minimum(data_closed_0)])
data_0 = normalize(data_0, minx, maxx)
data_semi_0 = normalize(data_semi_0, minx, maxx)
data_closed_0 = normalize(data_closed_0, minx, maxx)

m = mean(data_0, dims=1)
v = std(data_0, dims=1)
write_data("genomes_0", "w", m, v)
m = mean(data_semi_0, dims=1)
v = std(data_semi_0, dims=1)
write_data("genomes_semi_0", "a", m, v)
m = mean(data_closed_0, dims=1)
v = std(data_closed_0, dims=1)
write_data("genomes_closed_0", "a", m, v)

data_15 = get_data("genomes_15")
data_semi_15 = get_data("genomes_semi_15")
data_closed_15 = get_data("genomes_closed_15")
maxx = maximum([maximum(data_15), maximum(data_semi_15), maximum(data_closed_15)])
minx = minimum([minimum(data_15), minimum(data_semi_15), minimum(data_closed_15)])
data_15 = normalize(data_15, minx, maxx)
data_semi_15 = normalize(data_semi_15, minx, maxx)
data_closed_15 = normalize(data_closed_15, minx, maxx)

m = mean(data_15, dims=1)
v = std(data_15, dims=1)
write_data("genomes_15", "a", m, v)
m = mean(data_semi_15, dims=1)
v = std(data_semi_15, dims=1)
write_data("genomes_semi_15", "a", m, v)
m = mean(data_closed_15, dims=1)
v = std(data_closed_15, dims=1)
write_data("genomes_closed_15", "a", m, v)




function get_data(folder)
	data = Matrix{Float64}(undef, 61, 201)
	for i in 0:60
		DIR = "$folder/worker_$(lpad(i, 2, "0"))"
		for j in 0:200
			@load "$DIR/$(lpad(j, 4, "0")).bson" worker fit
			data[i+1, j+1] = fit
		end
	end
	return data
	m = maximum(data, dims=1)
	return m
end

function write_data(name, t, m)
	f = open("data/max_results.dat", t)
	write(f, "# $name\n")
	write(f, "x, max\n")
	for i in 1:length(m)
		write(f, "$(i-1), $(m[i])\n")
	end
	write(f, "\n\n\n")
	close(f)
end

data_0 = get_data("genomes_0")
data_semi_0 = get_data("genomes_semi_0")
data_closed_0 = get_data("genomes_closed_0")
maxx = maximum([maximum(data_0), maximum(data_semi_0), maximum(data_closed_0)])
minx = minimum([minimum(data_0), minimum(data_semi_0), minimum(data_closed_0)])
data_0 = normalize(data_0, minx, maxx)
data_semi_0 = normalize(data_semi_0, minx, maxx)
data_closed_0 = normalize(data_closed_0, minx, maxx)

m = maximum(data_0, dims=1)
write_data("genomes_0", "w", m)
m = maximum(data_semi_0, dims=1)
write_data("genomes_semi_0", "a", m)
m = maximum(data_closed_0, dims=1)
write_data("genomes_closed_0", "a", m)

data_15 = get_data("genomes_15")
data_semi_15 = get_data("genomes_semi_15")
data_closed_15 = get_data("genomes_closed_15")
maxx = maximum([maximum(data_15), maximum(data_semi_15), maximum(data_closed_15)])
minx = minimum([minimum(data_15), minimum(data_semi_15), minimum(data_closed_15)])
data_15 = normalize(data_15, minx, maxx)
data_semi_15 = normalize(data_semi_15, minx, maxx)
data_closed_15 = normalize(data_closed_15, minx, maxx)

m = maximum(data_15, dims=1)
write_data("genomes_15", "a", m)
m = maximum(data_semi_15, dims=1)
write_data("genomes_semi_15", "a", m)
m = maximum(data_closed_15, dims=1)
write_data("genomes_closed_15", "a", m)

Base.run(`gnuplot plot.gnu`)