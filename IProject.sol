interface IProject {
    struct ProjectInfo {
        uint256 maxCap;
        uint64 preSaleStart;
        uint64 preSaleEnd;
        uint64 pubSaleEnd;
        uint256 minUserCap;
        uint256 maxUserCap;
        address tokenAddress;
        uint256 tokenPrice;
        address projectOwner;
        address receiveToken;
        uint16  maxWhiteListLen;
    }
    
    function init(string memory _name,ProjectInfo memory project) external ;
    function addWhiteList(address[] memory _users) external ; 
    function removeWhiteList(address[] memory _users) external ;
    function updateMaxCap(uint256 maxCap) external ;
    function updateUserMaxCap(uint256 userMaxCap) external ;

    function updateUserMinCap(uint256 userMinCap) external ;

    function updatePreStartTime(uint64 newsaleStart) external ;

    function updatePreEndTime(uint64 newSaleEnd) external ;
    function updatePubEndTime(uint64 newSaleEnd) external ;
    function updateTokenPrice(uint256 newPrice) external ;

    function updateProjectOwner(address newOwner) external ;

    function pause() external ;

    function unpause() external ;
}