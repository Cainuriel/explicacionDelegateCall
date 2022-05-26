// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Herencia.sol";

contract Principal {

    //IMPORTANTE: La posicion de la variable resultadoCalculadora tiene que estar en el mismo orden
    //que en el contrato calculadora. En caso contrario, no encontrará la variable.
    uint256 public resultadoCalculadora;
    
    address public user;
    
    Herencia public herencia;
    
    constructor(Herencia _contractHerencia)  
    {
        herencia = _contractHerencia;

    }
    
    function saveValue(uint _value) public returns (bool) {
        herencia.setValue(_value);
        return true;
    }
    function getValue() public view returns (uint) {
        return herencia.valorAlmacenado();
    }
    
    function calculationWithDelegateCall(address conctractCalculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = conctractCalculator.delegatecall(abi.encodeWithSignature("sumar(uint256,uint256)", a, b));
        require(success, "fallo con la funcion delegateCall"); 
        return abi.decode(result, (uint256));
    }
    
    
    function calculationWithCall(address conctractCalculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = conctractCalculator.call(abi.encodeWithSignature("sumar(uint256,uint256)", a, b));
        require(success, "fallo con la funcion de llamada externa");
        return abi.decode(result, (uint256));
    }
}
