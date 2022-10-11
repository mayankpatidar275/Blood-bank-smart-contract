// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract BloodBank{

    address owner;      

    constructor(){
        owner = msg.sender;     //set the owner (who deploys the contract)
    }

    enum PatientType {
        Donor,                  //0
        Receiver                //1
    }

    struct BloodTransaction {
        PatientType patientType;
        uint256 time;
        address from;             
        address to;               // Hospital (in case of donor)
    }

    // for each Patient record
    struct Patient  {
        uint256 aadhar;
        string name;
        uint256 age;
        string bloodGroup;
        uint256 contact;
        string homeAddress;
        BloodTransaction[] bT;
    }

    // We will have to fetch all the records at once 
    // Therefore storing it in array and not in map
    Patient[] PatientRecord;

    // Use map (adhar => index)
    // To avoid looping the whole array.
    mapping(uint256 => uint256) PatientRecordIndex;

    // For notifying if function is executed or not
    event Successfull(string message);

    // Register a new Patient
    function newPatient(
        string memory _name,
        uint256 _age,
        string memory _bloodGroup,
        uint256 _contact,
        string memory _homeAddress,
        uint256 _aadhar
    ) external {
        require(msg.sender == owner, "Only admin can register new patient");
        
        uint256 index = PatientRecord.length; // length of array

        PatientRecord.push();
        PatientRecord[index].name = _name;
        PatientRecord[index].age = _age;
        PatientRecord[index].bloodGroup = _bloodGroup;
        PatientRecord[index].contact = _contact;
        PatientRecord[index].homeAddress = _homeAddress;
        PatientRecord[index].aadhar = _aadhar;

        PatientRecordIndex[_aadhar] = index;

        emit Successfull("Patient added successfully");
    }

    // Get specific user data using aadhar (unique)
    function getPatientRecord(uint256 _aadhar) external view returns(Patient memory) {
        uint256 index = PatientRecordIndex[_aadhar];
        return PatientRecord[index];
    }

    // To get all records in one go 
    function getAllRecord() external view returns(Patient[] memory) {
        return PatientRecord;
    }

    // store the blood transaction
    function bloodTransaction(
        uint256 _aadhar,
        PatientType _type,
        address _from,
        address _to
    ) external {
        // check if sender is hospital or not
        require(
            msg.sender == owner,
            "only hospital can update the patient's blood transaction data"
        );

        // get at which index the patient registartion details are saved
        uint256 index = PatientRecordIndex[_aadhar];

        //insert the BloodTransaction in the record
        BloodTransaction memory txObj = BloodTransaction({
            patientType: _type,
            time: block.timestamp,
            from: _from,
            to: _to
        });

        PatientRecord[index].bT.push(txObj);

        // Above statement can simply be done as below
        // PatientRecord[index].bT.push(BloodTransaction(_type, block.timestamp, _from, _to));

        emit Successfull(
            "Patient blood transaction data is updated successfully"
        );

    }
}