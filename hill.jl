include("pancakerobot.jl")

file = open("extra/roll_hill.csv", "w")
write(file, "slope, distance, time, BL\n")
close(file)

slopes = 0:0.1:15

for slope in slopes
    run_hill(slope)
end

