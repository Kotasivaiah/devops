@isTest
public class CodingQuestionnaireControllerTest {
  @testSetup
    static void CodingQuestionnaireControllerTestsetup() {
        // Setup any necessary test data here, if required.
        Contact candidate = new Contact(LastName = 'test1',
                                        Gender__c = 'Male',
                                        Written_Test_Status__c = 'Selected',
                                        Coding_Round_Status__c = 'Completed',
                                        Sec_Consumed__c = 2,
                                        Start_Test_Time__c = datetime.now().addSeconds(-40).time(),
										End_Test_Time__c = datetime.now().addSeconds(-20).time(),
                                        Exam_Start_Date__c = system.Today());
        insert candidate;
        
        List<Coding_Round_2_Question__c> codingQuestions = new List<Coding_Round_2_Question__c>();
        
        Coding_Round_2_Question__c codingques1 = new Coding_Round_2_Question__c();
        codingques1.Category__c = 'C';
        codingques1.Question__c = 'Write a Program to check whether a number is prime or not.';
        codingQuestions.add(codingques1);

        Coding_Round_2_Question__c codingques2 = new Coding_Round_2_Question__c();
        codingques2.Category__c = 'C';
        codingques2.Question__c = 'Write a program to calculate Compound Interest.';
        codingQuestions.add(codingques2);

        Coding_Round_2_Question__c codingques3 = new Coding_Round_2_Question__c();
        codingques3.Category__c = 'C';
        codingques3.Question__c = 'Write a program to Factorial of a Number.';
        codingQuestions.add(codingques3);
        
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
    static void CodingQuestionnaireControllerTestMethod() {
        Test.startTest();
            Contact candidate = [SELECT Id from Contact limit 1];
        	List<Candidate_Coding_Answer__c> writtenAnswers = [SELECT Id,CandidateId__c,Response__c, Status__c, 
                                                               Rating__c, Coding_Round_2_Question__c 
                                                               FROM Candidate_Coding_Answer__c 
                                                               WHERE CandidateId__c =: candidate.Id];
            PageReference testPageRef = Page.CodingQuestionnaire;
        	Test.setCurrentPage(testPageRef);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id)[1]);
        	CodingQuestionnaireController codeReviewPage = new CodingQuestionnaireController();
        
        	PageReference testPageRef1 = Page.CodingQuestionnaire;
        	Test.setCurrentPage(testPageRef1);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id + '#' + 'true')[1]);
        	CodingQuestionnaireController.updateStatus(candidate.Id);
        	CodingQuestionnaireController codeReviewPage1 = new CodingQuestionnaireController();
        	
        	codeReviewPage1.saveData();
        Test.stopTest();       
    }
}