using Base

run(`sbatch --array=1-60%10 g0.script`)
run(`sbatch --array=1-60%10 g15.script`)
run(`sbatch --array=1-60%10 g0_closed.script`)
run(`sbatch --array=1-60%10 g15_closed.script`)
run(`sbatch --array=1-60%10 g0_semi.script`)
run(`sbatch --array=1-60%10 g15_semi.script`)
run(`sbatch --array=1-60%10 grh.script`)