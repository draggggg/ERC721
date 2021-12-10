const Str = require('@supercharge/strings')
// const BigNumber = require('bignumber.js');

var TDErc20 = artifacts.require("ERC20TD.sol");
var evaluator = artifacts.require("Evaluator.sol");
var evaluator2 = artifacts.require("Evaluator2.sol");
var ExerciceSolution = artifacts.require("ExerciceSolution.sol");


module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await deployTDToken(deployer, network, accounts); 
        await deployEvaluator(deployer, network, accounts); 
        // await setPermissionsAndRandomValues(deployer, network, accounts); 
        await doExercices(deployer, network, accounts);  
    });
};

async function deployTDToken(deployer, network, accounts) {
	TDToken = await TDErc20.at("0x46a9Dc47185F769ef9a11927B0f9d2fd0dEc3304")
}

async function deployEvaluator(deployer, network, accounts) {
	Evaluator = await evaluator.at("0xa0b9f62A0dC5cCc21cfB71BA70070C3E1C66510E") 
	Evaluator2 = await evaluator.at("0x4f82f7A130821F61931C7675A40fab723b70d1B8")
}



async function doExercices(deployer, network, accounts){
	//deploy ERC721 contract
	MyERC721 = await ExerciceSolution.new("MyFarm","Farm");

	//submit exercice
	await Evaluator.submitExercice(MyERC721.address);

	// exercice 1
	// mint token
	await MyERC721.declareAnimal(0, 4, 0, "VACHE");
	//transfer to Evaluator
	await MyERC721.transferFrom(accounts[0], Evaluator.address, 1);
	//validation
	await Evaluator.ex1_testERC721();

	// exercice 2a
	await Evaluator.ex2a_getAnimalToCreateAttributes();

	// exercice 2b
	const sex = await Evaluator.readSex(accounts[0]);
	const legs = await Evaluator.readLegs(accounts[0]);
	const wings = await Evaluator.readWings(accounts[0]);
	const name = await Evaluator.readName(accounts[0]);

	await MyERC721.declareAnimal(sex, legs, wings, name);
	await MyERC721.transferFrom(accounts[0], Evaluator.address, 2);
	await Evaluator.ex2b_testDeclaredAnimal(2);

	// exercice 3
	await Evaluator.ex3_testRegisterBreeder();

	// exercice 4
	await Evaluator.ex4_testDeclareAnimal();

	// exercice 5
	await Evaluator.ex5_declareDeadAnimal();

	// exercice 6a
	await Evaluator.ex6a_auctionAnimal_offer();

	// exercice 6b
	await MyERC721.declareAnimal(0, 4, 0, "BREBIS");
	const num = await MyERC721.lastMintedToken();
	await MyERC721.offerForSale(num, 345)

	await Evaluator.ex6b_auctionAnimal_buy(num);
}

