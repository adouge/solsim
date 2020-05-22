#!/bin/sh
#########################################################################
#    Copyright 2020 Anton Douginets                                                        
#    This file is part of solensim.
#
#    solensim is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    solensim is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with solensim.  If not, see <https://www.gnu.org/licenses/>.
#########################################################################

# tweak the matlab python interface installer into accepting python 3.8

OPTIND=1
MATLABROOT="."
action=0

while getopts ":hur:" opt; do
    case "$opt" in
    h)
        echo "Tweak MATLAB Python interface to allow installing into a Python 3.8 distribution."
        echo "Usage:"
        echo "  tweak -r path/to/MATLAB/root"
        echo "    defaults to current directory, if no -r option specified."
        echo "  Use -ur to undo changes."
        echo "  Run matlab -nodesktop -nosplash -nojvm -batch matlabroot to obtain matlab root directory."
        echo "  !!Make sure to have write permissions!"
        exit 0
        ;;
    u)  action=1
        ;;
    r)  MATLABROOT=$OPTARG
        ;;
    esac
done

echo "Assuming MATLAB root directory is $MATLABROOT."
INSTALLER_PATH="$MATLABROOT/extern/engines/python"
echo "Installer path is thus: $INSTALLER_PATH"

if [ $action -eq 1 ]
then
  echo "Undoing tweaks..."

  cd $INSTALLER_PATH
  cp setup.py.bak setup.py

  cd build/lib/matlab/engine
  cp __init__.py.bak __init__.py
  cd $INSTALLER_PATH

  cd dist/matlab/engine
  cp __init__.py.bak __init__.py

  echo "done. The installer should be in its original state now."
  exit 0
fi

if [ $action -eq 0 ]
then
  cd $INSTALLER_PATH
  sed -i.bak s/"'2.7', '3.6', '3.7'"/"'2.7', '3.6', '3.7', '3.8'"/g setup.py
  python setup.py build

  cd build/lib/matlab/engine
  sed -i.bak s/"'2_7', '3_6', '3_7'"/"'2_7', '3_6', '3_7', '3_8'"/g __init__.py
  sed -i s/"_PYTHONVERSION = _version"/"_PYTHONVERSION = '3_7'"/g __init__.py

  cd $INSTALLER_PATH
  cd dist/matlab/engine
  sed -i.bak s/"'2_7', '3_6', '3_7'"/"'2_7', '3_6', '3_7', '3_8'"/g __init__.py
  sed -i s/"_PYTHONVERSION = _version"/"_PYTHONVERSION = '3_7'"/g __init__.py

  echo "done. Run sh tweak.sh -u after installing (setup.py install) to revert the installer to its original state."
  exit 0
fi
