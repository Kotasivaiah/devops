/*
Apex class		:	ReviewerAssignmentHelper
*/

@isTest
public class ReviewerAssignmentHelperTest {
    
    @testSetUp
    static void ReviewerAssignmentHelperTestSetup () {
        Profile standardPlatformUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        
        List<User> newUsers = new List<User>();
        newUsers.add(new User(
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
        ));
        
        newUsers.add(new User(
            FirstName = 'test',
            LastName = 'Smith',
            Username = 'test2.smith@example.com',
            Email = 'test2.smith@example.com',
            Alias = 'tsmith',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardPlatformUserProfile.Id,
            LanguageLocaleKey = 'en_US'
        ));
        
        newUsers.add(new User(
            FirstName = 'test3',
            LastName = 'Johnson',
            Username = 'test3.johnson@example.com',
            Email = 'test3.johnson@example.com',
            Alias = 'tjohnson',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardPlatformUserProfile.Id,
            LanguageLocaleKey = 'en_US'
        ));
        
        insert newUsers;
        
        List<Contact> candidates = new List<Contact>();
        
        Contact codingCandidate = new Contact();
        codingCandidate.LastName = 'test1';
        codingCandidate.Gender__c = 'Male';
        codingCandidate.Branch__c = 'EEE';
        codingCandidate.Exam_Start_Date__c = system.Today();
        codingCandidate.Coding_Round_Status__c = 'Completed';
        codingCandidate.Written_Test_Status__c = 'Selected';
        codingCandidate.Post_Graduate_Branch__c = 'Other';
        codingCandidate.Other_PG_Branch__c = 'test branch';
        candidates.add(codingCandidate);
        
        Contact codingCandidate1 = new Contact();
        codingCandidate1.LastName = 'test3';
        codingCandidate1.Gender__c = 'Male';
        codingCandidate1.Branch__c = 'Other';
        codingCandidate1.Other_Graduation_Branch__c = 'test branch';
        codingCandidate1.Exam_Start_Date__c = system.Today();
        codingCandidate.Written_Test_Status__c = 'Selected';
        codingCandidate1.Coding_Round_Status__c = 'Completed';
        candidates.add(codingCandidate1);
        
        Contact codingCandidate2 = new Contact();
        codingCandidate2.LastName = 'test4';
        codingCandidate2.Gender__c = 'Male';
        codingCandidate2.Branch__c = 'Other';
        codingCandidate2.Other_Graduation_Branch__c = 'test branch';
        codingCandidate2.Exam_Start_Date__c = system.Today();
        codingCandidate2.Written_Test_Status__c = 'Selected';
        codingCandidate2.Coding_Round_Status__c = 'Completed';
        candidates.add(codingCandidate2);
        
        Contact technicalCandidate = new Contact();
        technicalCandidate.LastName = 'test5';
        technicalCandidate.Gender__c = 'Male';
        technicalCandidate.Branch__c = 'EEE';
        technicalCandidate.Exam_Start_Date__c = system.Today();
        codingCandidate.Written_Test_Status__c = 'Selected';
        technicalCandidate.Coding_Round_Status__c = 'Selected';
        candidates.add(technicalCandidate);
        
        Contact technicalCandidate1 = new Contact();
        technicalCandidate1.LastName = 'test6';
        technicalCandidate1.Gender__c = 'Male';
        technicalCandidate1.Branch__c = 'EEE';
        technicalCandidate1.Exam_Start_Date__c = system.Today();
        codingCandidate1.Written_Test_Status__c = 'Selected';
        technicalCandidate1.Coding_Round_Status__c = 'Selected';
        candidates.add(technicalCandidate1);
        
        Contact technicalCandidate2 = new Contact();
        technicalCandidate2.LastName = 'test2';
        technicalCandidate2.Gender__c = 'Male';
        technicalCandidate2.Branch__c = 'EEE';
        technicalCandidate2.Exam_Start_Date__c = system.Today();
        codingCandidate2.Written_Test_Status__c = 'Selected';
        technicalCandidate2.Coding_Round_Status__c = 'Selected';
        candidates.add(technicalCandidate2);
        
        insert candidates;
    }
    
    @isTest
    static void ReviewerAssignmentHelperTestMethod () {
        List<Id> members = new List<Id>();
        
        Test.startTest();
        
            for (User u : ReviewerAssignmentHelper.getPanelMembers()) {
                members.add(u.Id);
            }
            ReviewerAssignmentHelper.getCandidateData();
            
            List<Contact> candidateList = [SELECT Id, Exam_Start_Date__c, Written_Test_Status__c, Coding_Round_Reviewer__c,
                                           Coding_Round_Status__c, Technical_Round_Status__c,Tech_Round_Interviewer__c
                                          FROM Contact];
            
            ReviewerAssignmentHelper.assignPanelMembers(members, 'CodeReview');
            
            List<Map<String, String>> candidates = new List<Map<String, String>>();
            
            for (Contact con : candidateList) {
                Map<String, String> contactMap  = new Map<String, String>();
                contactMap.put('id', con.Id);
                contactMap.put('writtenRoundStatus', con.Written_Test_Status__c);
                contactMap.put('codingRoundStatus', con.Coding_Round_Status__c);
                contactMap.put('technicalRoundReviewerId', con.Tech_Round_Interviewer__c);
                contactMap.put('codingRoundReiewerId', con.Coding_Round_Reviewer__c);
                candidates.add(contactMap);
                if (con.Coding_Round_Status__c == 'Completed') {
                    con.Coding_Round_Status__c = 'Selected';
                }
            }
        	update candidateList;
        
        	ReviewerAssignmentHelper.assignPanelMembers(members, 'TechnicalRound');
            ReviewerAssignmentHelper.assignReviewers(candidates);
            
        Test.stopTest();
    }
}