using Statistics
using BSON: @load

using Plots
pyplot(size=(500,400))

const len = 0.22
const time = 19.796841683855746

function normalize(x, minx, maxx)
    return (x .- minx)./(maxx.-minx)
end

function get_data(folder, offset)
	data = Matrix{Float64}(undef, 60, 201)
	for i in 1:60
		DIR = "$folder/worker_$(lpad(i, 2, "0"))"
		for j in 0:200
			@load "$DIR/$(lpad(j, 4, "0")).bson" worker fit
			data[i, j+1] = fit-offset
		end
	end
	return data
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

data_0 = get_data("genomes_0", 0.0797998309135437)
println("0 Open => Max: $((maximum(data_0, dims=1)[1, end]/len)/time), Mean: $((mean(data_0, dims=1)[1, end]/len)/time)")
data_semi_0 = get_data("genomes_semi_0", 0.0797998309135437)
println("0 Semi => Max: $((maximum(data_semi_0, dims=1)[1, end]/len)/time), Mean: $((mean(data_semi_0, dims=1)[1, end]/len)/time)")
data_closed_0 = get_data("genomes_closed_0", 0.0797998309135437)
println("0 Closed => Max: $((maximum(data_closed_0, dims=1)[1, end]/len)/time), Mean: $((mean(data_closed_0, dims=1)[1, end]/len)/time)")
maxx = maximum([maximum(data_0), maximum(data_semi_0), maximum(data_closed_0)])
minx = minimum([minimum(data_0), minimum(data_semi_0), minimum(data_closed_0)])
data_0 = normalize(data_0, minx, maxx)
data_semi_0 = normalize(data_semi_0, minx, maxx)
data_closed_0 = normalize(data_closed_0, minx, maxx)

mx = maximum(data_0, dims=1)
m = mean(data_0, dims=1)
v = std(data_0, dims=1)
plt = plot(0:200, m[:], ribbon=v[:],
	title="Flat Surface", xlabel="Generations", ylabel="Normalized Fitness",
	label="Orientation,Shape,Control", legend=:none, grid=false,
	linecolor=:blue, fill=:blue, fillalpha=0.15, ylims=(0.2,1.0)
)
plot!(plt, mx[:], linecolor=:blue, linestyle=:dash, label=nothing)
write_data("genomes_0", "w", m, v)

mx = maximum(data_semi_0, dims=1)
m = mean(data_semi_0, dims=1)
v = std(data_semi_0, dims=1)
plot!(plt, 0:200, m[:], ribbon=v[:],
	title="Flat Surface", xlabel="Generations", ylabel="Normalized Fitness",
	label="Shape,Control", legend=:none, grid=false,
	linecolor=:green, fill=:green, fillalpha=0.15, ylims=(0.2,1.0)
)
plot!(plt, mx[:], linecolor=:green, linestyle=:dash, label=nothing)
write_data("genomes_semi_0", "a", m, v)

mx = maximum(data_closed_0, dims=1)
m = mean(data_closed_0, dims=1)
v = std(data_closed_0, dims=1)
plot!(plt, 0:200, m[:], ribbon=v[:],
	title="Flat Surface", xlabel="Generations", ylabel="Normalized Fitness",
	label="Control", legend=:none, grid=false,
	linecolor=:red, fill=:red, fillalpha=0.15, ylims=(0.2,1.0)
)
plot!(plt, mx[:], linecolor=:red, linestyle=:dash, label=nothing)
write_data("genomes_closed_0", "a", m, v)
savefig(plt, "graphs/flat.png")




data_15 = get_data("genomes_15", 0.1118868738412857)
println("15 Open => Max: $((maximum(data_15, dims=1)[1, end]/len)/time), Mean: $((mean(data_15, dims=1)[1, end]/len)/time)")
data_semi_15 = get_data("genomes_semi_15", 0.1118868738412857)
println("15 Semi => Max: $((maximum(data_semi_15, dims=1)[1, end]/len)/time), Mean: $((mean(data_semi_15, dims=1)[1, end]/len)/time)")
data_closed_15 = get_data("genomes_closed_15", 0.1118868738412857)
println("15 Closed => Max: $((maximum(data_closed_15, dims=1)[1, end]/len)/time), Mean: $((mean(data_closed_15, dims=1)[1, end]/len)/time)")
maxx = maximum([maximum(data_15), maximum(data_semi_15), maximum(data_closed_15)])
minx = minimum([minimum(data_15), minimum(data_semi_15), minimum(data_closed_15)])
data_15 = normalize(data_15, minx, maxx)
data_semi_15 = normalize(data_semi_15, minx, maxx)
data_closed_15 = normalize(data_closed_15, minx, maxx)

mx = maximum(data_15, dims=1)
m = mean(data_15, dims=1)
v = std(data_15, dims=1)
plt = plot(0:200, m[:], ribbon=v[:],
	title="Inclined Surface", xlabel="Generations", ylabel="Normalized Fitness",
	label="Orientation,Shape,Control", legend=:bottomright, grid=false,
	linecolor=:blue, fill=:blue, fillalpha=0.15, ylims=(0.8,1.0)
)
plot!(plt, mx[:], linecolor=:blue, linestyle=:dash, label=nothing)
write_data("genomes_15", "a", m, v)

mx = maximum(data_semi_15, dims=1)
m = mean(data_semi_15, dims=1)
v = std(data_semi_15, dims=1)
plot!(plt, 0:200, m[:], ribbon=v[:],
	title="Inclined Surface", xlabel="Generations", ylabel="Normalized Fitness",
	label="Shape,Control", legend=:bottomright, grid=false,
	linecolor=:green, fill=:green, fillalpha=0.15, ylims=(0.8,1.0)
)
plot!(plt, mx[:], linecolor=:green, linestyle=:dash, label=nothing)
write_data("genomes_semi_15", "a", m, v)

mx = maximum(data_closed_15, dims=1)
m = mean(data_closed_15, dims=1)
v = std(data_closed_15, dims=1)
plot!(plt, 0:200, m[:], ribbon=v[:],
	title="Inclined Surface", xlabel="Generations", ylabel="Normalized Fitness",
	label="Control", legend=:bottomright, grid=false,
	linecolor=:red, fill=:red, fillalpha=0.15, ylims=(0.8,1.0)
)
plot!(plt, mx[:], linecolor=:red, linestyle=:dash, label=nothing)
write_data("genomes_closed_15", "a", m, v)
savefig(plt, "graphs/hill.png")









function get_data(folder, offset)
	data = Matrix{Float64}(undef, 60, 201)
	for i in 1:60
		DIR = "$folder/worker_$(lpad(i, 2, "0"))"
		for j in 0:200
			@load "$DIR/$(lpad(j, 4, "0")).bson" worker fit
			data[i, j+1] = fit-offset
		end
	end
	return data
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

data_0 = get_data("genomes_0", 0.0797998309135437)
data_semi_0 = get_data("genomes_semi_0", 0.0797998309135437)
data_closed_0 = get_data("genomes_closed_0", 0.0797998309135437)
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

data_15 = get_data("genomes_15", 0.1118868738412857)
data_semi_15 = get_data("genomes_semi_15", 0.1118868738412857)
data_closed_15 = get_data("genomes_closed_15", 0.1118868738412857)
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

#Base.run(`gnuplot plot.gnu`)