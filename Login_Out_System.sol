// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//存在问题 adminArray  adminArray.length

/*系统组成
1.注册
2.登录
3退出
以下流程都触发event事件

系统功能
1构造时产生superadmin
能邀请注册和任命admin
2可以允许admin进行多签转账和，全体成员通过投票罢免superadmin
成功罢免superadmin的投票发起人将成为superadmin
3admin的要请人数受时间戳的限制
目的是为了防止少数人可以作恶拉票

*/
contract router{
//基础用户状态事件
    event UserRegister(address indexed _userAddress);
    event UserLogin(address indexed _userAddress);
    event UserLogout(address indexed _userAddress);
    event UserGranAdmin(address indexed _userAddress,bool isAdmin);
    event UserRevokeAdmin(address indexed _userAddress,bool isAdmin);
    event Receive(address indexed from,uint indexed value);
    event SubmitTx(uint indexed txId);
    event IsApproved(address indexed adminAddress,uint _txId);
    event TxExecuted(uint indexed _txId);
    event RevokeTx(uint indexed _txId,address indexed admin);

//回退函数 接受代币
    receive() external payable{
        emit Receive(msg.sender,msg.value);
    }

//结构体

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool isExecuted;
    }
//需要区分superadmin和admin还有普通用户
    mapping(address => bool) public isSuperAdmin;
    mapping(address => bool) public isAdmin;

//用户状态
    mapping(address => bool) public isRegister;
    mapping(address => bool) isLoging;

    mapping(uint => mapping(address => bool)) isApproved;



    address [] public registerArray;//admin可以帮别人注册，故只有admin才能push数组
    address [] public adminArray;//admin数组用来看看谁是admin或遍历admin
    uint public adminNum;
    Transaction [] public transactionArray;
//注册

    constructor(){
        isAdmin[msg.sender] = true;
        isSuperAdmin[msg.sender] = true;
        isRegister[msg.sender] = true;
        adminArray.push(msg.sender);
        registerArray.push(msg.sender);
        adminNum++;
    }
//管理者权限
    modifier onlyAdmin{
        require(isLoging[msg.sender],"you are not loging");
        require(isAdmin[msg.sender] || isSuperAdmin[msg.sender],"you are not athorized");
        _;
    }
//超级管理权限
    modifier onlySuperAdmin{
        require(isLoging[msg.sender],"you are not loging");
        require(isSuperAdmin[msg.sender],"you are not athorized");
        _;
    }

//登录限制和注册限制



    modifier onlyLoging{
        require(isLoging[msg.sender],"you are not loging");
        _;
    }

//交易修改器
    //判断交易Id存在
    modifier txExists(uint _txId){
        require(_txId < transactionArray.length,"txId does not exists");
        _;
    }
    //没有批准过txId
    modifier notApproved(uint _txId){
        require(!isApproved[_txId][msg.sender],"tx already approved");
        _;
    }
    //没有被executed
    modifier notExecuted(uint _txId){
        require(!transactionArray[_txId].isExecuted,"tx already executed");
        _;
    }

//注册
    function setRegister(address _registerAddress) external onlyLoging onlyAdmin{
        require(isLoging[msg.sender],"you are not register");
        registerArray.push(_registerAddress);
        isRegister[_registerAddress] = true;
        registerArray.push(_registerAddress);
        emit UserRegister(_registerAddress);

    }
//登录
    function login() external {
        require(isRegister[msg.sender],"you are not register");
        require(!isLoging[msg.sender],"you are loging");
        isLoging[msg.sender] = true;
        emit UserLogin(msg.sender);

    }

//退出

    function logout()external onlyLoging{
        require(isRegister[msg.sender],"you are not register");
        isLoging[msg.sender] = false;
        emit UserLogout(msg.sender);
    }
//升级撤销权限

    function granAdmin(address _setAddress) external onlyLoging onlySuperAdmin{
        require(isRegister[msg.sender],"this user haven't registed,please go to register");
        isAdmin[_setAddress] = true;
        adminArray.push(_setAddress);
        adminNum++;
        emit UserGranAdmin(_setAddress,isAdmin[_setAddress]);
    } 
    function revokeAdmin(address _setAddress) external onlyLoging onlySuperAdmin{
        require(isRegister[msg.sender],"this user haven't registed,please go to register");
        isAdmin[_setAddress] = false;
        adminNum--;
        emit UserRevokeAdmin(_setAddress,isAdmin[_setAddress]);
    } 
//多签名交易
    //提交交易
    function submitTx(address _to,uint _value,bytes calldata _data) external onlyAdmin{
        transactionArray.push(Transaction({
            to : _to,
            value : _value,
            data : _data,
            isExecuted : false
        }));
        emit SubmitTx(transactionArray.length-1);
    }
    //批准
    function approve(uint _txId) 
        external
        onlyAdmin
        txExists(_txId)
        notExecuted(_txId)
    {
        isApproved[_txId][msg.sender] = true;
        emit IsApproved(msg.sender,_txId);
    }
    //批准的admin数
    function _getApprovalAdmin(uint _txId) public view returns(uint count){
        for(uint i;i < adminArray.length; i++){
            if(isApproved[_txId][adminArray[i]]){
                count += 1;
            }
        }
    }
    function excute(uint _txId) 
        external
        onlyAdmin
        txExists(_txId)
        notExecuted(_txId)
    {
        require(_getApprovalAdmin(_txId) >= adminNum/2,"approver not enought");
        Transaction storage transaction = transactionArray[_txId];

        transaction.isExecuted = true;

        (bool success,) = transaction.to.call{value : transaction.value}(
            transaction.data
        );
        require(success,"tx failed");
        emit TxExecuted(_txId);
    }

    function revokeTx(uint _txId) external onlyAdmin txExists(_txId) notExecuted(_txId){
        require(isApproved[_txId][msg.sender],"tx not approve");
        isApproved[_txId][msg.sender] = false;
        emit RevokeTx(_txId,msg.sender);
    }

    function getBalance()public view returns(uint){
        return address(this).balance;
    }

    function deposit()external payable{
        emit Receive(msg.sender,msg.value);
    }





}
