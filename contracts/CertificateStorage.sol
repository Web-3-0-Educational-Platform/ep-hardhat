// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract CertificateStorage {
    address private owner;

    struct Certificate {
        string uuid;
        address student;
        bool isActive;
        string infoHash;
    }

    mapping (address => bool) private organizations;
    mapping (string => Certificate) private certificates;
    mapping (address => Certificate[]) private studentCertificates;
    mapping (address => string) private users;

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getCertificate(string memory _uuid) public view returns (Certificate memory) {
        return certificates[_uuid];
    }

    function getAllCertificates(address _student) public view returns (Certificate[] memory) {
        return studentCertificates[_student];
    }

    function addCertificate(string memory _uuid, string memory _infoHash, address _student) public {
        require(organizations[msg.sender], "Only the organizations can add certificate");
        Certificate memory newCertificate = Certificate({
            uuid: _uuid,
            infoHash: _infoHash,
            isActive: true,
            student: _student
        });
        certificates[_uuid] = newCertificate;
        studentCertificates[_student].push(newCertificate);
    }

    function disactiveCertificate(string memory _uuid) public {
        certificates[_uuid].isActive = false;
    }

    function isActive(string memory _uuid) public view returns (bool) {
        return certificates[_uuid].isActive;
    }

    function isOrganization(address _organization) public view returns (bool) {
        return organizations[_organization];
    }

    function addOrganization(address _organization) public {
        require(msg.sender == owner, "Only the owner can add organization");
        organizations[_organization] = true;
    }

    function removeOrganization(address _organization) public {
        require(msg.sender == owner, "Only the owner can remove organization");
        organizations[_organization] = false;
    }
    
    function getUser() public view returns (string memory) {
        return users[msg.sender];
    }

    function updateUser(string memory _infoHash) public {
        users[msg.sender] = _infoHash;
    }
}