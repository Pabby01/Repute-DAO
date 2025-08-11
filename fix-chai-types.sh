#!/bin/bash

# Check if node_modules/@types/chai exists
if [ -d "node_modules/@types/chai" ]; then
  echo "Chai types are installed in the main project"
else
  echo "Chai types are missing in the main project"
  echo "Installing chai types..."
  npm install --save-dev @types/chai@^4.3.5
fi

# Check if repute_dao_program/node_modules/@types/chai exists
if [ -d "repute_dao_program/node_modules/@types/chai" ]; then
  echo "Chai types are installed in the repute_dao_program"
else
  echo "Chai types are missing in the repute_dao_program"
  echo "Installing chai types in repute_dao_program..."
  cd repute_dao_program
  npm install --save-dev @types/chai@^4.3.5
  cd ..
fi

echo "Done checking and installing chai types"