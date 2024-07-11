/*

Apex Class : CodingAnswerController

*/

@isTest
public class CodingAnswerControllerTest {
    @testSetUp
    static void CodingAnswerControllertestSetup() {
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

        Contact candidate = new Contact();
        candidate.LastName = 'test1';
        candidate.Gender__c = 'Male';
        candidate.Branch__c = 'EEE';
        candidate.Coding_Round_Status__c = 'Completed';
        candidate.Coding_Round_Reviewer__c = newUser.Id;
        candidate.Exam_Start_Date__c = system.Today(); 
        insert candidate;

        List<Coding_Round_2_Question__c> codingQuestions = new List<Coding_Round_2_Question__c>();
        
        Coding_Round_2_Question__c codingques1 = new Coding_Round_2_Question__c();
        codingques1.Category__c = 'Java';
        codingques1.Question__c = 'Write a Program to check whether a number is prime or not.';
        codingQuestions.add(codingques1);

        Coding_Round_2_Question__c codingques2 = new Coding_Round_2_Question__c();
        codingques2.Category__c = 'C';
        codingques2.Question__c = 'Write a program to calculate Compound Interest.';
        codingQuestions.add(codingques2);

        Coding_Round_2_Question__c codingques3 = new Coding_Round_2_Question__c();
        codingques3.Category__c = 'Java';
        codingques3.Question__c = 'Write a program to Factorial of a Number.';
        codingQuestions.add(codingques3);

        Coding_Round_2_Question__c codingques4 = new Coding_Round_2_Question__c();
        codingques4.Category__c = 'Java';
        codingques4.Question__c = 'Write a Program to reverse a number.';
        codingQuestions.add(codingques4);

        insert codingQuestions;

        List<Candidate_Coding_Answer__c> codingAnswers = new List<Candidate_Coding_Answer__c>();
        
        Candidate_Coding_Answer__c codingAns1 = new Candidate_Coding_Answer__c();
        codingAns1.CandidateId__c = candidate.Id;
        codingAns1.Coding_Round_2_Question__c = codingQuestions[0].Id;
        codingAns1.Rating__c = '';
        codingAns1.Response__c = 'answer 1';
        codingAns1.Status__c = 'Not Attempted';
        codingAnswers.add(codingAns1);

        Candidate_Coding_Answer__c codingAns2 = new Candidate_Coding_Answer__c();
        codingAns2.CandidateId__c = candidate.Id;
        codingAns2.Coding_Round_2_Question__c = codingQuestions[1].Id;
        codingAns2.Rating__c = '1';
        codingAns2.Response__c = 'answer 2';
        codingAns2.Status__c = 'Not Attempted';
        codingAnswers.add(codingAns2);

        Candidate_Coding_Answer__c codingAns3 = new Candidate_Coding_Answer__c();
        codingAns3.CandidateId__c = candidate.Id;
        codingAns3.Coding_Round_2_Question__c = codingQuestions[2].Id;
        codingAns3.Rating__c = '2';
        codingAns3.Response__c = 'answer 3';
        codingAns3.Status__c = 'Not Attempted';
        codingAnswers.add(codingAns3);

        insert codingAnswers;
    }
     @isTest
    static void CodingAnswerControllerTestMethod () {
        Contact candidate = [SELECT Id, Coding_Round_Reviewer__c from Contact limit 1];
        List<Coding_Round_2_Question__c> codingQuestions= [SELECT Id, Question__c, Category__c FROM  Coding_Round_2_Question__c];
        List<Candidate_Coding_Answer__c> codingAnswers = [SELECT CandidateId__c, Rating__c, Response__c,
                                                          Coding_Round_2_Question__c, Status__c FROM Candidate_Coding_Answer__c];
        CodingAnswerController.shuffleCodingQuestions(codingQuestions,3);
        CodingAnswerController.generateCodingQuestions('Java');
        CodingAnswerController.insertCodingQuestions(codingQuestions, candidate.Id);
        CodingAnswerController.getCandidateCodingRecords(candidate.Id);
        CodingAnswerController.storeCodingRoundStatus('Selected', candidate.Id);
        CodingAnswerController.getCandidateData(candidate.Id);
        
        List<Map<String, String>> info = new List<Map<String, String>>();
        for (Integer i = 0; i < 3; i++) {
             Map<String, String> recordMap = new Map<String, String>{
                'CArecordId'=> String.valueOf(codingAnswers[i].Id),
                'CandidateId' => String.valueOf(candidate.Id),
                'id'=> String.valueOf(codingAnswers[i].Coding_Round_2_Question__c),
                'response'=> String.valueOf(codingAnswers[i].Response__c),
                'status'=> String.valueOf(codingAnswers[i].Status__c),
                'comments' => 'commentss',
                'reviewedby'=> String.valueOf(candidate.Coding_Round_Reviewer__c),
                'rating'=> String.valueOf(codingAnswers[i].Rating__c)
            };
            info.add(recordMap);
            
        }
        CodingAnswerController.storeCodingInformation(info);
    }
}