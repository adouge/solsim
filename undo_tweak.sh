# undo the tweak the matlab python interface installer into accepting python 3.8
MATLABROOT="/home/anton/pfiles/MATLAB"
echo "Assuming MATLABROOT to be $MATLABROOT."
echo "run matlab -nodesktop -nosplash -nojvm -batch matlabroot to obtain matlab root directory."
# run matlab -nodesktop -nosplash -nojvm -batch matlabroot to obtain matlab root directory.
INSTALLER_PATH="$MATLABROOT/extern/engines/python"

cd $INSTALLER_PATH
cp setup.py.bak setup.py

cd build/lib/matlab/engine
cp __init__.py.bak __init__.py
cd $INSTALLER_PATH

cd dist/matlab/engine
cp __init__.py.bak __init__.py

echo "done. The installer should be in its original state now."