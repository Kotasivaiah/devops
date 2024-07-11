/*

Apex class: CodingReviewController

*/

@isTest
public class CodingReviewControllerTest {
    @testSetUp
    static void CodingReviewControllertestSetup() {
        Profile standardPlatformUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        
        User newUser = new User(
            FirstName = 'test',
            LastName = 'test1',
            Username = 'test1.doe@example.com',
            Email = 'test1.doe@example.com',
            Alias = 'ttes',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardPlatformUserProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;

        List<Contact> candidates = new List<Contact>();

        Contact candidate1 = new Contact();
        candidate1.LastName = 'test1';
        candidate1.Gender__c = 'Male';
        candidate1.Branch__c = 'EEE';
        candidate1.Post_Graduate_Branch__c = 'MCA';
        candidate1.Written_Test_Status__c = 'Selected';
        candidate1.Coding_Round_Status__c = 'Completed';
        candidate1.Coding_Round_Reviewer__c = newUser.Id;
        candidate1.Exam_Start_Date__c = system.Today(); 
        candidates.add(candidate1);

        Contact candidate2 = new Contact();
        candidate2.LastName = 'test2';
        candidate2.Gender__c = 'Female';
        candidate2.Post_Graduate_Branch__c = 'Other';
        candidate2.Other_PG_Branch__c = 'MCAA';
        candidate2.Written_Test_Status__c = 'Selected';
        candidate2.Coding_Round_Status__c = 'Selected';
        candidate2.Coding_Round_Reviewer__c = newUser.Id;
        candidate2.Exam_Start_Date__c = system.Today(); 
        candidates.add(candidate2);

        Contact candidate3 = new Contact();
        candidate3.LastName = 'test3';
        candidate3.Gender__c = 'Male';
        candidate3.Branch__c = 'Other';
        candidate3.Other_Graduation_Branch__c = 'AIML';
        candidate3.Written_Test_Status__c = 'Selected';
        candidate3.Coding_Round_Status__c = 'On Hold';
        candidate3.Coding_Round_Reviewer__c = newUser.Id;
        candidate3.Exam_Start_Date__c = system.Today(); 
        candidates.add(candidate3);

        Contact candidate = new Contact();
        candidate.LastName = 'test4';
        candidate.Gender__c = 'Female';
        candidate.Branch__c = 'CSE';
        candidate.Written_Test_Status__c = 'Selected';
        candidate.Coding_Round_Status__c = 'Rejected';
        candidate.Coding_Round_Reviewer__c = newUser.Id;
        candidate.Exam_Start_Date__c = system.Today(); 
        candidates.add(candidate);

        insert candidates;
    }
    @isTest
    static void CodingReviewControllerTestMethod () {
        User newUser = [SELECT Id FROM User limit 1];
        List<Contact> candidates = [SELECT Id, LastName FROM Contact];
        CodingReviewController.getCandidateCompleteddata();
        CodingReviewController.updateCodingReviewer(candidates[0].Id,newUser.Id);
        CodingReviewController.updateTechnicalReviewer(candidates[0].Id, newUser.Id);
    }
}