using Base

run(`rm -rf genomes_closed_0`)
run(`rm -rf genomes_closed_15`)
run(`rm -rf genomes_semi_0`)
run(`rm -rf genomes_semi_15`)
run(`rm -rf genomes_roll_hill`)

for i in [0, 15]
	run(`rm -rf genomes_$i`)
end


run(`mkdir genomes_closed_0`)
run(`mkdir genomes_closed_15`)
run(`mkdir genomes_semi_0`)
run(`mkdir genomes_semi_15`)
run(`mkdir genomes_roll_hill`)

for i in [0, 15]
	run(`mkdir genomes_$i`)
end



