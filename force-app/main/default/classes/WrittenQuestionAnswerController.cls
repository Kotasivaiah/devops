/*
Description		:	
Test class		:	
*/

public without sharing class WrittenQuestionAnswerController {
    
    //
    public static List<Written_Round_1_Question__c> getwrittenQuestions(String category) {
        
        List<Written_Round_1_Question__c> allQuestions = new List<Written_Round_1_Question__c>();
        List<Written_Round_1_Question__c> allTechnicalQuestions = new List<Written_Round_1_Question__c>();
        List<Written_Round_1_Question__c> allCQuestions = new List<Written_Round_1_Question__c>();
        List<Written_Round_1_Question__c> allJavaQuestions = new List<Written_Round_1_Question__c>();
        
        if (category == 'C & Java') {
            allCQuestions = [SELECT Question__c, Category__c, Type__c 
                             FROM Written_Round_1_Question__c 
                             WHERE Type__c = 'Technical' AND Category__c = 'C'];
            allJavaQuestions = [SELECT Question__c, Category__c, Type__c 
                                FROM Written_Round_1_Question__c 
                                WHERE Type__c = 'Technical' AND  Category__c = 'Java'];            
        } else {
            allTechnicalQuestions = [SELECT Question__c, Category__c, Type__c 
                                     FROM Written_Round_1_Question__c 
                                     WHERE Type__c = 'Technical' AND Category__c =: category];
        }               
        
        List<Written_Round_1_Question__c> allAptitudeQuestions = [SELECT Question__c, Category__c ,Type__c 
                                                                  FROM Written_Round_1_Question__c 
                                                                  WHERE Type__c = 'Aptitude'];
        if (category == 'C & Java') {
            allQuestions.addAll(shuffleTechnicalQuestions(allCQuestions, 5));
            allQuestions.addAll(shuffleTechnicalQuestions(allJavaQuestions, 5));
        } else {
            allQuestions.addAll(shuffleTechnicalQuestions(allTechnicalQuestions, 10));
        }        
        allQuestions.addAll(shuffleWrittenQuestions(allAptitudeQuestions, 10));
        
        return allQuestions;
    }
    
    // 
    private static List<Written_Round_1_Question__c> shuffleWrittenQuestions(List<Written_Round_1_Question__c> originalList, Integer n) {
        List<Written_Round_1_Question__c> shuffledList = new List<Written_Round_1_Question__c>();
        if (originalList.size() <= n) {
            return originalList;
        }
        
        // Separate questions by category
        Map<String, List<Written_Round_1_Question__c>> categoryMap = new Map<String, List<Written_Round_1_Question__c>>();
        for (Written_Round_1_Question__c question : originalList) {
            if (!categoryMap.containsKey(question.Category__c)) {
                categoryMap.put(question.Category__c, new List<Written_Round_1_Question__c>());
            }
            categoryMap.get(question.Category__c).add(question);
        }
        
        Set<String> usedCategories = new Set<String>();
        
        while (shuffledList.size() < n) {
            List<String> availableCategories = new List<String>();
            for (String category : categoryMap.keySet()) {
                if (categoryMap.get(category).isEmpty()) {
                    continue;
                }
                if (!usedCategories.contains(category)) {
                    availableCategories.add(category);
                }
            }
            
            // If all categories are used, reset the usedCategories set
            if (availableCategories.isEmpty()) {
                usedCategories.clear();
                for (String category : categoryMap.keySet()) {
                    if (!categoryMap.get(category).isEmpty()) {
                        availableCategories.add(category);
                    }
                }
            }
            
            // Pick a random category from available categories
            Integer categoryIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), availableCategories.size());
            String selectedCategory = availableCategories[categoryIndex];
            List<Written_Round_1_Question__c> questionsInCategory = categoryMap.get(selectedCategory);
            
            // Pick a random question from the selected category
            Integer questionIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), questionsInCategory.size());
            shuffledList.add(questionsInCategory.remove(questionIndex));
            
            // Mark the category as used
            usedCategories.add(selectedCategory);
        }
        
        return shuffledList;
    }
    
    // 
    private static List<Written_Round_1_Question__c> shuffleTechnicalQuestions(List<Written_Round_1_Question__c> originalList, Integer n) {
        List<Written_Round_1_Question__c> shuffledList = new List<Written_Round_1_Question__c>();
        if (originalList.size() <= n) {
            return originalList;
        }
        
        while (shuffledList.size() < n) {
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), originalList.size());
            shuffledList.add(originalList.remove(index));
        }
        return shuffledList;
    }
    
    // 
    public static String insertWrittenQuestions(List<Written_Round_1_Question__c> info,String candidateId) {        
        List<Candidate_Written_Answer__c> CWrecords = new List<Candidate_Written_Answer__c>();
        
        for (Written_Round_1_Question__c eachrecord : info) {
            Candidate_Written_Answer__c CWrecord = new Candidate_Written_Answer__c();
            CWrecord.CandidateId__c = candidateId;
            CWrecord.Written_Round_1_Question__c = eachrecord.Id;
            CWrecord.Response__c = '';
            CWrecords.add(CWrecord);
        }
        
        try {
            insert CWrecords;
            return 'success';
        } catch(Exception e) {
            System.debug('e.getMessage()::' + e.getMessage());
            return e.getMessage();
        }
    }
    
}