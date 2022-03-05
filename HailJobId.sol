// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";


// * Request testnet LINK and ETH here: https://faucets.chain.link/
// * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/

contract Weather is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    
    bytes32 public hailJobId;
    uint256 public hail;
    uint256 public fee;
    
    event Hail(uint256 _result);
    
    constructor(
        address _link,
        address _oracle,
        bytes32 _hailJobId,
        uint256 _fee
    ) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        hailJobId = _hailJobId;
        fee = _fee;
    }
    
    function requestHail(
        string memory _from,
        string memory _to
    ) external {
        Chainlink.Request memory req = buildChainlinkRequest(
            hailJobId,
            address(this),
            this.fulfillHail.selector
        );
        req.add("dateFrom", _from);
        req.add("dateTo", _to);
        req.add("method", "SUM");
        req.add("column", "hail");
        sendChainlinkRequest(req, fee);
    }
    
    function fulfillHail(
        bytes32 _requestId,
        uint256 _result
    ) external recordChainlinkFulfillment(_requestId) {
        hail = _result;
        emit Hail(_result);
    }
}
