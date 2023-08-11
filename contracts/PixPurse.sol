// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Base64} from "./Base64.sol";

contract PixPurse is ERC721Enumerable {
    IERC20 public usdc;
    IERC20 public usdt;

    string public SVG1 =
        "<svg width='200' height='100' xmlns='http://www.w3.org/2000/svg'><rect width='200' height='100' fill='#f1f1f1' rx='15' ry='15'/><text x='10' y='25' font-family='Arial' font-size='14' fill='black'>ETH: ";
    string public SVG2 =
        "</text><text x='10' y='50' font-family='Arial' font-size='14' fill='black'>USDC: ";
    string public SVG3 =
        "</text><text x='10' y='75' font-family='Arial' font-size='14' fill='black'>USDT: ";
    string public SVG4 = "</text></svg>";

    constructor(address _usdc, address _usdt) ERC721("PixPurse", "PPNFT") {
        usdc = IERC20(_usdc);
        usdt = IERC20(_usdt);
    }

    // Mint a new NFT for the caller
    function mint() public {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
    }

    function mint(address holder) public {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(holder, tokenId);
    }


    // Get the native Ether balance of the NFT owner
    function getEtherBalance(
        address owner
    ) public view returns (string memory) {
        return formatBalance(owner.balance, 18);
    }

    function getUSDCBalance(address owner) public view returns (string memory) {
        return formatBalance(usdc.balanceOf(owner), 18);
    }

    function getUSDTBalance(address owner) public view returns (string memory) {
        return formatBalance(usdt.balanceOf(owner), 18);
    }

    function formatBalance(
        uint256 balance,
        uint8 decimals
    ) internal pure returns (string memory) {
        uint256 factor = 10 ** decimals;
        uint256 wholePart = balance / factor;
        uint256 decimalPart = ((balance % factor) * 100) / factor;

        return
            string(
                abi.encodePacked(
                    uintToString(wholePart),
                    ".",
                    uintToString(decimalPart)
                )
            );
    }

    // Helper function to convert uint to string
    function uintToString(uint256 v) internal pure returns (string memory str) {
        if (v == 0) {
            return "0";
        }
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        string memory finalSvg = string(
            abi.encodePacked(
                SVG1,
                getEtherBalance(ownerOf(tokenId)),
                SVG2,
                getUSDCBalance(ownerOf(tokenId)),
                SVG3,
                getUSDTBalance(ownerOf(tokenId)),
                SVG4
            )
        );

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "PixPurse Wallet #',
                Strings.toString(tokenId),
                '",',
                '"attributes": [ { "trait_type": "color", "value": "red" }],',
                '"description": "bla bla bla",',
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '"}'
            )
        );
        string memory json = Base64.encode(bytes(metadata));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
