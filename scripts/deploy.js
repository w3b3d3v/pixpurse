// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat")

async function main() {
  const [deployer] = await hre.ethers.getSigners()
  const networks = {
    polygon: {
      usdc: "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
      usdt: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
    },
  }

  console.log("Deploying contracts with the account:", deployer.address)

  if (networks[hre.network.name] === undefined) {
    const mockUSDC = await hre.ethers.deployContract("MockUSDC")
    await mockUSDC.waitForDeployment()
    console.log("MockUSDC deployed to:", mockUSDC.target)
    const mockUSDT = await hre.ethers.deployContract("MockUSDT")
    await mockUSDT.waitForDeployment()
    console.log("MockUSDT deployed to:", mockUSDT.target)

    networks[hre.network.name] = { usdc: mockUSDC.target, usdt: mockUSDT.target }
  }

  const PixPurse = await hre.ethers.getContractFactory("PixPurse")
  const pixPurse = await PixPurse.deploy()
  await pixPurse.waitForDeployment()

  await pixPurse["mint(address,address)"](
    networks[hre.network.name].usdc,
    "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f"
  )
  await pixPurse["mint(address)"](networks[hre.network.name].usdc)
  await pixPurse.mint()

  console.log(await pixPurse.tokenURI(1))
  console.log(await pixPurse.tokenURI(2))
  console.log(await pixPurse.tokenURI(3))

  console.log("PixPurse deployed to:", pixPurse.target)
}

function extractSVG(tokenURI) {
  // Decode the base64 encoded JSON
  const decodedJson = Buffer.from(tokenURI.split(",")[1], "base64").toString()

  // Parse the JSON data
  const jsonData = JSON.parse(decodedJson)

  // Extract and decode the base64 encoded SVG image string
  const svgData = Buffer.from(jsonData.image.split(",")[1], "base64").toString()

  return svgData
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
