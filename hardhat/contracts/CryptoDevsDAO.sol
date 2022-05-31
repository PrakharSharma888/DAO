// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {
    
    function purchase(uint256 _tokenId) payable external;
    function getPrice() external view returns(uint256);
    function available(uint256 _tokenId) external view returns(bool);
}

interface ICryptoDevs {
    function balanceOf(address owner) external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);
}

contract CryptoDevs is Ownable{
    struct Proposal{
        uint256 nftTokenId;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;

        mapping (uint256 => bool) voters;
    }

    enum Vote{
        Yes,
        No
    }

    mapping (uint256 => Proposal) public proposals;
    uint256 public numProposals;

    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevs cryptoDevsNFT;

    constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
        nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
        cryptoDevsNFT = ICryptoDevs(_cryptoDevsNFT);
    }

    modifier nftHolderOnly(){
        require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "You are not a DAO member!");
        _;
    }

    modifier activeProposalOnly(uint256 proposalIndex){
        require(proposals[proposalIndex].deadline > block.timestamp, "Deadline Exceeded!!");
        _;
    }

    modifier inactiveProposalOnly(uint256 proposalIndex){
        require(proposals[proposalIndex].deadline <= block.timestamp, "Deadline has not yet ended");
        require(proposals[proposalIndex].executed == false, "This proposal has already been executed");
        _;
    }

    function createProposal(uint256 _nftTokenId) external nftHolderOnly returns(uint){
        require(nftMarketplace.available(_nftTokenId),"This NFT is not for sale :( ");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals ++;

        return numProposals - 1;
    }

    function voteOnProposals(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex){
        
        Proposal storage proposal = proposals[proposalIndex];
        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint numVotes = 0;

        for(uint i=0; i<voterNFTBalance; i++){
            uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if(proposal.voters[tokenId] == false){
                numVotes++;
                proposal.voters[tokenId] == true;
            }
        }
        require(numVotes > 0, "You have already voted for this proposal");

        if(vote == Vote.Yes){
            proposal.yesVotes += numVotes;
        }
        else{
            proposal.noVotes += numVotes;
        }
    }

    function executeProposal(uint proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex){
        Proposal storage proposal = proposals[proposalIndex];

        if(proposal.yesVotes > proposal.noVotes){
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "Not enough funds!");
            nftMarketplace.purchase{value : nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}
