contract Storage {
    event ProjectCreated(string projectName, address project);
    mapping(string=>address) public getProjects; 
    address[] allProjects;
}