@IsTest
private class QuestionMasterControllerTest {
    @IsTest
    static void testSelectQuestions() {
        Map<String, List<Question_Master__c>> selectedQuestions = 
            QuestionMasterController.selectQuestions();

        QuestionMasterController.getQuestions();
        
        System.assert(selectedQuestions.containsKey('Technical'), 
            'Technical questions should be present');
        System.assert(selectedQuestions.containsKey('Aptitude'),
            'Aptitude questions should be present');

        System.assertEquals(10, selectedQuestions.get('Technical').size(),
            'Should have 10 Technical questions');
        System.assertEquals(10, selectedQuestions.get('Aptitude').size(),
            'Should have 10 Aptitude questions');
    }
}