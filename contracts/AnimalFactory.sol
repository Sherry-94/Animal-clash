/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */

pragma solidity ^0.4.25;

import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title AnimalFactory
 * @dev Factory contract for creating and holding all fighters
 */
contract AnimalFactory is Ownable {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewBijou(uint animalId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    struct Animal {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    Animal[] public animals;

    mapping (uint => address) public animalToOwner;
    mapping (address => uint) ownerAnimalCount;

    /**
    * @title _createAnimal
    * @param _name The name of the animal
    * @param _dna Respective dna of the animal
    */
    function _createAnimal(string memory _name, uint _dna) internal {
        uint id = animals.push(Animal(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        animalToOwner[id] = msg.sender;
        ownerAnimalCount[msg.sender] = ownerAnimalCount[msg.sender].add(1);
        emit NewBijou(id, _name, _dna);
    }

    /**
    * @title _generateRandomDna
    * @notice This function generates random 16 digit number 
    * @param _str Some string to create random number
    */
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    /**
    * @title createRandomZombie
    * @notice This function is called by the user directly to create a random bijou
    * @param _name The name of the animal
    */
    function createRandomZombie(string memory _name) public {
        require(ownerAnimalCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createAnimal(_name, randDna);
    }

}
