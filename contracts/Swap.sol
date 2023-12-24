// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
pragma abicoder v2;

import "../node_modules/@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../node_modules/@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract Uniswap3 {
    IUniswapRouter public constant uniswapRouter =
        IUniswapRouter(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
    IQuoter public constant quoter =
        IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    address private constant multiDaiKovan =
        0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    address private constant WETH9 = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;

    function convertExactEthToDai() external payable {
        require(msg.value > 0, "Must pass non 0 ETH amount");

        uint256 deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        address tokenIn = WETH9;
        address tokenOut = multiDaiKovan;
        uint24 fee = 3000;
        address recipient = msg.sender;
        uint256 amountIn = msg.value;
        uint256 amountOutMinimum = 1;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams(
                tokenIn,
                tokenOut,
                fee,
                recipient,
                deadline,
                amountIn,
                amountOutMinimum,
                sqrtPriceLimitX96
            );

        uniswapRouter.exactInputSingle{value: msg.value}(params);
        uniswapRouter.refundETH();

        // refund leftover ETH to user
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "refund failed");
    }

    function convertEthToExactDai(uint256 daiAmount) external payable {
        require(daiAmount > 0, "Must pass non 0 DAI amount");
        require(msg.value > 0, "Must pass non 0 ETH amount");

        uint256 deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        address tokenIn = WETH9;
        address tokenOut = multiDaiKovan;
        uint24 fee = 3000;
        address recipient = msg.sender;
        uint256 amountOut = daiAmount;
        uint256 amountInMaximum = msg.value;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams(
                tokenIn,
                tokenOut,
                fee,
                recipient,
                deadline,
                amountOut,
                amountInMaximum,
                sqrtPriceLimitX96
            );

        uniswapRouter.exactOutputSingle{value: msg.value}(params);
        uniswapRouter.refundETH();

        // refund leftover ETH to user
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "refund failed");
    }

    // do not used on-chain, gas inefficient!
    function getEstimatedETHforDAI(
        uint daiAmount
    ) external payable returns (uint256) {
        address tokenIn = WETH9;
        address tokenOut = multiDaiKovan;
        uint24 fee = 3000;
        uint160 sqrtPriceLimitX96 = 0;

        return
            quoter.quoteExactOutputSingle(
                tokenIn,
                tokenOut,
                fee,
                daiAmount,
                sqrtPriceLimitX96
            );
    }

    // important to receive ETH
    receive() external payable {}
}
