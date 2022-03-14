using Cxx
using Libdl
using LinearAlgebra
using StatsBase
using Colors
using Random

include("pancakerobot.jl")
l = 0.22
t = 19.796841683855746
dt= 0.00010602478421508119

file = open("extra/baselines.txt", "w")
write(file, "dt=$dt\nstep_per_act≈11670\n\n")

f, nt = fitness((0, MAX_PRESS, empty_matrix), 0, true)
write(file, "nsteps=>$nt\nfitness((0, MAX_PRESS, empty_matrix), 0, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((90, MAX_PRESS, empty_matrix), 15, true)
write(file, "nsteps=>$nt\nfitness((90, MAX_PRESS, empty_matrix), 15, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((0, 0, empty_matrix), 0, true)
write(file, "nsteps=>$nt\nfitness((0, 0, empty_matrix), 0, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((90, 0, empty_matrix), 15, true)
write(file, "nsteps=>$nt\nfitness((90, 0, empty_matrix), 15, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((90, 0, inch_matrix), 0, true)
write(file, "nsteps=>$nt\nfitness((90, 0, inch_matrix), 0, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((90, 0, inch_matrix), 15, true)
write(file, "nsteps=>$nt\nfitness((90, 0, inch_matrix), 15, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((0, MAX_PRESS, roll_matrix), 0, true)
write(file, "nsteps=>$nt\nfitness((0, MAX_PRESS, roll_matrix), 0, true)=>$f\nBLs=>$((f/l)/t)\n\n")

f, nt = fitness((0, MAX_PRESS, roll_matrix), 15, true)
write(file, "nsteps=>$nt\nfitness((0, MAX_PRESS, roll_matrix), 15, true)=>$f\nBLs=>$((f/l)/t)\n\n")

close(file)




