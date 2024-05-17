const hre = require('hardhat');

async function main() {
    const CertificateContract = await hre.ethers.getContractFactory('CertificateStorage');
    const CertificateStorage = await CertificateContract.deploy();
    await CertificateStorage.waitForDeployment();
    console.log('CertificateStorage deployed to:', await CertificateStorage.getAddress());

    const CourseContract = await hre.ethers.getContractFactory('CourseStorage');
    const CourseStorage = await CourseContract.deploy();
    await CourseStorage.waitForDeployment();
    console.log('CourseStorage deployed to:', await CourseStorage.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });