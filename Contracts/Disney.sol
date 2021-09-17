// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney{
    //_------------------------------DECLARACIONES INICIALES ----------------------------------

    //Instancia del contrato token
    ERC20Basic private token;
    
    //direccion del propietario.
    address payable public owner;

    //Estructura de datos para almacenar clientes.
    struct cliente{
        uint tokens_comprados;
        string [] atracciones_utilzadas;
    }

    mapping(address => cliente) public Clientes;
    

    //Constructor.
    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    //------------------------------ GESTION DE TOKENS ------------------------------

    // Funcion para establecer el precio de 1 token. 
    function PrecioTokens(uint _numTokens) internal pure returns(uint){
        //convercion de tokens a Ethers. 1token = 1 Ether
        return _numTokens*(1 ether);
    }

    //Funcion para comprar los tokens.
    function ComprarTokens(uint _numTokens) public payable {
        //Establemos tokens, en eth.
        uint coste = PrecioTokens(_numTokens);
        //Se evalua el dinero que el cliente paga por los tokens
        require(msg.value >= coste, "Compra menos tokens o paga con mas ethers.");
        //Cambio, es la diferencia entre el coste y el valor de pago. Le retornamos el vuelto al comprador
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);
        //obtener el numero de tokens disney disponible.
        uint Balance = balanceOF();
        require(_numTokens <= Balance, "Compra un numero menor de Tokens");
        token.transfer(msg.sender, _numTokens);
        //Almacenar en un registro los tokens comprados.
        Clientes[msg.sender].tokens_comprados = _numTokens;

    } 
    function balanceOF() public view returns(uint){
        return token.balanceOf(address(this));
    }
    
    function balanceOFTheOwner() public view returns(uint){
        return token.balanceOf(address(owner));
    }
    
    //Visualizar el numero de tokens restantes de un Cliente
    function misTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }
    
    //Funcion para generar mas tokens.
    function generaTokens(uint _numTokens) public unicomente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    //------------------------------ GESTION DE DISNEY ------------------------------
   
    
    //Modificador para controlar las funciones ejecutables por disney
    modifier unicomente(address _direccion){
        require(_direccion == owner, "No tienes permiso");
        _;
    }
}