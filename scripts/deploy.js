const { ethers } = require("hardhat");

async function main() {
  const Uniswap3 = await ethers.getContractFactory("Uniswap3");
  const uniswap3 = await Uniswap3.deploy();

  console.log("Uniswap3 deployed to:", uniswap3.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
