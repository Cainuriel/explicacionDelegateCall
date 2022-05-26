// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Calculadora {

    uint256 public resultadoCalculadora;
    
    address public user;

    function sumar(uint256 a, uint256 b) public returns (uint256) 
    {
        resultadoCalculadora = a + b;

        user = msg.sender; // para almacenar quien llama. 
        
        return resultadoCalculadora;
    }
}
