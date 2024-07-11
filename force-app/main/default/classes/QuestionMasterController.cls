public class QuestionMasterController {
    public static Map<String, List<Question_Master__c>> selectQuestions() {
         Map<Object,List<String>> dependentToValues = 
                PicklistHelper.getDependentPicklistValues(Question_Master__c.Category__c);
        List<String> aptitude= dependentToValues.get('Aptitude');
        List<String> technical= dependentToValues.get('Technical');
        Map<String, List<Question_Master__c>> selectedQuestions = 
            new Map<String, List<Question_Master__c>>();
        
        selectedQuestions.put('Technical',
            selectQuestionsByType('Technical', dependentToValues.get('Technical')));
        selectedQuestions.put('Aptitude',
            selectQuestionsByType('Aptitude', dependentToValues.get('Aptitude')));
        
        return selectedQuestions;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Question_Master__c>> getQuestions() {
        return selectQuestions();
    }

    // Generic method to select 10 questions by type
    public static List<Question_Master__c> selectQuestionsByType(String type, List<String> categories) {
        List<Question_Master__c> selectedQuestions = new List<Question_Master__c>();
        List<Question_Master__c> remainingQuestions = new List<Question_Master__c>();

        List<Question_Master__c> allQuestions = [
            SELECT Id, Question__c, Option_1__c, 
                Option_2__c, Option_3__c, 
                Option_4__c, Answer__c, 
                Category__c, Type__c
            FROM Question_Master__c 
            WHERE Type__c = :type
        ];
        
        Map<String, List<Question_Master__c>> questionsByCategory = 
                new Map<String, List<Question_Master__c>>();
        
        for (String category : categories) {
            questionsByCategory.put(category, new List<Question_Master__c>());
        }
        
        for (Question_Master__c question : allQuestions) {
            if (questionsByCategory.containsKey(question.Category__c)) {
                questionsByCategory.get(question.Category__c).add(question);
            }
        }

        for (String category : questionsByCategory.keySet()) {
            List<Question_Master__c> questions = questionsByCategory.get(category);
			
            if (!questions.isEmpty()) {
                selectedQuestions.add(questions[0]);
                for (Integer i = 1; i < questions.size(); i++) {
                    remainingQuestions.add(questions[i]);
                }
            }
        }
        
        remainingQuestions = shuffleQuestions(remainingQuestions);

        while (selectedQuestions.size() < 10 && !remainingQuestions.isEmpty()) {
            selectedQuestions.add(remainingQuestions.remove(0));
        }

        selectedQuestions = shuffleQuestions(selectedQuestions);

        return selectedQuestions;
    }

    public static List<Question_Master__c> shuffleQuestions(List<Question_Master__c> questions) {
        Integer n = questions.size();
        while (n > 1) {
            Integer k = Math.floor(Math.random() * n).intValue();
            n--;
            Question_Master__c temp = questions[n];
            questions[n] = questions[k];
            questions[k] = temp;
        }
        
        return questions;
    }
}