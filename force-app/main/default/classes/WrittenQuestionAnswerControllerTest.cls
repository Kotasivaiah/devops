/*

Apex class : WrittenQuestionAnswerConstroller

*/

@isTest
public class WrittenQuestionAnswerControllerTest {
    @testSetUp
    static void WrittenQuestionAnswerControllerTestsetup() {
        Contact candidate = new Contact();
        candidate.LastName = 'test1';
        candidate.Gender__c = 'Male';
        candidate.Branch__c = 'EEE';
        candidate.Post_Graduate_Branch__c = 'MCA';
        candidate.Exam_Start_Date__c = system.Today(); 

        insert candidate;

        List<Written_Round_1_Question__c> writtenQuestions = new List<Written_Round_1_Question__c>();
        for(Integer i=0; i< 40; i++){
            Written_Round_1_Question__c writtenQues1 = new Written_Round_1_Question__c();
            if(i < 4){
                writtenQues1.Category__c = 'Height and Distance';
            }else if(i >= 4 && i < 8){
                writtenQues1.Category__c = 'Calendar';
            }else if(i >= 8 && i < 13){
                writtenQues1.Category__c = 'Average';
            }else if(i >= 13 && i < 17){
                writtenQues1.Category__c = 'Clock';
            }else if(i >= 17 && i < 20){
                writtenQues1.Category__c = 'Percentage';
            }else if(i >= 20 && i < 30){
                writtenQues1.Category__c = 'C';
            }else if(i >= 30){
                writtenQues1.Category__c = 'Java';
            }
            writtenQues1.Option_1__c = '1'+i;
            writtenQues1.Option_2__c = '2'+i;
            writtenQues1.Option_3__c = '3'+i;
            writtenQues1.Option_4__c = '4'+i;
            writtenQues1.Question__c = '1+2 = ?'+i;
            if(i < 20){
                writtenQues1.Type__c = 'Aptitude';
            }else{
                writtenQues1.Type__c = 'Technical';
            }
            writtenQuestions.add(writtenQues1);
        }

        insert writtenQuestions;
    }

    @IsTest
    static void WrittenQuestionAnswerControllerTestMethod () {
        Contact candidate = [SELECT Id FROM Contact limit 1];
        WrittenQuestionAnswerController.getwrittenQuestions('C & Java');
        WrittenQuestionAnswerController.insertWrittenQuestions(WrittenQuestionAnswerController.getwrittenQuestions('C & Java'), candidate.Id);
    }
}