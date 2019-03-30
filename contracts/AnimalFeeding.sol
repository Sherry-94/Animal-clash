/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
 
pragma solidity ^0.4.25;

import "./AnimalFactory.sol";

/**
 * @title Crypto Kitties Contract Interface 
 * @notice this interface only uses getKitty function to return genes of a kitty
 */
contract CryptoKittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

/**
 * @title AnimalFeeding 
 * @notice handles the feeding logic for Animals
 */
contract AnimalFeeding is AnimalFactory {

    CryptoKittyInterface cryptoKitty;

    modifier isAnimalOwner(uint _animalId) {
        require(msg.sender == animalToOwner[_animalId]);
        _;
    }

    function setCryptoKittyAddress(address _address) external onlyOwner {
        cryptoKitty = CryptoKittyInterface(_address);
    }

    function _triggerCooldown(Animal storage _animal) internal {
        _animal.readyTime = uint32(now + cooldownTime);
    }

    function _isReady(Animal storage _animal) internal view returns (bool) {
        return (_animal.readyTime <= now);
    }

    /**
    * @title AnimalFeeding 
    * @dev main function to handle feeding logic
    * @param _animalId, attacker animal
    * @param _targetDna, target animal/kitty
    * @param _species, identifier, either animal or crypto kitty
    */
    function feedAndMultiply(uint _animalId, uint _targetDna, string _species) 
        internal
        isAnimalOwner(_animalId)
        {
            Animal storage myAnimal = animals[_animalId];
            require(_isReady(myAnimal));
            _targetDna = _targetDna % dnaModulus;
            uint newDna = (myAnimal.dna + _targetDna) / 2;
            if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
            }
            _createAnimal("NoName", newDna);
            _triggerCooldown(myAnimal);
        }

    /**
    * @title AnimalFeeding 
    * @dev main function to handle feeding on Crypto kitty
    * @param _animalId, attacker animal
    * @param _kittyId, target kitty 
    */
    function feedOnKitty(uint _animalId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = cryptoKitty.getKitty(_kittyId);
        feedAndMultiply(_animalId, kittyDna, "kitty");
    }
}
