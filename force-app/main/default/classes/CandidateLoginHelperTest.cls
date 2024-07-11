/*
Apex Class      :   CandidateLoginHelper, CandidateReportData
*/

@isTest
public class CandidateLoginHelperTest {
    
    @testSetup
    static void candidateData () {
        Map<Object, Object> obj = 
            new Map<Object, Object> {
                'firstName' => 'Kotla',
                    'lastName' => 'Seetha Ramireddy',
                    'dob' => '2002-03-08',
                    'gender' => 'Male',
                    'mobileNumber' => '6303205839',
                    'email' => 'seetharamkotla266@gmailtest.com',
                    'sl' => 'English;Hindi;Telugu;Other',
                    'caddress' => 'APHB Colony, Guntur',
                    'collegeName' => 'Tirumala Engineering College',
                    'gYear' => '2023',
                    'gHallTicketNumber' => '19Ne1a0477',
                    'gPercent' => '65',
                    'interName' => 'Sri Chiatanya Jr College',
                    'interBranch' => 'Other',
                    'interYear' => '2019',
                    'interPercent' => '90',
                    'schoolName' => 'Shivam Merits Public School',
                    'schoolYear' => '2017',
                    'schoolPercent' => '85',
                    'pl' => 'Java;Python;HTML;CSS',
                    'pgName' => 'ANU',
                    'pgBranch' => 'Other',
                    'pgYear' => '2023',
                    'pgHallTicketNumber' => '19ne1a0478',
                    'pgPercent' => '65',
                    'paddress' => 'APHB Colony, Guntur',
                    'otherpgBranch' => 'PG',
                    'otherbranch' => 'Aeronuatical',
                    'otherinterBranch' => 'BiMPC'
                    };
                        CandidateRegistration.registerCandidate(obj);
        
        Contact rejectingCon = new contact();
        rejectingCon.Exam_Start_Date__c = System.today();
        rejectingCon.Written_Test_Status__c = 'Completed';
        rejectingCon.LastName = 'Test1';
        insert rejectingCon;
        
        Account defaultAccount = new Account();
        defaultAccount.Name = System.Label.Default_Account_Name;
        insert defaultAccount;
    }
    
    @isTest
    static void candidateTestMethod() {
        
        Test.startTest();
        
            Lead candidateLead = [SELECT Id, UserName__c FROM Lead LIMIT 1];
        
            CandidateLoginHelper.login('');
            CandidateLoginHelper.login(candidateLead.UserName__c);
            Contact candidate = [SELECT Id, UserName__c FROM Contact WHERE UserName__c = :candidateLead.UserName__c LIMIT 1];
            CandidateLoginHelper.generateQuestions(candidate.Id, 'Java');
            
            CandidateLoginHelper.getCandidateData(candidate.Id);
            CandidateLoginHelper.getCandidateData('');
            
            //CandidateLoginHelper.adminLogin(candidate.UserName__c, System.Label.EP_AdminPassword);
            CandidateReportData.updateStatus(new List<Id> {candidate.Id},
                                             'Written Round Candidate Filter', new List<String>{ 'ramireddy19474@gmail.com'} );
            CandidateLoginHelper.generateQuestions(candidate.Id, 'Java');
            CandidateReportData.updateStatus(new List<Id> {candidate.Id},
                                             'Coding Round Candidate Filter', new List<String>{ 'ramireddy19474@gmail.com'} );
        Test.stopTest();
    }
    
}