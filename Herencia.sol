// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Herencia {

    uint public valorAlmacenado;
    
    constructor()  {}

    function setValue(uint _valor) public 
    {
        valorAlmacenado = _valor;
    }
}
