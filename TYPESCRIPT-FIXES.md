# Fixing TypeScript Configuration Issues

If you're encountering TypeScript errors related to missing type definitions for 'chai' or other libraries, follow these steps to resolve them:

## Step 1: Install Dependencies

Make sure all dependencies are properly installed:

```bash
# In the root directory
npm install

# In the repute_dao_program directory
cd repute_dao_program
npm install
cd ..
```

## Step 2: Run the Fix Script

We've provided a script to check and install the chai types:

```bash
# Make the script executable
chmod +x fix-chai-types.sh

# Run the script
./fix-chai-types.sh
```

## Step 3: Restart Your IDE/Editor

Sometimes, your IDE or editor needs to be restarted to recognize the newly installed type definitions.

## Step 4: Manual Installation (if needed)

If you're still encountering issues, try manually installing the chai types:

```bash
# In the root directory
npm install --save-dev @types/chai@^4.3.5

# In the repute_dao_program directory
cd repute_dao_program
npm install --save-dev @types/chai@^4.3.5
cd ..
```

## Step 5: Check TypeScript Configuration

Ensure your tsconfig.json files are correctly configured:

1. Root tsconfig.json should include:
   - "skipLibCheck": true
   - "types": ["mocha", "chai", "node"]

2. repute_dao_program/tsconfig.json should include:
   - "skipLibCheck": true
   - "typeRoots" pointing to both local and parent node_modules
   - "types": ["mocha", "chai", "node"]

## Common Issues and Solutions

1. **Missing Type Definitions**: Make sure @types/chai is installed in both the root and program directories.

2. **Version Mismatch**: Ensure the version of chai and @types/chai are compatible.

3. **Path Issues**: TypeScript might not be finding the type definitions. Check the "typeRoots" setting in tsconfig.json.

4. **Cache Issues**: Try clearing the TypeScript server cache in your IDE.

If you continue to experience issues, please open an issue on the repository.