using Base

run(`mkdir genomes_closed_0`)
for j in 0:60
	DIR = "genomes_closed_0/worker_$(lpad(j, 2, "0"))"
	run(`mkdir $DIR`)
	open("$DIR/checkpoint.txt", "w") do f
		write(f, "0")
	end
end

run(`mkdir genomes_closed_15`)
for j in 0:60
	DIR = "genomes_closed_15/worker_$(lpad(j, 2, "0"))"
	run(`mkdir $DIR`)
	open("$DIR/checkpoint.txt", "w") do f
		write(f, "0")
	end
end


run(`mkdir genomes_semi_0`)
for j in 0:60
	DIR = "genomes_semi_0/worker_$(lpad(j, 2, "0"))"
	run(`mkdir $DIR`)
	open("$DIR/checkpoint.txt", "w") do f
		write(f, "0")
	end
end

run(`mkdir genomes_semi_15`)
for j in 0:60
	DIR = "genomes_semi_15/worker_$(lpad(j, 2, "0"))"
	run(`mkdir $DIR`)
	open("$DIR/checkpoint.txt", "w") do f
		write(f, "0")
	end
end


run(`mkdir genomes_roll_hill`)
for j in 0:60
	DIR = "genomes_roll_hill/worker_$(lpad(j, 2, "0"))"
	run(`mkdir $DIR`)
	open("$DIR/checkpoint.txt", "w") do f
		write(f, "0")
	end
end


for i in [0, 15]
	run(`mkdir genomes_$i`)
	for j in 0:60
		DIR = "genomes_$i/worker_$(lpad(j, 2, "0"))"
		run(`mkdir $DIR`)
		open("$DIR/checkpoint.txt", "w") do f
			write(f, "0")
		end
	end
end



