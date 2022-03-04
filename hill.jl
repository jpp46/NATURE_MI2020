include("pancakerobot.jl")

slopes = 0:0.1:15

for slope in slopes
    run_hill(slope)
end

