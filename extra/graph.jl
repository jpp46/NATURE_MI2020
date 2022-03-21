using Plots, DataFrames, CSV
pyplot(size=(400,350))

df = DataFrame(CSV.File("cfrict_results.csv"))
x = reverse((df.high .- df.low))
y = reverse(df.BLs)

plt = plot(x, y, seriestype=:scatter, markercolor=:black)
plot!(plt, x, y,
	xlabel="Δμ (N/N)", ylabel="Speed (BL/s)",
	title=nothing, legend=:none,
	grid=false, linecolor=:black
)
plot!(plt, x, zeros(length(x)), linestyle=:dash, linecolor=:black)
savefig(plt, "fig_d.png")


df = DataFrame(CSV.File("sfrict_results.csv"))
x = (df.high .+ df.low) ./ 2
y = df.BLs

plt = plot(x, y, seriestype=:scatter, markercolor=:black)
plot!(plt, x, y,
	xlabel="μₘ (N/N)", ylabel="Speed (BL/s)",
	title=nothing, legend=:none,
	grid=false, linecolor=:black
)
savefig(plt, "fig_e.png")