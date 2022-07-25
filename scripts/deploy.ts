import hardhat, { ethers, waffle } from "hardhat";

async function main() {

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy("Token", "TKN");
  await token.deployed();

  console.log("Token deployed to:", token.address);

  console.log("Waiting for 10 confirmations")
  await token.deployTransaction.wait(10)
  console.log("Confirmed!")

  console.log("Verifying...")
  await hardhat.run("verify:verify", {
    address: token.address,
    constructorArguments: ["Token", "TKN"],
  })
  console.log("VERIFICATION COMPLETE")
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});