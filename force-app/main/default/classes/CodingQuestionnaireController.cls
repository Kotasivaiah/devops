/*
Description			:	
Test class			:	
*/

public without sharing class CodingQuestionnaireController {
    
    public String candidateId { get; set; }
    public Integer examDuration { get; set; }
    public String autoSubmit { get; set; }
    public Integer secondsSpent{ get; set; }
    public Boolean isSubmitted { get; set; }
    public Boolean inProgress { get; set; }
    
    private String adminLoggedIn;
    
    private Contact candidate;
    
    public CodingQuestionnaireController() {
        String parameters = ExamPortalHelper.decryptKey( apexpages.currentpage().getparameters().get('key') )[1];
        if (parameters.contains('#')) {
            List<String> parameterList = parameters.split('#');
            candidateId = parameterList[0];
            adminLoggedIn = parameterList[1];
        }

        try {
            inProgress = false;
            isSubmitted = false;
            secondsSpent = 0;
            autoSubmit = 'false';
           examDuration = Integer.valueOf(Online_Exam_Settings__c.getValues('Coding Exam Duration (Minutes)').Secret_Key__c);

            if (candidateId != null) {
                candidate = [SELECT Id, Name, Branch__c, Written_Test_Status__c,Coding_Round_Status__c , Sec_Consumed__c, 
                             Retake_Start_Time__c, Start_Test_Time__c, End_Test_Time__c 
                             FROM Contact 
                             WHERE Id = :candidateId];
                candidate.Start_Test_Time__c =  DateTime.now().time();
                
                if (candidate.Coding_Round_Status__c == 'Selected' || candidate.Coding_Round_Status__c == 'Rejected'
                     || candidate.Coding_Round_Status__c == 'On Hold') 
                {
                    isSubmitted = true;
                } else if (adminLoggedIn == 'true') {
                    isSubmitted = false;
                } else if (candidate.Coding_Round_Status__c == 'In Progress') {
                    isSubmitted = true;
                    inProgress = true;
                } else if (candidate.Coding_Round_Status__c == 'Not Started') {
					isSubmitted = false;
                } else {
                    isSubmitted = true;
                }
            }
            
            if (candidate.Id != null && candidate.Start_Test_Time__c != null && candidate.End_Test_Time__c != null) {
                Integer totalSecondsLeft = candidate.Sec_Consumed__c == null ? 0 : (Integer)candidate.Sec_Consumed__c;
                if (totalSecondsLeft != 0) {
                    secondsSpent = totalSecondsLeft;
                    if (secondsSpent == examDuration || secondsSpent >= examDuration) {
                        isSubmitted = true; 
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception ::'+e.getMessage());
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
    public PageReference saveData() {
        
        candidate.Coding_Round_Status__c = 'Completed';
        DateTime dt = DateTime.now();
        candidate.End_Test_Time__c = dt.time();
        isSubmitted = true;
        
        if (candidate.End_Test_Time__c != null ) {
            Integer totalSecondsLeft = calculateTimeDiff(candidate);
            candidate.Sec_Consumed__c = totalSecondsLeft ;
        }
        update candidate;
        
        return null;
    }
    
    // 
    @RemoteAction
    public static String updateStatus (String CandidateId) {
        Contact candidate = [SELECT Written_Test_Status__c, Coding_Round_Status__c 
                             FROM Contact 
                             WHERE Id =: CandidateId];
        candidate.Coding_Round_Status__c = 'In Progress';
        
        update candidate;
        return 'success';
    }
    
}