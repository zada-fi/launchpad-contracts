// SPDX-License-Identifier: UNLICENSED
import "Ownable.sol";
import "IProject.sol";
import "Governable.sol";
contract Launchpad is Governable {
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

    function updatePreStartTime(address project,uint64 newsaleStart) public onlyGovernor {
        IProject(project).updatePreStartTime(newsaleStart);
    }

    function updatePreSaleEndTime(address project,uint64 newSaleEnd) public onlyGovernor {
        IProject(project).updatePreEndTime(newSaleEnd);
    }

    function updatePubEndTime(address project,uint64 newSaleEnd) public onlyGovernor {
        IProject(project).updatePubEndTime(newSaleEnd);
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