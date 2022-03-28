using Cxx
using Libdl
using LinearAlgebra
using StatsBase
using Colors
using Random
using GLMakie
using Formatting

using BSON: @save, @load
include("Voxelyze.jl")

MAX_INF = 2.5
MIN_INF = 0.2
INF_RATE = 0.0003
MAX_ST_FRIC = 2.0
MIN_ST_FRIC = 0.0001
MAX_K_FRIC = 2.0
MIN_K_FRIC = 0.0001
MAX_PRESS = 12000

mutable struct Sim
	Vx
	dt
	vxMass
	skinMat
	intraMat
	varMat
	sacsMat
	voxels
	topVoxels
	bottomVoxels
	sacVoxels
	gravity
	pressure
	coef
	actMatrix
end


function Sim(vx_size, W, L, E, ρ)
	Vx = Voxelyze(vx_size)
	enableFloor(Vx, true)
	enableCollisions(Vx, true)
	setGravity(Vx, 0)
	setAmbientTemperature(Vx, 0)
	mats, voxs = setVoxels(Vx, W, L, E, ρ)
	return Sim(Vx, recommendedTimeStep(Vx)/1.3, vx_size^3 * ρ, mats[1], mats[2], mats[3], mats[4], voxs[1], voxs[2], voxs[3], voxs[4], [0., 0., 0.], 0, 0, zeros(10, 10))
end


function setVoxels(Vx, W, L, E,     ρ)
	skin = addMaterial(Vx, E, ρ)
	setColor(skin, 0, 255, 0)
	setInternalDamping(skin, 1.0)
	setCollisionDamping(skin, 1.0)
	setStaticFriction(skin, MAX_ST_FRIC)
	setKineticFriction(skin, MAX_K_FRIC)

	intraskin = addMaterial(Vx, E, ρ)
	setColor(intraskin, 0, 255, 0)
	setInternalDamping(intraskin, 1.0)
	setCollisionDamping(intraskin, 1.0)
	setStaticFriction(intraskin, MAX_ST_FRIC)
	setKineticFriction(intraskin, MAX_K_FRIC)
	setExternalScaleFactor(intraskin, 1.0, 1.0, 1.0)
	
	varF = [addMaterial(Vx, E, ρ), addMaterial(Vx, E, ρ), addMaterial(Vx, E, ρ)]
	map(mat -> setColor(mat, 0, 255, 0), varF)
	map(mat -> setInternalDamping(mat, 1.0), varF)
	map(mat -> setCollisionDamping(mat, 1.0), varF)
	map(mat -> setStaticFriction(mat, MAX_ST_FRIC), varF)
	map(mat -> setKineticFriction(mat, MAX_K_FRIC), varF)
	setExternalScaleFactor(varF[3], 0.9, 1.0, 1.0)
	setStaticFriction(varF[3], MIN_ST_FRIC)
	setKineticFriction(varF[3], MIN_K_FRIC)

	
	sacs = [addMaterial(Vx, E/1.8, ρ), addMaterial(Vx, E/1.8, ρ), addMaterial(Vx, E/1.8, ρ), addMaterial(Vx, E/1.8, ρ),
			addMaterial(Vx, E/1.8, ρ), addMaterial(Vx, E/1.8, ρ), addMaterial(Vx, E/1.8, ρ), addMaterial(Vx, E/1.8, ρ)]
	map(mat -> setColor(mat, 0, 0, 255), sacs)
	map(mat -> setInternalDamping(mat, 1.0), sacs)
	map(mat -> setCollisionDamping(mat, 1.0), sacs)
	map(mat -> setStaticFriction(mat, MAX_ST_FRIC/3), sacs)
	map(mat -> setKineticFriction(mat, MAX_K_FRIC/3), sacs)
	map(mat -> setExternalScaleFactor(mat, 1.0, 1.0, MIN_INF), sacs)
	

	voxels = []
	topLayer = []
	bottomLayer = []
	for x in 1:W
		for y in 1:L
			if x in [4, 8, 12]
				if y == 1 || y == 2 || y == 3
					push!(bottomLayer, setVoxel(Vx, varF[3], x, y, 2))
					push!(topLayer, setVoxel(Vx, varF[3], x, y, 3))
				elseif y == L || y == L-1 || y == L-2
					push!(bottomLayer, setVoxel(Vx, varF[3], x, y, 2))
					push!(topLayer, setVoxel(Vx, varF[3], x, y, 3))
				else
					push!(bottomLayer, setVoxel(Vx, intraskin, x, y, 2))
					push!(topLayer, setVoxel(Vx, intraskin, x, y, 3))
				end
			else
				if y == 1 || y == 2 || y == 3
					push!(bottomLayer, setVoxel(Vx, varF[1], x, y, 2))
					push!(topLayer, setVoxel(Vx, varF[1], x, y, 3))
				elseif y == L || y == L-1 || y == L-2
					push!(bottomLayer, setVoxel(Vx, varF[2], x, y, 2))
					push!(topLayer, setVoxel(Vx, varF[2], x, y, 3))
				else
					push!(bottomLayer, setVoxel(Vx, skin, x, y, 2))
					push!(topLayer, setVoxel(Vx, skin, x, y, 3))
				end
			end
		end
	end


	airsacs = Vector{Any}(undef, 8)
	sac1 = []
	sac2 = []
	i = 1
	for x in 1:W
		if x in  [4, 8, 12] # [4, 5, 9, 10, 14, 15]
			if x in  [4, 8, 12] # [5, 10, 15]
				airsacs[i] = [sac1...]
				airsacs[9-i] = [sac2...]
				sac1 = []
				sac2 = []
				i += 1
			end
		else
			for y in 4:L-3
				push!(sac1, setVoxel(Vx, sacs[i], x, y, 4))
				push!(sac1, setVoxel(Vx, sacs[i], x, y, 5))

				push!(sac2, setVoxel(Vx, sacs[9-i], x, y, 1))
				push!(sac2, setVoxel(Vx, sacs[9-i], x, y, 0))
			end
		end
	end
	airsacs[i] = [sac1...]
	airsacs[9-i] = [sac2...]

	for x in 2:(W-1)
		for y in 1:L
			breakLink(Vx, x, y, 2, Z_POS)
		end
	end

	voxels = [topLayer..., bottomLayer..., (airsacs...)...]
	return ((skin, intraskin, varF, sacs), (voxels, topLayer, bottomLayer, [airsacs...]))
end

function polar_cart(r, θ, ϕ)
	x = r*sind(θ)*cosd(ϕ)
	y = r*sind(θ)*sind(ϕ)
	z = r*cosd(θ)
	return [x, y, z]
end

function cart_polar(x, y, z)
	r = √(x^2 + y^2 + z^2)
	θ = acosd(z/r)
	ϕ = atand(y/x)
	return [r, θ, ϕ]
end

function setEnv(sim, slope, orientation)
	r = 9.80665
	θ = 180 + slope
	ϕ = orientation
	g = polar_cart(r, θ, ϕ)

	gravity = 1 .* g .* sim.vxMass
	for vx in sim.voxels
		setForce(vx, gravity...)
	end
	sim.gravity = gravity
end


function setPressure(sim, pressure)
	sim.pressure = pressure
	sim.coef = stretchCoef(pressure)
end

function setActuactionMatrix(sim, matrix)
	@assert(size(matrix)[1] == 10)
	@assert(size(matrix)[2] > 0)
	sim.actMatrix = matrix
end

function initialize(sim, frame_rate)
	nodes = []
	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	push!(nodes, getMesh(pMesh))
	gsave = sim.gravity
	sim.gravity = [0, 0, -9.80665] .* sim.vxMass
	for i in 0:0.5:sim.pressure
		applyPressure(sim, i)
		setAmbientTemperature(sim.Vx, 0)
		doTimeStep(sim.Vx, sim.dt)
		if i % frame_rate == 0
			generateMesh(pMesh)
			push!(nodes, getMesh(pMesh))
		end
	end
	for i in 1:6000
		step(sim)
		if i % frame_rate == 0
			generateMesh(pMesh)
			push!(nodes, getMesh(pMesh))
		end
	end
	sim.gravity = gsave
	return nodes
end

function initialize(sim)
	gsave = sim.gravity
	sim.gravity = [0, 0, -9.80665] .* sim.vxMass
	for i in 0:0.5:sim.pressure
		applyPressure(sim, i)
		setAmbientTemperature(sim.Vx, 0)
		doTimeStep(sim.Vx, sim.dt)
	end
	for i in 1:2000
		step(sim)
	end
	sim.gravity = gsave
end

function applyPressure(sim, pressure)
	for vx in sim.topVoxels
		position(vx)
		p1 = cornerPosition(vx, PPP)
		p2 = cornerPosition(vx, NPP)
		p3 = cornerPosition(vx, PNP)
		x = p2-p1
		y = p3-p1
		n = pressure .* cross(x, y)
		n .+= sim.gravity
		setForce(vx, n...)
	end
	for vx in sim.bottomVoxels
		position(vx)
		p1 = cornerPosition(vx, PPN)
		p2 = cornerPosition(vx, NPN)
		p3 = cornerPosition(vx, PNN)
		x = p2-p1
		y = p3-p1
		n = -pressure .* cross(x, y)
		n .+= sim.gravity
		setForce(vx, n...)
	end
end

function step(sim)
	setAmbientTemperature(sim.Vx, 0)
	applyPressure(sim, sim.pressure)
	doTimeStep(sim.Vx, sim.dt)
end

function increaseFric(mat)
	setStaticFriction(mat, MAX_ST_FRIC)
	setKineticFriction(mat, MAX_K_FRIC)
	return true
end

function decreaseFric(mat)
	setStaticFriction(mat, MIN_ST_FRIC)
	setKineticFriction(mat, MIN_K_FRIC)
	return true
end

function stretchCoef(pressure)
	a = 1.7
	b = 10
	return (b - a) * ((pressure - 0)/(MAX_PRESS- 0)) + a
end

function inflate(mat, coef)
	ext = externalScaleFactor(mat)
	inf = [INF_RATE/20, INF_RATE/coef, INF_RATE]
	if ext[3] >= MAX_INF
		return true
	else
		setExternalScaleFactor(mat, (ext .+ inf)...)
	end
	return false
end

function deflate(mat, coef)
	ext = externalScaleFactor(mat)
	inf = [INF_RATE/20, INF_RATE/coef, INF_RATE]
	if ext[3] <= MIN_INF
		return true
	else
		setExternalScaleFactor(mat, (ext .- inf)...)
	end
	return false
end

function run(sim, frame_rate)
	nodes = []
	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	push!(nodes, getMesh(pMesh))
	for r in 1:2
		for i in 1:size(sim.actMatrix)[2]
			println(i)
			map(mat -> setGlobalDamping(mat, 0.002), sim.varMat)
			map(mat -> setGlobalDamping(mat, 0.002), sim.sacsMat)
			setGlobalDamping(sim.skinMat, 0.002)
			setGlobalDamping(sim.intraMat, 0.002)
			act = sim.actMatrix[:, i]
			for j in 1:2
				if act[8+j] == 0
					decreaseFric(sim.varMat[j])
				elseif act[8+j] == 1
					increaseFric(sim.varMat[j])
				end
			end

			done = zeros(Bool, 8)
			k = 0
			while sum(done) < 8
				for j in 1:8
					if act[j] == 0 && !done[j]
						done[j] = deflate(sim.sacsMat[j], sim.coef)
						if done[j]
							map(vx -> setForce(vx, (sim.gravity.*1.0)...), sim.sacVoxels[j])
						else
							map(vx -> setForce(vx, (sim.gravity.*0.0)...), sim.sacVoxels[j])
						end
					elseif act[j] == 1 && !done[j]
						done[j] = inflate(sim.sacsMat[j], sim.coef)
						map(vx -> setForce(vx, (sim.gravity.*0.0)...), sim.sacVoxels[j])
					end
				end
				step(sim)
				if k % frame_rate == 0
					generateMesh(pMesh)
					push!(nodes, getMesh(pMesh))
				end
				k += 1
			end
			map(mat -> setGlobalDamping(mat, 0.01), sim.varMat)
			map(mat -> setGlobalDamping(mat, 0.01), sim.sacsMat)
			setGlobalDamping(sim.skinMat, 0.01)
			setGlobalDamping(sim.intraMat, 0.01)
			map(increaseFric, sim.varMat)
			for j in 0:4000
				step(sim)
				if j % frame_rate == 0
					generateMesh(pMesh)
					push!(nodes, getMesh(pMesh))
				end
			end
		end
	end
	return nodes
end

function run(sim)
	t = 0
	for r in 1:2
		for i in 1:size(sim.actMatrix)[2]
			println(i)
			map(mat -> setGlobalDamping(mat, 0.002), sim.varMat)
			map(mat -> setGlobalDamping(mat, 0.002), sim.sacsMat)
			setGlobalDamping(sim.skinMat, 0.002)
			setGlobalDamping(sim.intraMat, 0.002)
			act = sim.actMatrix[:, i]
			for j in 1:2
				if act[8+j] == 0
					decreaseFric(sim.varMat[j])
				elseif act[8+j] == 1
					increaseFric(sim.varMat[j])
				end
			end

			done = zeros(Bool, 8)
			while sum(done) < 8
				for j in 1:8
					if act[j] == 0 && !done[j]
						done[j] = deflate(sim.sacsMat[j], sim.coef)
						if done[j]
							map(vx -> setForce(vx, (sim.gravity.*1.0)...), sim.sacVoxels[j])
						else
							map(vx -> setForce(vx, (sim.gravity.*0.0)...), sim.sacVoxels[j])
						end
					elseif act[j] == 1 && !done[j]
						done[j] = inflate(sim.sacsMat[j], sim.coef)
						map(vx -> setForce(vx, (sim.gravity.*0.0)...), sim.sacVoxels[j])
					end
				end
				step(sim)
				t+=1
			end
			map(mat -> setGlobalDamping(mat, 0.01), sim.varMat)
			map(mat -> setGlobalDamping(mat, 0.01), sim.sacsMat)
			setGlobalDamping(sim.skinMat, 0.01)
			setGlobalDamping(sim.intraMat, 0.01)
			map(increaseFric, sim.varMat)
			for j in 0:4000
				step(sim)
				t+=1
			end
		end
	end
	return t
end

function make_row(f, ϕ)
	if f == 0
		return ones(Int64, 8)
	end
	x = zeros(Int64, 8)
	for i in ϕ+1:f+1:8
		if i > 8
			continue
		end
		x[i] = 1
	end

	for i in ϕ+1:-(f+1):1
		if i > 8
			continue
		end
		x[i] = 1
	end
	return x
end

function actuation_matrix(genome)
	f = genome[:, 1]
	ϕ = genome[:, 2]
	act_mat = zeros(Int64, 10, 8)
	for r in 1:10
		act_mat[r, :] = make_row(f[r], ϕ[r])
	end
	return act_mat
end

function fitness(genome, env, frame_rate, fname, direct=true)
	sim = Sim(0.01, 15, 22, 400000, 3000)
	setEnv(sim, env, genome[1])
	setPressure(sim, genome[2])
	setActuactionMatrix(sim, genome[3])
	nodes = initialize(sim, frame_rate)
	nodes = [nodes..., (run(sim, frame_rate))...]

	coordinates = Observable(nodes[1][1])
	connectivity = Observable(nodes[1][2])
	colors = Observable(nodes[1][3])

	
	figure, axis, plot = mesh(coordinates, connectivity, color=colors, show_axis=false)
	surface!(axis.scene, range(-10, stop=10, length=400), range(-10, stop=10, length=400), randn(400, 400).*0.0001 .- 0.01, colormap=:Spectral)
	update_cam!(axis.scene, eyepos(nodes[1][1], genome[1]), lookat(nodes[1][1]))
	if env == 15 rotate_cam!(axis.scene, 0.0, 0.0, -0.25) end
	record(figure, "$(fname).mp4", 1:length(nodes)) do i
		coordinates[] = nodes[i][1]
		connectivity[] = nodes[i][2]
		colors[] = nodes[i][3]
		notify.((coordinates, connectivity, colors))
		update_cam!(axis.scene, eyepos(nodes[i][1], genome[1]), lookat(nodes[i][1]))
		if env == 15 rotate_cam!(axis.scene, 0.0, 0.0, -0.25) end
	end

	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	vertices = getMesh(pMesh)[1]
	cm = mean(vertices, dims=1)
	vector_dir = polar_cart(1, 90, genome[1])
	return dot(cm, vector_dir)
end

function fitness(genome, env, frame_rate, fname)
	sim = Sim(0.01, 15, 22, 400000, 3000)
	setEnv(sim, env, genome[1])
	setPressure(sim, genome[2])
	setActuactionMatrix(sim, actuation_matrix(genome[3]))
	nodes = initialize(sim, frame_rate)
	nodes = [nodes..., (run(sim, frame_rate))...]
	
	coordinates = Observable(nodes[1][1])
	connectivity = Observable(nodes[1][2])
	colors = Observable(nodes[1][3])

	figure, axis, plot = mesh(coordinates, connectivity, color=colors, show_axis=false)
	surface!(axis.scene, range(-10, stop=10, length=400), range(-10, stop=10, length=400), randn(400, 400).*0.0001 .- 0.01, colormap=:Spectral)
	update_cam!(axis.scene, eyepos(nodes[1][1], genome[1]), lookat(nodes[1][1]))
	if env == 15 rotate_cam!(axis.scene, 0.0, 0.0, -0.25) end
	record(figure, "$(fname).mp4", 1:length(nodes)) do i
		coordinates[] = nodes[i][1]
		connectivity[] = nodes[i][2]
		colors[] = nodes[i][3]
		notify.((coordinates, connectivity, colors))
		update_cam!(axis.scene, eyepos(nodes[i][1], genome[1]), lookat(nodes[i][1]))
		if env == 15 rotate_cam!(axis.scene, 0.0, 0.0, -0.25) end
	end

	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	vertices = getMesh(pMesh)[1]
	cm = mean(vertices, dims=1)
	vector_dir = polar_cart(1, 90, genome[1])
	return dot(cm, vector_dir)
end

function fitness(genome, env, direct=true)
	sim = Sim(0.01, 15, 22, 400000, 3000)
	setEnv(sim, env, genome[1])
	setPressure(sim, genome[2])
	setActuactionMatrix(sim, genome[3])
	initialize(sim)

	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	vertices = getMesh(pMesh)[1]
	cm_prev = mean(vertices, dims=1)

	nt = run(sim)

	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	vertices = getMesh(pMesh)[1]
	cm = mean(vertices, dims=1)
	
	vector_dir = polar_cart(1, 90, genome[1])
	return dot(cm, vector_dir) - dot(cm_prev, vector_dir), nt
end

function fitness(genome, env)
	sim = Sim(0.01, 15, 22, 400000, 3000)
	setEnv(sim, env, genome[1])
	setPressure(sim, genome[2])
	setActuactionMatrix(sim, actuation_matrix(genome[3]))
	initialize(sim)

	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	vertices = getMesh(pMesh)[1]
	cm_prev = mean(vertices, dims=1)

	nt = run(sim)

	pMesh = MeshRender(sim.Vx)
	generateMesh(pMesh)
	vertices = getMesh(pMesh)[1]
	cm = mean(vertices, dims=1)
	
	vector_dir = polar_cart(1, 90, genome[1])
	return dot(cm, vector_dir) - dot(cm_prev, vector_dir), nt
end

empty_matrix = [
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
		]

inch_matrix = [
		  	1 0 1 0 1 0 1 0;
		  	1 0 1 0 1 0 1 0;
		  	1 0 1 0 1 0 1 0;
		  	1 0 1 0 1 0 1 0;
		  	0 0 0 0 0 0 0 0;
		  	0 0 0 0 0 0 0 0;
		  	0 0 0 0 0 0 0 0;
		  	0 0 0 0 0 0 0 0;
		  	0 1 0 1 0 1 0 1;
		  	1 0 1 0 1 0 1 0;
		]

roll_matrix = [
			0 0 0 0 0 0 0 1;
			0 0 0 0 0 0 1 0;
			0 0 0 0 0 1 0 0;
			0 0 0 0 1 0 0 0;
			0 0 0 1 0 0 0 0;
			0 0 1 0 0 0 0 0;
			0 1 0 0 0 0 0 0;
			1 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
			0 0 0 0 0 0 0 0;
		]

function run_hill(slope)
	path = "extra/roll_hill"
	
	f, nt = fitness((0, MAX_PRESS, roll_matrix), slope, true)
	file = open("$(path).csv", "a")
	write(file, "$slope, $f, 19.796841683855746, $(f/0.22)\n")
	close(file)
end

function run_sfriction(min_f, max_f)
	global MAX_ST_FRIC, MIN_ST_FRIC, MAX_K_FRIC, MIN_K_FRIC
	MAX_ST_FRIC = max_f
	MIN_ST_FRIC = min_f
	MAX_K_FRIC = max_f
	MIN_K_FRIC = min_f
	low = format(min_f, precision=2)
	high = format(max_f, precision=2)
	path = "extra/inch_flat_s"
	
	f, nt = fitness((90, 0, inch_matrix), 0, true)
	file = open("$(path).csv", "a")
	write(file, "$low, $high, $f, 19.796841683855746, $(f/0.22)\n")
	close(file)
end

function run_cfriction(min_f, max_f)
	global MAX_ST_FRIC, MIN_ST_FRIC, MAX_K_FRIC, MIN_K_FRIC
	MAX_ST_FRIC = max_f
	MIN_ST_FRIC = min_f
	MAX_K_FRIC = max_f
	MIN_K_FRIC = min_f
	low = format(min_f, precision=2)
	high = format(max_f, precision=2)
	path = "extra/inch_flat_c"
	
	f, nt = fitness((90, 0, inch_matrix), 0, true)
	file = open("$(path).csv", "a")
	write(file, "$low, $high, $f, 19.796841683855746, $(f/0.22)\n")
	close(file)
end

