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

# Pull Astra executables
# Run get_astra path/to/solensim/root
# If none specified, the current directory is used.

if [ -z $1 ]
then
  target="./plugins/astra/workspace"
else
  target=$1/plugins/astra/workspace
fi

echo "Putting Astra into "$target
echo "=================="

cd $target

wget https://www.desy.de/~mpyflo/Astra_for_64_Bit_Linux/Astra
wget https://www.desy.de/~mpyflo/Astra_for_64_Bit_Linux/generator
chmod +x Astra
chmod +x generator

echo "================="
echo "Done."
