// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {Base64} from "./Base64.sol";

interface IExtendedERC20 is IERC20 {
    function decimals() external view returns (uint8);
}

contract PixPurse is ERC721Enumerable {
    address public defaultToken = address(0); // Represents ETH
    mapping(uint256 => address) public chosenToken;

    string public SVG1 =
        '<svg width="200" height="100" xmlns="http://www.w3.org/2000/svg"><rect width="200" height="100" fill="#f1f1f1" rx="15" ry="15"/><text x="10" y="50" font-family="Arial" font-size="14" fill="black">Balance: ';
    string public SVG2 = "</text></svg>";

    constructor() ERC721("PixPurse", "PPNFT") {}

    function mint() public {
        mint(defaultToken);
    }

    function mint(address tokenAddress) public {
        mint(tokenAddress, msg.sender);
    }

    function mint(address tokenAddress, address holder) public {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(holder, tokenId);
        chosenToken[tokenId] = tokenAddress;
    }

    function setChosenToken(uint256 tokenId, address tokenAddress) external {
        // Ensure the caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "Not the owner of this NFT");

        // Set the chosen token for this NFT
        chosenToken[tokenId] = tokenAddress;
    }

    function getBalance(uint256 tokenId) public view returns (string memory) {
        address tokenAddress = chosenToken[tokenId];
        address owner = ownerOf(tokenId);
        if (tokenAddress == defaultToken) {
            return formatBalance(owner.balance, 18);
        } else {
            IExtendedERC20 token = IExtendedERC20(tokenAddress);
            uint8 decimals = token.decimals();
            return formatBalance(token.balanceOf(owner), decimals);
        }
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

    function getTokenSymbol(
        address tokenAddress
    ) public view returns (string memory) {
        IERC20Metadata token = IERC20Metadata(tokenAddress);
        return token.symbol();
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        // Get the balance and symbol of the NFT owner's chosen token
        string memory balance = getBalance(tokenId);
        string memory symbol;
        address chosenTokenAddress = chosenToken[tokenId];
        if (chosenTokenAddress == address(0)) {
            symbol = "ETH";
        } else {
            symbol = getTokenSymbol(chosenTokenAddress);
        }

        // SVG content
        string memory svg = string(
            abi.encodePacked(
                '<svg width="200" height="150" xmlns="http://www.w3.org/2000/svg">',
                '<rect x="10" y="10" width="180" height="130" rx="20" ry="20" fill="#8B4513" />',
                '<rect x="20" y="20" width="160" height="110" rx="15" ry="15" fill="#A0522D" />',
                '<rect x="30" y="40" width="140" height="30" rx="5" ry="5" fill="#D2B48C" />',
                '<circle cx="170" cy="75" r="5" fill="#8B4513" />',
                '<text x="40" y="60" font-family="Arial" font-size="14" fill="black">',
                symbol,": ",
                balance,
                "</text>",
                "</svg>"
            )
        );

        // Metadata
        string memory metadata = string(
            abi.encodePacked(
                '{"name": "PixPurse Wallet #',
                Strings.toString(tokenId),
                '",',
                '"attributes": [ { "trait_type": "color", "value": "red" }],',
                '"description": "bla bla bla",',
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(svg)),
                '"}'
            )
        );
        string memory json = Base64.encode(bytes(metadata));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
