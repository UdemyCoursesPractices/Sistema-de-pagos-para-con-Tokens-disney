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
        Clientes[msg.sender].tokens_comprados += _numTokens;

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
    function generaTokens(uint _numTokens) public unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    //------------------------------ GESTION DE DISNEY ------------------------------
   
    
    //Modificador para controlar las funciones ejecutables por disney
    modifier unicamente(address _direccion){
        require(_direccion == owner, "No tienes permiso");
        _;
    }
    
    //Events
    
    event disfruta_atraccion(string);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);
    
    //struct de las atracciones_utilzadas
    struct atraccion{
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }
    
    //mapping nombre con una estructura de datos de la atraccion.
    mapping(string => atraccion) public MappingAtracciones;
    
    
    //array para almacenar el nombre de las atracciones.
    string[] Atracciones;
    
    //mapping para relacionar una identidad (Cliente) con su historial en DISNEY
    mapping(address => string[]) HistorialAtracciones;
    
    //Hombre araña -> 8 Tokens
    //Toy Story -> 1 Tokens
    //StarWars -> 5 tokens
    
    //Crea nuevas atracciones para DISNEY. Solo es ejecutable para DISNEY (unicamente modifier)
    function nuevaAtraccion(string memory _nombreAtraccion, uint _precio) public unicamente(msg.sender){
        //Creacion de una atraccion en DISNEY
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        //almacenar en el arraiy las Atracciones
        Atracciones.push(_nombreAtraccion);
        //Emision evento nuevaAtraccion
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }
    
    //Dar de baja atracciones
    function BajaAtraccion (string memory _nombreAtraccion) public unicamente(msg.sender){
        //mover el bool del struct atracciones a falso
    
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        //evento de BajaAtra
        emit baja_atraccion(_nombreAtraccion);
    }
    
    //Visualizar las atracciones de Disney.
    function AtraccionesDisponibles() public view returns(string[] memory){
        return Atracciones;
    }
    
    
    //Funcion que permite a un cliente pagar la atraccion.
    function SubirseAtraccion(string memory _nombreAtraccion) public {
        //precio de la atracion (en tokens)
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        //verifica el estado de la atracion (si esta disponible para su uso)
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "NO esta en uso esta atraccion");
        //Verifique el numero de tokens que tiene el cliente.
        require(tokens_atraccion <= misTokens(), "Necesitas mas tokens para subirte a esta atraccion");
        
        /*El cliente paga la atraccion.
            -Ha sido necesario crear una function en ERC20.sol con el nombre "transferencia_Disney" debido a que en caso de usar el transfer o transfer from
            se generaba un conflicto con las direcciones de swap.. ya que el msg.sender que recibia el metodo Transfer o TransferFrom era la direccion del contrato Disney.sol.
        */
        
       token.transferencia_Disney(msg.sender, address(this), tokens_atraccion);
       //Almacenar el historial del cliente en el MappingAtracciones
       HistorialAtracciones[msg.sender].push(_nombreAtraccion);
       emit disfruta_atraccion(_nombreAtraccion);
    } 
    
    //Visualizar el historial dcompleto de atracciones disfrutadas por un cliente
    function Historial()public view returns(string [] memory){
        return HistorialAtracciones[msg.sender];
    }
    
    //Funcion para que un cliente pueda cambiar tokens por su valor en eth.
    function DevolverTokens(uint _numTokens) public payable{
        //El numero de tokes a devolver esta en la cartera del cliente.
        require(_numTokens > 0, "necesario regresar una cantidad positiva de tokens");
        require(_numTokens <= misTokens(), "No tienes los tokens que deseas devolver");
        
        //El cliente devulve los tokens
        token.transferencia_Disney(msg.sender, address(this), _numTokens);
        //Disney regresa los eth
        msg.sender.transfer(PrecioTokens(_numTokens));
        
    }
}

