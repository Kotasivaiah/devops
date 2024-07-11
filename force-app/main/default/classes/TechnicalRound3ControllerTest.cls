/*
Apex class		:	TechnicalRound3Controller
*/

@istest
public class TechnicalRound3ControllerTest {
    
    @istest
    static void testLabelValues() {
        Contact candidate = new contact(LastName = 'test', Exam_Start_Date__c = system.Today(),
                                       TR_Comments__c = '', Technical_Round_Status__c = '', Technical_Round_Marks__c = null, 
                                       Communication_Skills_Tr__c = null, Problem_Solving_Skills_Tr__c = null, Technical_Skills_Tr__c = null, 
                                       Learning_Skills_Tr__c = null, Confidence_Level_Tr__c =null, Attitude_and_Professionalism_Tr__c = null);
        insert candidate;
        
        List<Map<String, String>> languages = new List<Map<String, String>>();
        languages.add(new Map<String, String> { 'label' => 'Java', 'value' => 'Java' });
        languages.add(new Map<String, String> { 'label' => 'C', 'value' => 'C' });
        languages.add(new Map<String, String> { 'label' => 'DBMS', 'value' => 'DBMS' });
        languages.add(new Map<String, String> { 'label' => 'SQL', 'value' => 'SQL' });
        languages.add(new Map<String, String> { 'label' => 'HTML', 'value' => 'HTML' });
        languages.add(new Map<String, String> { 'label' => 'Python', 'value' => 'Python' });
        languages.add(new Map<String, String> { 'label' => 'JavaScript', 'value' => 'JavaScript' });
        
        List<Technical_Round_3_Question__c> technicalQuestions = new List<Technical_Round_3_Question__c>();
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Java1?', Language__c = 'Java', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Java2?', Language__c = 'Java', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Java3?', Language__c = 'Java', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Java4?', Language__c = 'Java', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Java5?', Language__c = 'Java', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Java6?', Language__c = 'Java', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is C?', Language__c = 'C', Question_Difficulty__c = 'Medium'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is DBMS?', Language__c = 'DBMS', Question_Difficulty__c = 'Easy'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is SQL?', Language__c = 'SQL', Question_Difficulty__c = 'Hard'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is HTML?', Language__c = 'HTML', Question_Difficulty__c = 'Medium'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is Python?', Language__c = 'Python', Question_Difficulty__c = 'Easy'));
        technicalQuestions.add(new Technical_Round_3_Question__c(Question__c = 'What is JavaScript?', Language__c = 'JavaScript', Question_Difficulty__c = 'Hard'));
        
        insert technicalQuestions;
        
        List<Candidate_Technical_Answer__c> technicalAnswers = new List<Candidate_Technical_Answer__c>();
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[0].Id)); 
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[1].Id));
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[2].Id));
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[3].Id));
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[4].Id));
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[5].Id));
        technicalAnswers.add(new Candidate_Technical_Answer__c(CandidateId__c = candidate.Id, Response__c = '', Technical_Round_3_Question__c = technicalQuestions[6].Id));
        
        insert technicalAnswers;
        
        List<Map<String, String>> ratings = new List<Map<String,String>>();
        ratings.add(new Map<String, String> {'label'=>'Confidence Level','apiName'=>'Confidence_Level_Tr__c','value'=>'1'});
        ratings.add(new Map<String, String> {'label'=>'Attitude and Professionalism','apiName'=>'Attitude_and_Professionalism_Tr__c','value'=>'3'});
		ratings.add(new Map<String, String> {'label'=>'Learning Skills','apiName'=>'Learning_Skills_Tr__c','value'=>'2'});
		ratings.add(new Map<String, String> {'label'=>'Communication Skills','apiName'=>'Communication_Skills_Tr__c','value'=>'4'});
		ratings.add(new Map<String, String> {'label'=>'Problem Solving Skills','apiName'=>'Problem_Solving_Skills_Tr__c','value'=>'3'});
        ratings.add(new Map<String, String> {'label'=>'Technical Skills','apiName'=>'Technical_Skills_Tr__c','value'=>'5'});
        
        List<Map<String,String>> candidateQuestionInfo = new List<Map<String,String>>();
        candidateQuestionInfo.add(new Map<String, String> {'Id'=> technicalQuestions[0].Id,'Response'=>'Yes','CandidateId'=> candidate.Id});
        candidateQuestionInfo.add(new Map<String, String> {'Id'=> technicalQuestions[1].Id,'Response'=>'No','CandidateId'=> candidate.Id});
        candidateQuestionInfo.add(new Map<String, String> {'Id'=> technicalQuestions[2].Id,'Response'=>'Yes','CandidateId'=> candidate.Id});
        candidateQuestionInfo.add(new Map<String, String> {'Id'=> technicalQuestions[3].Id,'Response'=>'No','CandidateId'=> candidate.Id});
        
        TechnicalRound3Controller.getTechnicalQuestions(languages);
        TechnicalRound3Controller.getTechnicalAnswerData(candidate.Id);
        TechnicalRound3Controller.getCandidateData(candidate.Id);
        TechnicalRound3Controller.insertCTRecords(candidateQuestionInfo, 'Overall Technical Review', candidate.Id, ratings, 'Selected'); 
    }
}