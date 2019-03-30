pragma solidity ^0.4.25;

import "./AnimalFeeding.sol";

contract AnimalConfiguration is AnimalFeeding {

  uint levelUpFee = 0.05 ether;

  modifier aboveLevel(uint _level, uint _animalId) {
    require(animals[_animalId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
      owner.transfer(address(this).balance);
  }

  function setLevelFee(uint _fee) external onlyOwner {
      levelUpFee = _fee;
  }

  function levelUp(uint _animalId) external payable {
    require(msg.value == levelUpFee);
    animals[_animalId].level = animals[_animalId].level.add(1);
  }

  function changeName(uint _animalId, string _newName) external aboveLevel(5, _animalId) isAnimalOwner(_animalId) {
    animals[_animalId].name = _newName;
  }

  function changeDna(uint _animalId, uint _newDna) external aboveLevel(45, _animalId) isAnimalOwner(_animalId) {
    animals[_animalId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerAnimalCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < animals.length; i++) {
      if (animalToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}