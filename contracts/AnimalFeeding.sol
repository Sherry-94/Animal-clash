/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
 
pragma solidity ^0.4.25;

import "./AnimalFactory.sol";

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

    function feedOnKitty(uint _animalId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = cryptoKitty.getKitty(_kittyId);
        feedAndMultiply(_animalId, kittyDna, "kitty");
    }
}
