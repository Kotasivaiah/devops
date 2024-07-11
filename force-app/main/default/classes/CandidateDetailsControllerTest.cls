@isTest
public class CandidateDetailsControllerTest {

    @testSetup
    static void CandidateDetailsControllerTestsetup() {
        // Setup any necessary test data here, if required.
        Contact candidate = new Contact(LastName = 'test1',
                                        Gender__c = 'Male',
                                        Exam_Start_Date__c = system.Today());
        insert candidate;
    }

    @isTest
    static void CandidateDetailsControllerTestMethod() {
        Test.startTest();
            Contact candidate = [SELECT Id from Contact limit 1];
            PageReference testPageRef = Page.CandidateDetails;
        	Test.setCurrentPage(testPageRef);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id)[1]);
        	CandidateDetailsController candidateDetailPage = new CandidateDetailsController();
        
        	PageReference testPageRef1 = Page.CandidateDetails;
        	Test.setCurrentPage(testPageRef1);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id)[1]);
        	CandidateDetailsController candDetailPage = new CandidateDetailsController();
        Test.stopTest();
    }
}