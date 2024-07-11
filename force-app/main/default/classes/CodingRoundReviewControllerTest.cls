@isTest
public class CodingRoundReviewControllerTest {

    @testSetup
    static void CodingRoundReviewControllerTestsetup() {
        // Setup any necessary test data here, if required.
        Contact candidate = new Contact(LastName = 'test1',
                                        Gender__c = 'Male',
                                        Written_Test_Status__c = 'Selected',
                                        Coding_Round_Status__c = 'Not Started',
                                        Exam_Start_Date__c = system.Today());
        insert candidate;
    }

    @isTest
    static void CodingRoundReviewControllerTestMethod() {
        Test.startTest();
            Contact candidate = [SELECT Id from Contact limit 1];
            PageReference testPageRef = Page.CodingQuestionnaire;
        	Test.setCurrentPage(testPageRef);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id)[1]);
        	CodingRoundReviewController codeReviewPage = new CodingRoundReviewController();
        
        	PageReference testPageRef1 = Page.CodingQuestionnaire;
        	Test.setCurrentPage(testPageRef1);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id + '#' + 'testString')[1]);
        	CodingRoundReviewController codeReviewPage1 = new CodingRoundReviewController();
        Test.stopTest();
       
    }
}