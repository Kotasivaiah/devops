/*
Description         :   To store the candidate data from TechnicalRound Tab
Test class name     :   TechnicalRound3ControllerTest
LWC                 :   ep_TechnicalRound3
*/

public without sharing class TechnicalRound3Controller {   
    
    // 
    @AuraEnabled
    public static String insertCTRecords(List<Map<String,String>> candidateQuestionInfo, String review, String candidateId, 
                                         List<Map<String,String>> ratings, String technicalRoundStatus) 
    {
        Integer technicalRoundMarks = 0;
        List<Candidate_Technical_Answer__c> CTrecords = new List<Candidate_Technical_Answer__c>();   
        
        for (Map<String,String> eachrecord : candidateQuestionInfo) {
            Candidate_Technical_Answer__c CTrecord = new Candidate_Technical_Answer__c();
            CTrecord.CandidateId__c = eachrecord.get('CandidateId');
            CTrecord.Technical_Round_3_Question__c = eachrecord.get('Id');
            CTrecord.Response__c = eachrecord.get('Response');            
            CTrecords.add(CTrecord);
        }
        
        Contact candidateRecord = [SELECT Id, TR_Comments__c, Technical_Round_Status__c, Technical_Round_Marks__c, Communication_Skills_Tr__c, 
                                   Problem_Solving_Skills_Tr__c, Technical_Skills_Tr__c, Learning_Skills_Tr__c, Confidence_Level_Tr__c, 
                                   Attitude_and_Professionalism_Tr__c 
                                   FROM Contact 
                                   WHERE Id =: candidateId LIMIT 1];
        candidateRecord.TR_Comments__c = review;
        candidateRecord.Technical_Round_Status__c = technicalRoundStatus;
            for (Map<String, String> ratingInfo : ratings) {
                if(ratingInfo.get('value') != null){
                    String fieldApiName = ratingInfo.get('apiName');
                    String fieldValue = ratingInfo.get('value');
                    technicalRoundMarks += Integer.valueOf(fieldValue); 
                    // Use dynamic field assignment
                    candidateRecord.put(fieldApiName, fieldValue);
                }
            }
        candidateRecord.Technical_Round_Marks__c = (Decimal.valueOf(technicalRoundMarks) / Decimal.valueOf(6)).setScale(2);
        
        try {
            insert CTrecords;
            update candidateRecord;
            
            return 'success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }   
    
    // 
    @AuraEnabled
    public static Map<String, List<Technical_Round_3_Question__c>> getTechnicalQuestions(List<Map<String, String>> language) {
        Map<String, List<Technical_Round_3_Question__c>> labelQuestionMap = new Map<String, List<Technical_Round_3_Question__c>>();                
        Set<String> languageSet = new Set<String>();
        
        for (Map<String, String> eachlanguage : language) {
            languageSet.add(eachlanguage.get('label'));
        }
        
        List<Technical_Round_3_Question__c> questions = [SELECT Id, Question__c, Language__c, Question_Difficulty__c 
                                                         FROM Technical_Round_3_Question__c 
                                                         WHERE Language__c IN :languageSet];
        
        Map<String, List<Technical_Round_3_Question__c>> languageWithQuestions = new Map<String, List<Technical_Round_3_Question__c>>();
        for (Technical_Round_3_Question__c question : questions) {
            if (!languageWithQuestions.containsKey(question.Language__c)) {
                languageWithQuestions.put(question.Language__c, new List<Technical_Round_3_Question__c>());
            }
            languageWithQuestions.get(question.Language__c).add(question);
        }
        
        for (String category : languageSet) {
            List<Technical_Round_3_Question__c> allQuestionsForLanguage = languageWithQuestions.get(category);
            if (allQuestionsForLanguage != null) {
                labelQuestionMap.put(category, generateRandomQuestions(allQuestionsForLanguage));
            } else {
                labelQuestionMap.put(category, new List<Technical_Round_3_Question__c>());
            }
        }
        
        return labelQuestionMap;
    }
    
    // 
    public static List<Technical_Round_3_Question__c> generateRandomQuestions(List<Technical_Round_3_Question__c> inputList) {
        List<Technical_Round_3_Question__c> easyQuestions = new List<Technical_Round_3_Question__c>();
        List<Technical_Round_3_Question__c> mediumQuestions = new List<Technical_Round_3_Question__c>();
        List<Technical_Round_3_Question__c> hardQuestions = new List<Technical_Round_3_Question__c>();
        
        // Separate questions by difficulty
        for (Technical_Round_3_Question__c question : inputList) {
            if (question.Question_Difficulty__c == 'Easy') {
                easyQuestions.add(question);
            } else if (question.Question_Difficulty__c == 'Medium') {
                mediumQuestions.add(question);
            } else if (question.Question_Difficulty__c == 'Hard') {
                hardQuestions.add(question);
            }
        }
        
        // Randomly select 5 questions from each difficulty list
        List<Technical_Round_3_Question__c> randomQuestions = new List<Technical_Round_3_Question__c>();
        randomQuestions.addAll(selectRandomQuestions(easyQuestions, 5));
        randomQuestions.addAll(selectRandomQuestions(mediumQuestions, 5));
        randomQuestions.addAll(selectRandomQuestions(hardQuestions, 5));
        
        return randomQuestions;
    }
    
    // 
    private static List<Technical_Round_3_Question__c> selectRandomQuestions(List<Technical_Round_3_Question__c> questions, Integer num) {
        List<Technical_Round_3_Question__c> randomQuestions = new List<Technical_Round_3_Question__c>();        
        if (questions.size() <= num) {
            return questions;
        }
        
        while (randomQuestions.size() < num) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), questions.size());    
            randomQuestions.add(questions.remove(randomIndex));
        }
        
        return randomQuestions;
    }
    
    // 
    @AuraEnabled
    public static List<ExamPortalHelper.technicalReviewWrapper> getTechnicalAnswerData(String candidateId) {        
        List<ExamPortalHelper.technicalReviewWrapper> technicalAnswers = new List<ExamPortalHelper.technicalReviewWrapper> ();
        
        List<Candidate_Technical_Answer__c> CTrecords = [SELECT Id, CandidateId__c,
                                                         Response__c, Technical_Round_3_Question__c, 
                                                         Technical_Round_3_Question__r.Language__c, Technical_Round_3_Question__r.Question__c, 
                                                         Technical_Round_3_Question__r.Question_Difficulty__c 
                                                         FROM Candidate_Technical_Answer__c 
                                                         WHERE CandidateId__c = :candidateId];
        for (Candidate_Technical_Answer__c eachAnswrer : CTrecords) {
            ExamPortalHelper.technicalReviewWrapper technicalAnswer = new ExamPortalHelper.technicalReviewWrapper ();
            technicalAnswer.id = eachAnswrer.Id ;
            technicalAnswer.candidateId = eachAnswrer.CandidateId__c ;
            technicalAnswer.response = eachAnswrer.Response__c ;
            technicalAnswer.technicalQuestion = eachAnswrer.Technical_Round_3_Question__r.Question__c ;
            technicalAnswer.technicalLanguage = eachAnswrer.Technical_Round_3_Question__r.Language__c ;
            technicalAnswer.difficultyLevel = eachAnswrer.Technical_Round_3_Question__r.Question_Difficulty__c ;
            technicalAnswers.add(technicalAnswer);
        }
        
        return technicalAnswers;
    }
    
    // 
    @AuraEnabled
    public static Contact getCandidateData(String candidateId){
        Contact contact = [SELECT Id, Coding_Round_Status__c,Technical_Round_Status__c, Communication_Skills_Tr__c, TR_Question_Comments__c, 
                           TR_Comments__c, Problem_Solving_Skills_Tr__c, Technical_Skills_Tr__c, Learning_Skills_Tr__c, Confidence_Level_Tr__c, 
                           Attitude_and_Professionalism_Tr__c ,Technical_Round_Marks__c, Tech_Round_Interviewer__c,Tech_Round_Interviewer__r.Name,
                           Coding_Round_Reviewer__c
                           FROM Contact 
                           WHERE Id = :candidateId LIMIT 1];
        
        return contact;
    }
    
}