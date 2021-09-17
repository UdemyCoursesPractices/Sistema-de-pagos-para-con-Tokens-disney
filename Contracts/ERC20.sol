// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//Usamos una nomenclatura para hacer pruebas. 
//Leandro : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Ariel :   0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//Maria :   0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
//Contract Address: 0x35d22f202601Eb9Ae54EbF18C52c4731db47A1c3

//interface de nuestro token ERC20
interface IERC20 {
    //Devuelve la cantidad de tokens en existencia
    //External es que la programaremos fuera de la interface. Solo estara la cabecera
    function totalSupply() external view returns(uint256);
    
    //Devuelve la cantidad de tokens para una address indicada por parametro
    function balanceOf(address account)external view returns(uint256);
    
    //Regresa al numero de tokens que el spender podra gastar en nombre del propietario(owner)
    function allowance(address owner, address spender) external view returns (uint256);
    
    //Devuelve un valor booleano resultado de operacion indicada
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    //Devuelve un valor booleano con el resultado de la operacion de gasto
    function approve(address spender, uint256 amount) external returns(bool);
    
    //Devuelve un valor booleano con el resultado de la operacion de paso de una cantidad de tokens usando el metodo allowance
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    
    //Eventos que se debe emitir cuando una cantidad de tokens pasen de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //Evento que se debeemitir cuando se establece una asignacion con el metodo allowance()
    event Approval(address indexed awner, address indexed spender, uint256 value);
}

//Implementacion de las funciones del tojken ERC20
contract ERC20Basic is IERC20{
    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "JBJ-TOKEN";
    uint8 public constant decimals = 2;
    
    
    //event Transfer(address indexed from, address indexed to, uint256 tokens);
    //event Approval(address indexed owner, address indexed spender, uint256 tokens);
    
    
    using SafeMath for uint256;
    
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed; // se distribullen en diferente personas, una los mina.
    uint256 totalSupply_; //Por defecto es privado.
    
    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }
    
    
    //Public para accederla desde fuera, override para reescribirla.
    function totalSupply() public  override view returns(uint256){
        return totalSupply_;
    }
    
    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }
    
    function balanceOf(address tokenOwner)public override view returns(uint256){
        return balances[tokenOwner];
    }
    
    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }
    
    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]); 
        balances[msg.sender] =balances[msg.sender].sub(numTokens); // Resta los tokens del emisor. El orden es el que esta aqui.
        balances[recipient] = balances[recipient].add(numTokens); // Agregamos las cantidad  al otro.
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }
    
    function approve(address delegate, uint256 numTokens) public override returns(bool){
        allowed[msg.sender][delegate] = numTokens; // No ahi transferencia. Solo permitimos que el delegate pueda usar tokens de nuestra wallet
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}