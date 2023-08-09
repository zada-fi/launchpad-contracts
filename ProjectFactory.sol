import "Storage.sol";
import "IProject.sol";
import "Governable.sol";
import "Project.sol";

contract ProjectFactory is Storage,Governable {
        function createProject(string memory _name,IProject.ProjectInfo memory _project) onlyGovernor external returns (address project)  {
        require(getProjects[_name] == address(0),'L1');
        bytes memory bytecode = type(Project).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_name, _project.preSaleStart,_project.pubSaleEnd));
        assembly {
            project := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IProject(project).init(_name,_project);
        getProjects[_name] = project;
        allProjects.push(project);
        emit ProjectCreated(_name,project);
    }
}