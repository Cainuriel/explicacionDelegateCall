# Explicación de la función delegateCall 

Entender el uso de la función ```delegateCall``` puede ser al principio confuso. 
Este repositorio pretende explicar las diferentes formas de acceder al estado de un contrato para comprenderla.

Antes que nada me disculpo por el uso del castellano y el inglés con las variables. 
No termino de decidirme cual idioma cuando hago tutoriales en castellano.
Espero que no por ello le sea díficil entender mi código.


## Crontrato Herencia

El contrato herencia almacena un valor de forma clásica. 
Pruebe a deployarlo y cambie su valor usando la función ```setValue```.
```solidity
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
```
Ningún misterio hasta aquí.
Vamos ahora con el contrato principal para heredar éste  y acceder a el de forma clasica.

### Accediendo a contrato Herencia con el contrato Principal

Deploye el contrato Principal. 
Comnprobará que hereda el contrato Herencia y lo usa como si fuese una interface.
Ignore la variable ```resultadoCalculadora``` porque será usada más adelante.
Verá que nos pide al deployar la dirección del contrato Herencia.
Si me ha hecho caso lo tendrá deployado de antes, pásele la dirección.

```solidity

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

```
Así ahora podrá acceder a la variable ```valorAlmacenado``` a través de la función ```getValue```, y por supuesto setear su valor con ``` saveValue ```.
Nada nuevo espero para usted.

## contrato Calculadora

```solidity

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
```
Vamos ahora con el contrato Calculadora.
Compile y deploye pero __no use la función sumar__.
Compruebe solamente que los valores de las variables están inicializadas a cero como es normal en solidity.
Volvamos ahora al contrato principal.

### Almacenando datos con una llamada externa

Fíjese ahora en la siguiente función:

```solidity
   function calculationWithCall(address conctractCalculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = conctractCalculator.call(abi.encodeWithSignature("sumar(uint256,uint256)", a, b));
        require(success, "fallo con la funcion de llamada externa");
        return abi.decode(result, (uint256));
    }
```
Aqui hay presentes varios conceptos que deberá comprender para entender lo que vamos hacer. 

1. El identificador de una función. Son los cuatro primeros bytes del hash sacado de su nombre junto a los tipos de sus argumentos.
Puede ver esos cuatro bytes colocando ```msg.sig``` como valor de retorno en cualquier funcion que llame.  
2. El uso de ``` abi.encodeWithSignature ``` https://docs.soliditylang.org/en/v0.8.14/units-and-global-variables.html?highlight=abi.encodeWithSignature#abi-encoding-and-decoding-functions
3. El método call. 

Llamando a ésta función accederemos a la del contrato pásado por argumento, y sin necesitar su ABI, interactuaremos con el
si disponemos de acceso. 

Para ver su efecto en el almacenamiento mire los getters de las variables ``` user ``` y  ``` resultadoCalculadora ``` del contrato Principal.
Hemos comprobado antes que también están a cero los del contrato Calculadora.
Llame ahora a la función ``` calculationWithCall ```, pasando la dirección delcontrato Calculadora y unos valores a sumar.

Verá que se han actualizado los valores del contrato Calculadora. 
Comprobará como la dirección en ``` user ``` del contrato Calculadora __es la dirección la del contrato Principal__.

## DelegateCall

Y llegamos a la función delegateCall.
Lo que conseguimos con delegateCall __es almacenar los valores en nuestro contrato Principal y no en el contrato Calculadora__. 
Para esto debemos poseer una configuración de variables globales igual al contrato que llamemos.
De esta forma podemos tener el estado de un contrato separado de un cuerpo de funciones que las setea.
Esta es la esencia de lo que es un proxy en solidity. https://ethereum.stackexchange.com/questions/114809/what-exactly-is-a-proxy-contract-and-why-is-there-a-security-vulnerability-invol


Compruebe llamando a ``` calculationWithDelegateCall ``` y verá como en éste caso, las variables que se actualizan __son las del contrato principal__.

