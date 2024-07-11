/*
Description			:	
Test class			:	
*/

public without sharing class QuestionnaireController {
      
    public Boolean inProgress { get; set;}
    public Integer examDuration { get; set; }
    public Boolean isSubmitted { get; set; }    
    public String autoSubmit { get; set; }
    public String candidateId { get; set;}
    private String adminLoggedIn;    
    public Integer secondsSpent{ get; set; }
    
    private Contact candidate;
    
    public Map<Id,Id> questionIdWithResponseId = new Map<Id,Id>();
    public List<QuestionWrapper> candidateWrittenQuestions { get; set; }
    
    // 
    public class QuestionWrapper {
        public String question {get; set;}
        public Id questionId { get; set; }        
        public String selectedOption { get; set; }
        public List<selectOption> options {get; set;}
        
        public QuestionWrapper(String question, List<selectOption> options, String selectedOption, Id questionId) {
            this.question = question;
            this.options = options;
            this.questionId = questionId;
            if (selectedOption != null) {
                this.selectedOption = selectedOption;
            }
        } 
    }
    
    // 
    public QuestionnaireController() {
        String parameters = ExamPortalHelper.decryptKey(ApexPages.currentPage().getParameters().get('key'))[1];
        if (parameters.contains('#')) {
            List<String> parameterList = parameters.split('#');
            candidateId = parameterList[0];
            adminLoggedIn = parameterList[1];
        }
        candidateWrittenQuestions = new List<QuestionWrapper>();
        
        try {
            isSubmitted = false;
            secondsSpent = 0;
            inProgress = false;
            autoSubmit = 'false';
            examDuration = Integer.valueOf(Online_Exam_Settings__c.getValues('Written Exam Duration (Minutes)').Secret_Key__c);
            List<Candidate_Written_Answer__c> allWrittenQuestions = [SELECT Id, CandidateId__c, Response__c, Written_Round_1_Question__c, 
                                                                     Written_Round_1_Question__r.Question__c, 
                                                                     Written_Round_1_Question__r.Option_1__c, 
                                                                     Written_Round_1_Question__r.Option_2__c, 
                                                                     Written_Round_1_Question__r.Option_3__c, 
                                                                     Written_Round_1_Question__r.Option_4__c, 
                                                                     Written_Round_1_Question__r.Answer__c 
                                                                     FROM Candidate_Written_Answer__c
                                                                     WHERE CandidateId__c = :candidateId];
            for(Candidate_Written_Answer__c CWrecord : allWrittenQuestions) {
                List<String> optionss = new List<String>();
                
                questionIdWithResponseId.put(CWrecord.Written_Round_1_Question__c, CWrecord.Id);
                optionss.add(CWrecord.Written_Round_1_Question__r.Option_1__c);
                optionss.add(CWrecord.Written_Round_1_Question__r.Option_2__c);
                optionss.add(CWrecord.Written_Round_1_Question__r.Option_3__c);
                optionss.add(CWrecord.Written_Round_1_Question__r.Option_4__c);
                
                List<SelectOption> qOptions = new List<SelectOption>();
                for (String qOption : optionss) {
                    qOptions.add(new SelectOption(qOption,qOption));
                }
                
                candidateWrittenQuestions.add(new QuestionWrapper(CWrecord.Written_Round_1_Question__r.Question__c.replaceAll('\n', '<br/>'), 
                                                                  qOptions, CWrecord.Response__c ,CWrecord.Written_Round_1_Question__c));
            }
            
            if (candidateId != null) {
                candidate = [SELECT Id, Name, Branch__c, Written_Test_Status__c,Exam_Start_Date__c, Sec_Consumed__c, Retake_Start_Time__c, 
                             Start_Test_Time__c, End_Test_Time__c, Written_Test_Aptitude_Marks__c, Coding_Round_Status__c, 
                             Written_Test_Technical_Marks__c 
                             FROM Contact 
                             WHERE Id = :candidateId];
                
                DateTime dt = DateTime.now();
                candidate.Start_Test_Time__c =  dt.time(); 
                
                if ((candidate.Written_Test_Status__c == 'Selected' || candidate.Written_Test_Status__c == 'Rejected'
                     || candidate.Written_Test_Status__c == 'On Hold') && adminLoggedIn == 'false') 
                {
                    isSubmitted = true;
                    system.debug('Selected');
                } else if (adminLoggedIn == 'true') {
                    isSubmitted = false;
                    system.debug('admiin logged in ');
                } else if (candidate.Written_Test_Status__c == 'In Progress') {
                    isSubmitted = true;
                    inProgress = true;
                    system.debug('in progress!!');
                } else if (candidate.Written_Test_Status__c == 'Not Started') {
					isSubmitted = false;
                    system.debug('Not started the exam!!!');
                } else {
                    isSubmitted = true;
                }
            }
            
            if (adminLoggedIn == 'false' && inProgress) {
                isSubmitted = true;
            }
            
            if (candidate.Id != null && candidate.Start_Test_Time__c != null && candidate.End_Test_Time__c != null) {
                Integer totalSecondsLeft = candidate.Sec_Consumed__c == null ? 0 : (Integer)candidate.Sec_Consumed__c;
                
                if (totalSecondsLeft != 0) {
                    secondsSpent = totalSecondsLeft;
                    if (secondsSpent >= examDuration) {
                        isSubmitted = true; 
                    }
                }
            }
        } catch(Exception e) {
            System.debug('Exception ::'+e.getMessage() + '  ' + e.getLineNumber());
            isSubmitted = true;
        }
    }
    
    // 
    public Integer calculateTimeDiff(Contact candidate) {
        Integer secConsumed = 0;
        secConsumed += candidate.Sec_Consumed__c == null ? 0 : (Integer)candidate.Sec_Consumed__c; 
        
        Time startTime = candidate.Start_Test_Time__c;
        Integer starHours = startTime.hour();
        Integer startMinutes = startTime.minute();
        Integer startSeconds = startTime.second();
        
        Time endTime = candidate.End_Test_Time__c;
        Integer endHours = endTime.hour();
        Integer endMinutes = endTime.minute();
        Integer endSeconds = endTime.second();
        
        Integer hourToSec1 = starHours * 3600;
        Integer mintToSec1 = startMinutes * 60;
        Integer totalVal1 =hourToSec1 + mintToSec1 + startSeconds;
        
        Integer hourToSec2 = endHours * 3600;
        Integer mintToSec2 = endMinutes * 60;
        Integer totalVal2 = hourToSec2 + mintToSec2 + endSeconds;
        
        Integer totalSecondsLeft = secConsumed + (totalVal2 - totalVal1);
        
        String seconds = String.valueOf(totalSecondsLeft);
        Boolean result = seconds.contains('-');
        if (result == true) {
            totalSecondsLeft = Integer.valueOf(seconds) * -1;
        }
        return totalSecondsLeft;
    }
    
    // 
    public void saveData() {
        List<Candidate_Written_Answer__c> responses = new List<Candidate_Written_Answer__c>();
        
        for (QuestionWrapper question: candidateWrittenQuestions) {
            if (question.selectedOption != null) {
                Candidate_Written_Answer__c response = new Candidate_Written_Answer__c();
                if (questionIdWithResponseId.containsKey(question.questionId)) {
                    response.id = questionIdWithResponseId.get(question.questionId); 
                }
                if (response.id == null) {
                    response.Written_Round_1_Question__c = question.questionId;
                    response.CandidateId__c = candidate.Id;
                }
                response.Response__c = question.selectedOption;
                responses.add(response);
            }
        }
        update responses; 
        
        candidate.Written_Test_Status__c = 'Completed';
        candidate.Exam_Start_Date__c = candidate.Exam_Start_Date__c == null ? Date.today() : candidate.Exam_Start_Date__c;
        
        DateTime dt = DateTime.now();
        candidate.End_Test_Time__c = dt.time();
        
        List<Integer> marks = storeMarks(responses);
        
        candidate.Written_Test_Aptitude_Marks__c = marks[0];
        candidate.Written_Test_Technical_Marks__c = marks[1];
        
        isSubmitted = true;
        inProgress = false;
        
        if (candidate.End_Test_Time__c != null ) {
            Integer totalSecondsLeft = calculateTimeDiff(candidate);
            candidate.Sec_Consumed__c = totalSecondsLeft ;
        }
        
        update candidate;
    }
    
    // 
    public List<Integer> storeMarks(List<Candidate_Written_Answer__c> writtenAnswerList) {
        List<Integer> marks = new List<Integer>();
        Set<Id> writtenAnswerIds = new Set<Id>();
        
        for (Candidate_Written_Answer__c answer : writtenAnswerList) {
            writtenAnswerIds.add(answer.Id);
        }
        
        List<Candidate_Written_Answer__c> responses = [SELECT Id, Response__c, Written_Round_1_Question__r.Answer__c, 
                                                       Written_Round_1_Question__r.Type__c 
                                                       FROM Candidate_Written_Answer__c 
                                                       WHERE Id IN :writtenAnswerIds];
        Integer aptitudeMarks = 0;
        Integer technicalMarks =0;
        
        for (Candidate_Written_Answer__c response : responses) {   
            if (response.Response__c != null) { 
                if ((response.Written_Round_1_Question__r.Answer__c == response.Response__c) &&
                    response.Written_Round_1_Question__r.Type__c == 'Aptitude') 
                {
                    aptitudeMarks++;
                } else if((response.Written_Round_1_Question__r.Answer__c == response.Response__c) &&
                          response.Written_Round_1_Question__r.Type__c == 'Technical') 
                {
                    technicalMarks++;
                }
            }
        }  
        marks.add(aptitudeMarks);
        marks.add(technicalMarks);  
        
        return marks;
    }
    
    // 
    @RemoteAction
    public static String updateStatus(String CandidateId) {
        Contact candidate = [SELECT Written_Test_Status__c 
                             FROM Contact 
                             WHERE Id = :CandidateId];
        candidate.Written_Test_Status__c = 'In Progress';
        update candidate;
        
        return 'success';
    }
    
}