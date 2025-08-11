#!/bin/bash

# Create necessary directories
mkdir -p repute_dao_program/target/idl
mkdir -p repute_dao_program/target/types

# Check if the program has been built
if [ ! -f "repute_dao_program/target/idl/repute_dao.json" ]; then
  echo "IDL file not found. Creating placeholder..."
  
  # Create a placeholder IDL file
  cat > repute_dao_program/target/idl/repute_dao.json << 'EOL'
{
  "version": "0.1.0",
  "name": "repute_dao",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [
        {
          "name": "programState",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "tokenMint",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "cooldownPeriod",
          "type": "u64"
        },
        {
          "name": "decayRate",
          "type": "u8"
        },
        {
          "name": "decayPeriod",
          "type": "u64"
        },
        {
          "name": "votePowerMultiplier",
          "type": "u8"
        }
      ]
    },
    {
      "name": "upvote",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voteRecord",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "voterTokenAccount",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "target",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "downvote",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voteRecord",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "voterTokenAccount",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "target",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "resetScores",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": []
    },
    {
      "name": "configureRole",
      "accounts": [
        {
          "name": "programState",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "role",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "name",
          "type": "string"
        },
        {
          "name": "threshold",
          "type": "i64"
        },
        {
          "name": "index",
          "type": "u8"
        }
      ]
    },
    {
      "name": "getUserRole",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "user",
          "type": "publicKey"
        }
      ],
      "returns": "string"
    }
  ],
  "accounts": [
    {
      "name": "programState",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "publicKey"
          },
          {
            "name": "tokenMint",
            "type": "publicKey"
          },
          {
            "name": "cooldownPeriod",
            "type": "u64"
          },
          {
            "name": "roleCount",
            "type": "u8"
          },
          {
            "name": "decayEnabled",
            "type": "bool"
          },
          {
            "name": "decayRate",
            "type": "u8"
          },
          {
            "name": "decayPeriod",
            "type": "u64"
          },
          {
            "name": "lastDecayTime",
            "type": "i64"
          },
          {
            "name": "votePowerMultiplier",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "userScore",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "user",
            "type": "publicKey"
          },
          {
            "name": "score",
            "type": "i64"
          },
          {
            "name": "lastUpdated",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "voteRecord",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "voter",
            "type": "publicKey"
          },
          {
            "name": "target",
            "type": "publicKey"
          },
          {
            "name": "lastVoteTime",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "role",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "threshold",
            "type": "i64"
          },
          {
            "name": "index",
            "type": "u8"
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "Unauthorized",
      "msg": "User is not authorized to perform this action"
    },
    {
      "code": 6001,
      "name": "CooldownActive",
      "msg": "User must wait before voting again"
    },
    {
      "code": 6002,
      "name": "NoTokens",
      "msg": "User doesn't hold the required tokens to vote"
    },
    {
      "code": 6003,
      "name": "InvalidInput",
      "msg": "Invalid parameters provided"
    },
    {
      "code": 6004,
      "name": "DecayNotDue",
      "msg": "Decay period has not elapsed yet"
    }
  ]
}
EOL
fi

if [ ! -f "repute_dao_program/target/types/repute_dao.ts" ]; then
  echo "Type definition file not found. Creating placeholder..."
  
  # Create a placeholder type definition file
  cat > repute_dao_program/target/types/repute_dao.ts << 'EOL'
export type ReputeDao = {
  "version": "0.1.0",
  "name": "repute_dao",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [
        {
          "name": "programState",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "tokenMint",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "cooldownPeriod",
          "type": "u64"
        },
        {
          "name": "decayRate",
          "type": "u8"
        },
        {
          "name": "decayPeriod",
          "type": "u64"
        },
        {
          "name": "votePowerMultiplier",
          "type": "u8"
        }
      ]
    },
    {
      "name": "upvote",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voteRecord",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "voterTokenAccount",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "target",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "downvote",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voteRecord",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "voterTokenAccount",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "target",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "resetScores",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": []
    },
    {
      "name": "configureRole",
      "accounts": [
        {
          "name": "programState",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "role",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "name",
          "type": "string"
        },
        {
          "name": "threshold",
          "type": "i64"
        },
        {
          "name": "index",
          "type": "u8"
        }
      ]
    },
    {
      "name": "getUserRole",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "user",
          "type": "publicKey"
        }
      ],
      "returns": "string"
    }
  ],
  "accounts": [
    {
      "name": "programState",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "publicKey"
          },
          {
            "name": "tokenMint",
            "type": "publicKey"
          },
          {
            "name": "cooldownPeriod",
            "type": "u64"
          },
          {
            "name": "roleCount",
            "type": "u8"
          },
          {
            "name": "decayEnabled",
            "type": "bool"
          },
          {
            "name": "decayRate",
            "type": "u8"
          },
          {
            "name": "decayPeriod",
            "type": "u64"
          },
          {
            "name": "lastDecayTime",
            "type": "i64"
          },
          {
            "name": "votePowerMultiplier",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "userScore",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "user",
            "type": "publicKey"
          },
          {
            "name": "score",
            "type": "i64"
          },
          {
            "name": "lastUpdated",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "voteRecord",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "voter",
            "type": "publicKey"
          },
          {
            "name": "target",
            "type": "publicKey"
          },
          {
            "name": "lastVoteTime",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "role",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "threshold",
            "type": "i64"
          },
          {
            "name": "index",
            "type": "u8"
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "Unauthorized",
      "msg": "User is not authorized to perform this action"
    },
    {
      "code": 6001,
      "name": "CooldownActive",
      "msg": "User must wait before voting again"
    },
    {
      "code": 6002,
      "name": "NoTokens",
      "msg": "User doesn't hold the required tokens to vote"
    },
    {
      "code": 6003,
      "name": "InvalidInput",
      "msg": "Invalid parameters provided"
    },
    {
      "code": 6004,
      "name": "DecayNotDue",
      "msg": "Decay period has not elapsed yet"
    }
  ]
};

export const IDL: ReputeDao = {
  "version": "0.1.0",
  "name": "repute_dao",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [
        {
          "name": "programState",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "tokenMint",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "cooldownPeriod",
          "type": "u64"
        },
        {
          "name": "decayRate",
          "type": "u8"
        },
        {
          "name": "decayPeriod",
          "type": "u64"
        },
        {
          "name": "votePowerMultiplier",
          "type": "u8"
        }
      ]
    },
    {
      "name": "upvote",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voteRecord",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "voterTokenAccount",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "target",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "downvote",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voteRecord",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "voter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "voterTokenAccount",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "target",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "resetScores",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": []
    },
    {
      "name": "configureRole",
      "accounts": [
        {
          "name": "programState",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "role",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "name",
          "type": "string"
        },
        {
          "name": "threshold",
          "type": "i64"
        },
        {
          "name": "index",
          "type": "u8"
        }
      ]
    },
    {
      "name": "getUserRole",
      "accounts": [
        {
          "name": "programState",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "userScore",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "user",
          "type": "publicKey"
        }
      ],
      "returns": "string"
    }
  ],
  "accounts": [
    {
      "name": "programState",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "publicKey"
          },
          {
            "name": "tokenMint",
            "type": "publicKey"
          },
          {
            "name": "cooldownPeriod",
            "type": "u64"
          },
          {
            "name": "roleCount",
            "type": "u8"
          },
          {
            "name": "decayEnabled",
            "type": "bool"
          },
          {
            "name": "decayRate",
            "type": "u8"
          },
          {
            "name": "decayPeriod",
            "type": "u64"
          },
          {
            "name": "lastDecayTime",
            "type": "i64"
          },
          {
            "name": "votePowerMultiplier",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "userScore",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "user",
            "type": "publicKey"
          },
          {
            "name": "score",
            "type": "i64"
          },
          {
            "name": "lastUpdated",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "voteRecord",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "voter",
            "type": "publicKey"
          },
          {
            "name": "target",
            "type": "publicKey"
          },
          {
            "name": "lastVoteTime",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "role",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "threshold",
            "type": "i64"
          },
          {
            "name": "index",
            "type": "u8"
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "Unauthorized",
      "msg": "User is not authorized to perform this action"
    },
    {
      "code": 6001,
      "name": "CooldownActive",
      "msg": "User must wait before voting again"
    },
    {
      "code": 6002,
      "name": "NoTokens",
      "msg": "User doesn't hold the required tokens to vote"
    },
    {
      "code": 6003,
      "name": "InvalidInput",
      "msg": "Invalid parameters provided"
    },
    {
      "code": 6004,
      "name": "DecayNotDue",
      "msg": "Decay period has not elapsed yet"
    }
  ]
};
EOL
fi

# Fix getUserRole in rpc.ts
echo "Fixing getUserRole in rpc.ts..."
sed -i 's/feePayer: args.feePayer,/programState: programStatePubkey,\n      userScore: userScorePubkey,/g' repute_dao_program/app/program_client/rpc.ts

# Install dependencies
echo "Installing dependencies..."
npm install --save-dev @types/chai@^4.3.5 @types/mocha@^9.0.0 @types/node@^20.4.5

echo "All TypeScript issues fixed!"