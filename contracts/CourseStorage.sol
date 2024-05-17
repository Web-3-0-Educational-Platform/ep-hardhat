// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract CourseStorage {
    address private owner;
    string private coursesHash; // массив адресов 

    struct Course {
        string uuid;
        address author;
        uint price;
        bool active;
        string infoHash; // title, description, files, etc
        string lessonsHash; // массив uuid уроков по порядку
        string studentsHash; // массив адресов студентов
        string commentHash; // массив комментариев к курсу
    }
    
    struct Grade {
        string uuid;
        address student;
        uint grade;
    } 
    
    struct Lesson {
        string uuid;
        string gradesHash; // массив оценок
        string infoHash; // title, description, answers, files, etc
    }

    mapping(string => Course) private courses;
    mapping(string => Lesson) private lessons;
    mapping(string => Grade) private grades;
    mapping(address => string[]) private studentCourses;
    mapping(address => uint) private payments;

    function indexOf(string[] memory arr, string memory searchFor) private pure returns (int) {
        for (uint i = 0; i < arr.length; i++) {
            if (keccak256(abi.encodePacked(arr[i])) == keccak256(abi.encodePacked(searchFor))) {
                return int(i);
            }
        }
        return -1;
    }

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getCourses() public view returns (string memory) {
        return coursesHash;
    }

    function addCourse(string memory _uuid, uint _price, string memory _infoHash, string memory _lessonsHash, string memory _coursesHash) public {
        Course memory newCourse = Course({
            uuid: _uuid,
            author: msg.sender,
            price: _price,
            infoHash: _infoHash,
            lessonsHash: _lessonsHash,
            studentsHash: '',
            commentHash: '',
            active: true
        });
        courses[_uuid] = newCourse;
        coursesHash = _coursesHash;
    }

    function deleteCourse(string memory _uuid, string memory _coursesHash) public {
        require(courses[_uuid].author == msg.sender, "Only the author can delete course");
        delete courses[_uuid];
        coursesHash = _coursesHash;
    }

    function updateCourse(string memory _uuid, uint _price, string memory _infoHash, bool _active) public {
        require(courses[_uuid].author == msg.sender, "Only the author can update course");
        courses[_uuid].price = _price;
        courses[_uuid].infoHash = _infoHash;
        courses[_uuid].active = _active;
    }

    function isActive(string memory _uuid) public view returns (bool) {
        return courses[_uuid].active;
    }

    function getCourse(string memory _uuid) public view returns (address, uint, string memory, string memory) {
        return (courses[_uuid].author, courses[_uuid].price, courses[_uuid].infoHash, courses[_uuid].lessonsHash);
    }

    function updateComments(string memory _courseUuid, string memory _commentHash) public {
        courses[_courseUuid].commentHash = _commentHash;
    }

    function addLesson(string memory _uuid, string memory _courseUuid, string memory _infoHash, string memory _gradesHash, string memory _lessonsHash) public {
        require(courses[_courseUuid].author == msg.sender, "Only the author can add lesson");
        Lesson memory newLesson = Lesson({
            uuid: _uuid,
            gradesHash: _gradesHash,
            infoHash: _infoHash
        });
        lessons[_uuid] = newLesson;
        courses[_courseUuid].lessonsHash = _lessonsHash;
    }

    function updateLesson(string memory _courseUuid, string memory _uuid, string memory _infoHash) public {
        require(courses[_courseUuid].author == msg.sender, "Only the author can update lesson");
        lessons[_uuid].infoHash = _infoHash;
    }

    function deleteLesson(string memory _courseUuid, string memory _uuid , string memory _lessonsHash) public {
        delete lessons[_uuid];
        courses[_courseUuid].lessonsHash = _lessonsHash;
    }

    function getLesson(string memory _uuid) public view returns (Lesson memory) {
        return lessons[_uuid];
    }

    function addGrade(string memory _uuid, string memory _lessonUuid, address _student, uint _grade, string memory _gradesHash) public {
        Grade memory newGrade = Grade({
            uuid: _uuid,
            student: _student,
            grade: _grade
        });
        grades[_uuid] = newGrade;
        lessons[_lessonUuid].gradesHash = _gradesHash;
    }

    function updateGrades(string memory _uuid, address _student, uint _grade) public {
        grades[_uuid].student = _student;
        grades[_uuid].grade = _grade;
    }

    function getGrade(string memory _lessonUuid) public view returns (uint) {
        return grades[_lessonUuid].grade;
    }

    function isStudent(string memory _courseUuid) public view returns (bool) {
        return indexOf(studentCourses[msg.sender], _courseUuid) != -1;
    }

    function buyCourse(string memory _courseUuid) public payable {
        require(msg.value == courses[_courseUuid].price, "Not enough Ether provided");
        require(indexOf(studentCourses[msg.sender], _courseUuid) == -1, "Already bought this course");
        payments[courses[_courseUuid].author] += msg.value;
        studentCourses[msg.sender].push(_courseUuid);
    }

    function withdrawFunds(string memory _courseUuid) public {
        require(courses[_courseUuid].author == msg.sender, "Only the author can withdraw funds");
        payable(courses[_courseUuid].author).transfer(payments[msg.sender]);
        payments[courses[_courseUuid].author] = 0;
    }
}