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
        address _receiveToken) external ;
    function addWhiteList(address[] memory _users) external ; 
    function removeWhiteList(address[] memory _users) external ;
}