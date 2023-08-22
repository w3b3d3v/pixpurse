// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Base64} from "./Base64.sol";

interface IExtendedERC20 is IERC20 {
    function decimals() external view returns (uint8);
}

contract PixPurse is ERC721Enumerable {
    address public defaultToken = address(0); // Represents ETH
    mapping(address => address) public chosenToken;

    string public SVG1 =
        '<svg width="200" height="100" xmlns="http://www.w3.org/2000/svg"><rect width="200" height="100" fill="#f1f1f1" rx="15" ry="15"/><text x="10" y="50" font-family="Arial" font-size="14" fill="black">Balance: ';
    string public SVG2 = "</text></svg>";

    constructor() ERC721("PixPurse", "PPNFT") {}

    function mint() public {
        mint(msg.sender, defaultToken);
    }

    function mint(address holder) public {
        mint(holder, defaultToken);
    }

    function mint(address holder, address tokenAddress) public {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(holder, tokenId);
        chosenToken[holder] = tokenAddress;
    }

    function setChosenToken(uint256 tokenId, address tokenAddress) external {
        // Ensure the caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "Not the owner of this NFT");

        // Set the chosen token for this NFT
        chosenToken[msg.sender] = tokenAddress;
    }

    function getBalance(address owner) public view returns (string memory) {
        address tokenAddress = chosenToken[owner];
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

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        string memory balance = getBalance(ownerOf(tokenId));
        string memory finalSvg = string(
            abi.encodePacked(
                SVG1,
                balance,
                SVG2
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
