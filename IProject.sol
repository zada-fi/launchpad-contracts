interface IProject {
    function init(
        string memory _name,
        uint256 _maxCap,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _minUserCap,
        uint256 _maxUserCap,
        address _tokenAddress,
        uint256 _tokenPrice,
        address _projectOwner,
        address _receiveToke,
        address _feeAddress
        ) external ;
    function addWhiteList(address[] memory _users) external ; 
    function removeWhiteList(address[] memory _users) external ;
    function updateMaxCap(uint256 maxCap) external ;
    function updateUserMaxCap(uint256 userMaxCap) external ;

    function updateUserMinCap(uint256 userMinCap) external ;

    function updateStartTime(uint256 newsaleStart) external ;

    function updateEndTime(uint256 newSaleEnd) external ;

    function updateTokenPrice(uint256 newPrice) external ;

    function updateProjectOwner(address newOwner) external ;

    function pause() external ;

    function unpause() external ;
}