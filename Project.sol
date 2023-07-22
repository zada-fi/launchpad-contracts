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
    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public totalUSDCReceived;
    uint256 public totalUsers;
    address public projectOwner;
    address public tokenAddress;
    uint256 public minUserCap;
    uint256 public maxUserCap;
    uint256 public tokenPrice;
    address public receiveToken;
    address public feeAddress;
    mapping(address=>bool) public whiteList;
    mapping(address=>uint) public users;
    mapping(address=>bool) public claimedList;

    event UserInvestment(address user,uint amount);
    event UserClaim(address user,uint amount);

    function init (
        string memory _name,
        uint256 _maxCap,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _minUserCap,
        uint256 _maxUserCap,
        address _tokenAddress,
        uint256 _tokenPrice,
        address _projectOwner,
        address _receiveToken,
        address _feeAddress
    ) external  {
        name = _name;
        require(_maxCap > 0, "Z1");
        maxCap = _maxCap;
        require(_minUserCap > 0, "Z2");
        minUserCap = _minUserCap;
        require(_maxUserCap > 0, "Z3");
        maxUserCap = _maxUserCap;
        require(
            _saleStart > block.timestamp && _saleEnd > _saleStart,
            "T1"
        );
        saleStart = _saleStart;
        saleEnd = _saleEnd;
        require(_projectOwner != address(0), "O1");
        projectOwner = _projectOwner;
        require(_tokenAddress != address(0), "TK1");
        tokenAddress = _tokenAddress;
        require(_tokenPrice > 0, "TK2");
        tokenPrice = _tokenPrice;
        receiveToken = _receiveToken;
        feeAddress = _feeAddress;
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

    function updateStartTime(uint256 newsaleStart) public onlyOwner {
        require(block.timestamp < saleStart, "T2");
        saleStart = newsaleStart;
    }

    function updateEndTime(uint256 newSaleEnd) public onlyOwner {
        require(
            newSaleEnd > saleStart && newSaleEnd > block.timestamp,
            "T3"
        );
        saleEnd = newSaleEnd;
    }

    function updateTokenPrice(uint256 newPrice) public onlyOwner {
        require(block.timestamp < saleStart, "S1");
        tokenPrice = newPrice;
    }

    function updateProjectOwner(address newOwner) public onlyOwner {
        require(block.timestamp <= saleEnd, "S2");
        require(newOwner != address(0) && projectOwner != newOwner,"OW1");
        projectOwner = newOwner;
    }


    function addWhiteList(address[] memory _users) public onlyOwner {
        require(block.timestamp <= saleEnd, "S2");
        for (uint i=0; i < _users.length;i++) {
            whiteList[_users[i]] = true;
        }
    }

    function removeWhiteList(address[] memory _users) public onlyOwner {
        require(block.timestamp <= saleEnd, "S2");
        for (uint i=0; i < _users.length;i++) {
            whiteList[_users[i]] = false;
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
        require(block.timestamp >= saleStart, "S1");
        require(block.timestamp <= saleEnd, "S2");
        require(
            totalUSDCReceived < maxCap,
            "C1"
        );
        uint256 realAmount = amount;
        if (totalUSDCReceived.add(amount) > maxCap) {
            realAmount = maxCap.sub(totalUSDCReceived); 
        }
        require(whiteList[msg.sender] == true,"W1");
        uint256 expectedAmount = realAmount.add(
            users[msg.sender]
        );
        require(expectedAmount >= minUserCap,"A1");
        require(expectedAmount <= maxUserCap,"A2");

        IERC20(receiveToken).safeTransferFrom(msg.sender, address(this), realAmount);
        totalUSDCReceived = totalUSDCReceived.add(realAmount);
        users[msg.sender] = expectedAmount;
        emit UserInvestment(msg.sender, realAmount);
        return true;
    }

    function claimTokens() external whenNotPaused returns (bool){
        require(block.timestamp >= saleEnd, "S1");
        require(whiteList[msg.sender] == true && claimedList[msg.sender] == false,"W1");
        uint256 usdcAmount = users[msg.sender];
        require(usdcAmount > 0,"A1");
        uint256 receive_token_decimals = IERC20(receiveToken).decimals();
        uint256 claimTokensAmount = usdcAmount.div(10**receive_token_decimals).mul(tokenPrice);
        //make sure the user can claim all tokens
        IERC20(tokenAddress).safeTransferFrom(projectOwner,msg.sender,claimTokensAmount);
        claimedList[msg.sender] = true;
        emit UserClaim(msg.sender,claimTokensAmount);
        return true;
    }

    function withdraw() external {
        require(block.timestamp >= saleEnd, "S1");
        require(msg.sender == projectOwner,"P1");
        uint256 fee = totalUSDCReceived.mul(95).div(100);
        uint256 withdrawAmount = totalUSDCReceived.sub(fee);
        IERC20(receiveToken).safeTransfer(feeAddress,fee);
        IERC20(receiveToken).safeTransfer(msg.sender,withdrawAmount);
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = IERC20(receiveToken).allowance(allower, address(this));
        require(amount <= ourAllowance, "M1");
        _;
    }
}