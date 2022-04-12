cd ~/projects/def-zaiane/taghianj
module load python/3.8.10
virtualenv env
source env/bin/activate
module load cuda/11.4
pip3 install --no-index torch torchvision torchaudio
pip3 install --no-index -r Compute-Canada/requirements.txt
wget https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz
tar -xvf mujoco210-linux-x86_64.tar.gz
mv mujoco210 ~/.mujoco/
echo  'LD_LIBRARY_PATH=/home/taghianj/.mujoco/mujoco210/bin:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PYTHONPATH=/home/taghianj/scratch/SAC_GCN:$PYTHONPATH' >> ~/.bashrc
echo 'source ~/projects/def-zaiane/taghianj/env/bin/activate'
pip3 install -U 'mujoco-py<2.2,>=2.1'

