// SPDX-License-Identifier: UNLICENSED
import "Ownable.sol";
import "Pausable.sol";
import "SafeMath.sol";
import "SafeERC20.sol";
import "Project.sol";
import "Governable.sol";

contract Launchpad is Governable {
    event ProjectCreated(string indexed projectName, address project);
    mapping(string=>address) public getProjects; 
    address[] allProjects;

    function createProject(        
        string memory _name,
        uint256 _maxCap,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _minUserCap,
        uint256 _maxUserCap,
        address _tokenAddress,
        uint256 _tokenPrice,
        address _projectOwner,
        address _receiveToken) onlyGovernor external returns (address project)  {
        require(getProjects[_name] == address(0),'L1');
        bytes memory bytecode = type(Project).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_name, _saleStart,_saleEnd));
        assembly {
            project := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IProject(project).init(_name,_maxCap,_saleStart,_saleEnd,_minUserCap,_maxUserCap,_tokenAddress,_tokenPrice,_projectOwner,_receiveToken);
        getProjects[_name] = project;
        allProjects.push(project);
        emit ProjectCreated(_name,project);
    }

    function addWhiteList(address project,address[] memory users) public onlyGovernor {
        IProject(project).addWhiteList(users);
    }

    function removeWhiteList(address project,address[] memory users) public onlyGovernor {
        IProject(project).removeWhiteList(users);
    }

    function updateMaxCap(address project,uint256 maxCap) public onlyGovernor {
        IProject(project).updateMaxCap(maxCap);
    }

    function updateUserMaxCap(address project,uint256 userMaxCap) public onlyGovernor {
        IProject(project).updateUserMaxCap(userMaxCap);
    }

    function updateUserMinCap(address project,uint256 userMinCap) public onlyGovernor {
        IProject(project).updateUserMinCap(userMinCap);
    }

    function updateStartTime(address project,uint256 newsaleStart) public onlyGovernor {
        IProject(project).updateStartTime(newsaleStart);
    }

    function updateEndTime(address project,uint256 newSaleEnd) public onlyGovernor {
        IProject(project).updateEndTime(newSaleEnd);
    }

    function updateTokenPrice(address project,uint256 newPrice) public onlyGovernor {
        IProject(project).updateTokenPrice(newPrice);
    }

    function updateProjectOwner(address project,address newOwner) public onlyGovernor {
        IProject(project).updateProjectOwner(newOwner);
    }

    function pause(address project) public onlyGovernor {
        IProject(project).pause();
    }

    function unpause(address project) public onlyGovernor {
        IProject(project).unpause();
    }

}