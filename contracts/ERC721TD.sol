pragma solidity ^0.6.0;
import "./IExerciceSolution.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract ExerciceSolution is ERC721
{

	struct Animal {
		uint256 id;
		string name;
		bool wings;
		uint legs; 
		uint sex;
		bool isForSale;
		uint256 price;
	}

	uint256 private _tokenNumber;
	mapping(uint256 => Animal) public _tokens;
	mapping(address => bool) public _breeder;
	uint256 private _priceBreeder;
	address private _owner;


	constructor(string memory _name, string memory _symbol) public ERC721(_name, _symbol){
		_tokenNumber = 0;
		_priceBreeder = 0.01 ether;
		_owner = msg.sender;
		_breeder[_owner] = true;
	}


	// Breeding function

	function isBreeder(address account) external view returns (bool){
		return _breeder[account];
	}

	function registrationPrice() external view returns (uint256){
		return _priceBreeder;
	}

	function registerMeAsBreeder() external payable{

		require(msg.value == _priceBreeder);
		_breeder[msg.sender] = true;

	}

	function declareAnimal(uint sex, uint legs, bool wings, string calldata name) 
	external 
	returns (uint256)
	{
		_tokenNumber++;
		_mint(msg.sender, _tokenNumber);
		Animal memory newAnimal = Animal(_tokenNumber, name, wings, legs, sex, false, 0);
		_tokens[_tokenNumber] = newAnimal;
		return _tokenNumber;
	}	
	
	function getAnimalCharacteristics(uint animalNumber) 
	external 
	view 
	returns (string memory _name, bool _wings, uint _legs, uint _sex)
	{
		require(animalNumber <= _tokenNumber, "Id not found");
		require(animalNumber > 0, "Id not found");
		Animal memory animal = _tokens[animalNumber];
		return (animal.name, animal.wings, animal.legs, animal.sex);
	}

	modifier onlyAnimalOwner(uint256 RefToken) 
	{
	    require(ownerOf(RefToken) == msg.sender);
		_;
	}

	function declareDeadAnimal(uint animalNumber) 
	external
	onlyAnimalOwner(animalNumber)
	{
		_burn(animalNumber);
		delete _tokens[animalNumber];
	}


// Selling functions

	function isAnimalForSale(uint animalNumber) 
	external 
	view 
	returns (bool)
	{
		return _tokens[animalNumber].isForSale;
	}

	function animalPrice(uint animalNumber) 
	external 
	view 
	returns (uint256)
	{
		return _tokens[animalNumber].price;
	}

	function buyAnimal(uint animalNumber) 
	external
	payable
	{
		Animal memory animal = _tokens[animalNumber];

		require(animal.isForSale, "Animal is not for sale");
		require(msg.value == animal.price);

		address animalOwner = ownerOf(animalNumber);

		//give eth to current owner
		(bool sent, bytes memory data) = animalOwner.call{value: msg.value}("");
		require(sent, "Failed to transfer Ether");

		//transfer token to new owner
		_transfer(animalOwner, msg.sender, animalNumber);

		//reset sale
		delete animal.isForSale;
	}

	function offerForSale(uint animalNumber, uint price) 
	external
	onlyAnimalOwner(animalNumber)
	{
		_tokens[animalNumber].isForSale = true;
		_tokens[animalNumber].price = price;
	}

	function lastMintedToken()
	external
	view
	returns (uint256)
	{
		return _tokenNumber;
	}

	




}