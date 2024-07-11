@isTest
public class QuestionnaireControllerTest {
    @testSetup
    static void QuestionnaireControllerTestsetup() {
        // Setup any necessary test data here, if required.
        Contact candidate = new Contact(LastName = 'test1',
                                        Gender__c = 'Male',
                                        Written_Test_Status__c = 'Completed',
                                        Sec_Consumed__c = 2,
                                        Start_Test_Time__c = datetime.now().addSeconds(-40).time(),
										End_Test_Time__c = datetime.now().addSeconds(-20).time(),
                                        Exam_Start_Date__c = system.Today());
        insert candidate;
        
        List<Written_Round_1_Question__c> writtenQuestions = new List<Written_Round_1_Question__c>();
        for(Integer i=0; i< 20; i++){
            Written_Round_1_Question__c writtenQues1 = new Written_Round_1_Question__c();
            if(i < 2){
                writtenQues1.Category__c = 'Height and Distance';
            }else if(i >= 2 && i < 4){
                writtenQues1.Category__c = 'Calendar';
            }else if(i >= 4 && i < 6){
                writtenQues1.Category__c = 'Average';
            }else if(i >= 6 && i < 8){
                writtenQues1.Category__c = 'Clock';
            }else if(i >= 8 && i < 10){
                writtenQues1.Category__c = 'Percentage';
            }else if(i >= 10 && i < 15){
                writtenQues1.Category__c = 'C';
            }else if(i >= 15){
                writtenQues1.Category__c = 'Java';
            }
            writtenQues1.Option_1__c = '1'+i;
            writtenQues1.Option_2__c = '2'+i;
            writtenQues1.Option_3__c = '3'+i;
            writtenQues1.Option_4__c = '4'+i;
            writtenQues1.Answer__c = 'answer'; 
            writtenQues1.Question__c = '1+2 = ?'+i;
            if(i < 10){
                writtenQues1.Type__c = 'Aptitude';
            }else{
                writtenQues1.Type__c = 'Technical';
            }
            writtenQuestions.add(writtenQues1);
        }

        insert writtenQuestions;
 
        List<Candidate_Written_Answer__c> writtenAnswers = new List<Candidate_Written_Answer__c>();
        for(Integer i = 0; i< 20; i++){
        	writtenAnswers.add(new Candidate_Written_Answer__c(CandidateId__c = candidate.Id, Response__c = 'answer', Written_Round_1_Question__c = writtenQuestions[i].Id));//, Written_Round_1_Question__c = ));            
        }
        insert writtenAnswers;
    }

    @isTest
    static void QuestionnaireControllerTestMethod() {
        Test.startTest();
            Contact candidate = [SELECT Id from Contact limit 1];
        	List<Candidate_Written_Answer__c> writtenAnswers = [SELECT Id,CandidateId__c,Response__c, Written_Round_1_Question__c 
                                                                from Candidate_Written_Answer__c where CandidateId__c =: candidate.Id];
            PageReference testPageRef = Page.Questionnaire;
        	Test.setCurrentPage(testPageRef);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id)[1]);
        	QuestionnaireController codeReviewPage = new QuestionnaireController();
        
        	PageReference testPageRef1 = Page.Questionnaire;
        	Test.setCurrentPage(testPageRef1);
            ApexPages.currentPage().getParameters().put('key', ExamPortalHelper.encryptKey(candidate.Id + '#' + 'true')[1]);
        	QuestionnaireController codeReviewPage1 = new QuestionnaireController();
        	QuestionnaireController.updateStatus(candidate.Id);
        	codeReviewPage1.storeMarks(writtenAnswers);
        	codeReviewPage1.saveData();
        Test.stopTest();       
    }
}