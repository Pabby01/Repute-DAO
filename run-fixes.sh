#!/bin/bash

# Make the fix script executable
chmod +x fix-remaining-issues.sh

# Run the fix script
./fix-remaining-issues.sh

# Build the program
echo "Building the program..."
anchor build