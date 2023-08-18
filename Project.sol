// SPDX-License-Identifier: UNLICENSED
import "./Ownable.sol";
import "./Pausable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./IProject.sol";

contract Project is Ownable, Pausable, IProject {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public name;
    uint256 public maxCap;
    uint256 public preSaleStart;
    uint256 public preSaleEnd;
    uint256 public pubSaleEnd;
    uint256 public totalUSDCReceived;
    uint256 public totalUsers;
    address public projectOwner;
    address public tokenAddress;
    uint256 public minUserCap;
    uint256 public maxUserCap;
    uint256 public tokenPrice;
    uint16  public whiteListLen; 
    uint16  public maxWhiteListLen; 
    address public receiveToken;
    mapping(address=>bool) public whiteList;
    mapping(address=>uint) public users;
    mapping(address=>bool) public claimedList;

    event UserInvestment(address user,uint amount);
    event UserClaim(address user,uint amount);

    error MaxWhiteListLenLimit();

    function init (string memory _name,ProjectInfo memory project) external  {
        name = _name;
        require(project.maxCap > 0, "Z1");
        maxCap = project.maxCap;
        require(project.minUserCap > 0, "Z2");
        minUserCap = project.minUserCap;
        require(project.maxUserCap > 0, "Z3");
        maxUserCap = project.maxUserCap;
        require(
            project.preSaleStart > block.timestamp && project.preSaleEnd > project.preSaleStart && project.pubSaleEnd > project.preSaleEnd,
            "T1"
        );

        preSaleStart = project.preSaleStart;
        preSaleEnd = project.preSaleEnd;
        pubSaleEnd = project.pubSaleEnd;
        maxWhiteListLen = project.maxWhiteListLen;
        require(project.projectOwner != address(0), "O1");
        projectOwner = project.projectOwner;
        require(project.tokenAddress != address(0), "TK1");
        tokenAddress = project.tokenAddress;
        require(project.tokenPrice > 0, "TK2");
        tokenPrice = project.tokenPrice;
        receiveToken = project.receiveToken;
        whiteListLen = 0;
    }

    function updateMaxCap(uint256 _maxCap) public onlyOwner {
        require(_maxCap > 0, "Z1");
        maxCap = _maxCap;
    }

    function updateUserMaxCap(uint256 _maxCap) public onlyOwner {
        require(_maxCap > 0, "Z2");
        maxUserCap = _maxCap;
    }

    function updateUserMinCap(uint256 _minCap) public onlyOwner {
        require(_minCap > 0, "Z3");
        minUserCap = _minCap;
    }

    function updatePreStartTime(uint256 newSaleStart) public onlyOwner {
        require(block.timestamp < preSaleStart, "T2");
        preSaleStart = newSaleStart;
    }

    function updatePreEndTime(uint256 newSaleEnd) public onlyOwner {
        require(
            newSaleEnd > preSaleStart && newSaleEnd > block.timestamp,
            "T3"
        );
        preSaleEnd = newSaleEnd;
    }
    function updatePubEndTime(uint256 newSaleEnd) public onlyOwner {
        require(
            newSaleEnd > preSaleEnd && newSaleEnd > block.timestamp,
            "T3"
        );
        pubSaleEnd = newSaleEnd;
    }

    function updateTokenPrice(uint256 newPrice) public onlyOwner {
        require(block.timestamp < pubSaleEnd, "S1");
        tokenPrice = newPrice;
    }

    function updateProjectOwner(address newOwner) public onlyOwner {
        require(block.timestamp <= pubSaleEnd, "S2");
        require(newOwner != address(0) && projectOwner != newOwner,"OW1");
        projectOwner = newOwner;
    }


    function addWhiteList(address[] memory _users) public onlyOwner {
        require(block.timestamp <= preSaleEnd && whiteListLen <= maxWhiteListLen, "S2");
        for (uint i=0; i < _users.length;i++) {
            whiteListLen++;
            if (whiteListLen > maxWhiteListLen) {
                break;
            }
            whiteList[_users[i]] = true;         
        }
    }

    function removeWhiteList(address[] memory _users) public onlyOwner {
        require(block.timestamp <= preSaleEnd && whiteListLen > 0, "S2");
        for (uint i=0; i < _users.length;i++) {
            whiteList[_users[i]] = false;
            whiteListLen--;
        }

    }
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function buyTokens(uint256 amount)
        external
        whenNotPaused
        _hasAllowance(msg.sender, amount)
        returns (bool)
    {
        require(block.timestamp >= preSaleStart && block.timestamp <= pubSaleEnd,"T3");
        if (block.timestamp >= preSaleStart && block.timestamp <= preSaleEnd){
            require(whiteList[msg.sender] == true,"W1"); 
        } 

        uint256 expectedAmount = amount.add(
            users[msg.sender]
        );
        require(expectedAmount >= minUserCap,"A1");
        require(expectedAmount <= maxUserCap,"A2");

        IERC20(receiveToken).safeTransferFrom(msg.sender, projectOwner, amount);
        totalUSDCReceived = totalUSDCReceived.add(amount);
        users[msg.sender] = expectedAmount;
        emit UserInvestment(msg.sender, amount);
        return true;
    }
    
    function claimTokens() external whenNotPaused returns (bool){
        require(block.timestamp > pubSaleEnd, "S1");
        require(claimedList[msg.sender] == false,"W1");
        uint256 usdcAmount = users[msg.sender];
        require(usdcAmount > 0,"A1");
        uint256 receive_token_decimals = IERC20(receiveToken).decimals();
        uint256 claimTokensAmount = usdcAmount.div(10**receive_token_decimals).mul(tokenPrice);
        //make sure the user can claim all tokens
        IERC20(tokenAddress).safeTransferFrom(projectOwner,msg.sender,claimTokensAmount);
        claimedList[msg.sender] = true;
        users[msg.sender] = 0;
        emit UserClaim(msg.sender,claimTokensAmount);
        return true;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = IERC20(receiveToken).allowance(allower, address(this));
        require(amount <= ourAllowance, "M1");
        _;
    }
}