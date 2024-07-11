/*
Description			:	To generate questions for CodingTest and store the answers of candidates and change status after review.
Test class name		:	
LWC					:	ep_codingTest
*/

public without sharing class CodingAnswerController {
    
    // To shuffle the entire list of questions and return desired number of questions  
    public static List<Coding_Round_2_Question__c> shuffleCodingQuestions(List<Coding_Round_2_Question__c> originalList, Integer n) {
        List<Coding_Round_2_Question__c> shuffledList = new List<Coding_Round_2_Question__c>();
        
        if (originalList.size() <= n) {
            return originalList;
        }
        
        while (shuffledList.size() < n) {
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), originalList.size());
            shuffledList.add(originalList.remove(index));
        }
        
        return shuffledList;
    }
    
    // To generate 3 Coding Round Questions
    public static List<Coding_Round_2_Question__c> generateCodingQuestions(String category) {
        List<Coding_Round_2_Question__c> allQuestions = new List<Coding_Round_2_Question__c>();
        
        List<Coding_Round_2_Question__c> allcodingQuestions = [SELECT Question__c, Category__c 
                                                               FROM Coding_Round_2_Question__c 
                                                               WHERE Category__c = :category];
        allQuestions.addAll(shuffleCodingQuestions(allcodingQuestions, 3));
        
        return allQuestions;
    }
    
    // To insert Coding Round Question Records for given CandidateId    
    public static String insertCodingQuestions(List<Coding_Round_2_Question__c> info,String candidateId) {
        List<Candidate_Coding_Answer__c> CArecords = new List<Candidate_Coding_Answer__c>();
        
        for (Coding_Round_2_Question__c eachrecord : info) {
            Candidate_Coding_Answer__c CArecord = new Candidate_Coding_Answer__c();
            CArecord.CandidateId__c = candidateId;
            CArecord.Coding_Round_2_Question__c = eachrecord.Id;
            CArecord.Response__c = '';
            CArecords.add(CArecord);
        }
        
        try {
            insert CArecords;
            return 'success';
        } catch (Exception e) {
            System.debug('CodingAnswerController -> insertCodingQuestions :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    // To fetch available codingRound Records for given candidateId
    @AuraEnabled
    public static List<Candidate_Coding_Answer__c> getCandidateCodingRecords(String candidateId) {
        List<Candidate_Coding_Answer__c> codingAnswerList = [SELECT Id, Coding_Round_2_Question__r.Question__c, Status__c, Comments__c, 
                                                             Rating__c, Coding_Round_2_Question__r.Category__c, Response__c ,
                                                             CandidateId__r.Coding_Round_Reviewer__r.Name
                                                             FROM Candidate_Coding_Answer__c 
                                                             WHERE CandidateId__c = :candidateId];
        if (!codingAnswerList.isEmpty()) {
            return codingAnswerList;
        } else {
            return null;
        }
    }
    
    // Store the coding Test info of candidate
    @AuraEnabled
    public static String storeCodingInformation(List<Map<String, String>> info) {
        system.debug(info);
        Integer codingRoundMarks = 0;
        String candidateId;
        List<Candidate_Coding_Answer__c> CArecords = new List<Candidate_Coding_Answer__c>();
        System.debug('info:::'+info);
        
        for(Map<String, String> eachrecord : info) {
            Candidate_Coding_Answer__c CArecord = new Candidate_Coding_Answer__c();
            CArecord.Id = eachrecord.get('CArecordId');
            CArecord.CandidateId__c = eachrecord.get('CandidateId');
            candidateId = CArecord.CandidateId__c;
            CArecord.Coding_Round_2_Question__c = eachrecord.get('id');
            CArecord.Response__c = eachrecord.get('response');
            CArecord.Status__c = eachrecord.get('status');
            CArecord.Comments__c = eachrecord.get('comments');
            CARecord.Rating__c = eachrecord.get('rating');
            codingRoundMarks += (CARecord.Rating__c == null ? 0 : Integer.valueOf(CARecord.Rating__c));
            CArecords.add(CArecord);
        }
        
        Contact contact = [SELECT Id, Coding_Round_Marks__c 
                           FROM Contact 
                           WHERE Id = :candidateId];
        contact.Coding_Round_Marks__c = (Decimal.valueOf(codingRoundMarks) / Decimal.valueOf(3)).setScale(2);
        try {
            System.debug('CArecords:::'+CArecords);
            update CArecords;
            update contact;
            return 'success';
        } catch (Exception e) {
            System.debug('CodingAnswerController -> storeCodingInformation :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    // Store CodingRound status after Review
    @AuraEnabled
    public static String storeCodingRoundStatus(String status, String candidateId) {
        Contact contact = [SELECT Id, Coding_Round_Status__c 
                           FROM Contact 
                           WHERE Id = :candidateId LIMIT 1];
        contact.Coding_Round_Status__c = status;
        try {
            update contact;
            return 'success';
        } catch(Exception e) {
            System.debug('CodingAnswerController -> storeCodingRoundRating :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    // Fetch candidate data
    @AuraEnabled
    public static Contact getCandidateData(String candidateId) {
        
        Contact contact = [SELECT Id, Coding_Round_Reviewer__c, Coding_Round_Status__c, Technical_Round_Status__c 
                           FROM Contact 
                           WHERE Id = :candidateId];
        return contact;
    }

    @AuraEnabled
    public static User getUserData(String userId){
        User user = [SELECT Recruiting_Manager__c FROM User WHERE Id =: userId];
        return user;
    }
}