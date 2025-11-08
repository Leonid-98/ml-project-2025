#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --time=04:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=jupyter
#SBATCH --output=slurm-jupyter-%j.out
set -euo pipefail

# Activate your venv
source "$HOME/.env/bin/activate"

nvidia-smi || true
export XDG_RUNTIME_DIR=""

# Port/IP
ipnport=$(shuf -i 8000-8080 -n 1)
ipnip=$(hostname -i | awk '{print $1}')
login_host="rocket.hpc.ut.ee"
user_name="$(whoami)"

# Use your actual home dir (on GPFS) or fall back to submit dir
NOTEBOOK_DIR="${HOME}/ml-project-2025"
[ -d "$NOTEBOOK_DIR" ] || NOTEBOOK_DIR="${SLURM_SUBMIT_DIR:-$HOME}"

echo
echo "SSH tunnel from YOUR LAPTOP:"
echo "  ssh -N -L $ipnport:$ipnip:$ipnport $user_name@$login_host"
echo
echo "Then open in your browser:"
echo "  http://localhost:$ipnport"
echo

# Launch JupyterLab (fallback to Notebook)
jupyter-lab --no-browser --port=$ipnport --ip=$ipnip --notebook-dir="$NOTEBOOK_DIR" \
  || jupyter-notebook --no-browser --port=$ipnport --ip=$ipnip --notebook-dir="$NOTEBOOK_DIR"
