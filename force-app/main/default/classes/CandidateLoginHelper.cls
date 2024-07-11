/*
Description			:	To check login data matches or not and generate questions for Written and coding Round
Test class name		:	CandidateLoginHelperTest
LWC					:	ep_LoginPage
*/

public without sharing class CandidateLoginHelper {
    
    //Lead to Contact Conversion
    @AuraEnabled
    public static String login(String htNumber) {
        
        List<Contact> contactList = [SELECT Id 
                                     FROM Contact 
                                     WHERE Username__c = :htNumber.toUpperCase()];
        System.debug('contactList::'+contactList);
        Account parentAccount = [SELECT Id 
                                 FROM Account 
                                 WHERE Name = :System.Label.Default_Account_Name];
        
        if (contactList.size() == 0) {
            String candidateId = '';
            List<Lead> leadList = [SELECT Id 
                                   FROM Lead 
                                   WHERE Username__c = :htNumber.toUpperCase()];
            if(leadList.size() > 0) {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadList[0].Id);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                            FROM LeadStatus 
                                            WHERE IsConverted = true 
                                            LIMIT 1];
                
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setDoNotCreateOpportunity(TRUE);
                lc.setAccountId(parentAccount.Id);
                
                Database.LeadConvertResult result = Database.convertLead(lc);
                
                if (result.isSuccess()) {
                    Contact candidate =  [SELECT Id, Written_Test_Status__c, Coding_Round_Status__c 
                                          FROM Contact 
                                          WHERE Id = :result.getContactId() 
                                          LIMIT 1];
                    
                    candidate.Written_Test_Status__c = 'Not Started';
                    candidate.Coding_Round_Status__c = 'Not Started';
                    candidate.Exam_Start_Date__c = System.today();
                    update candidate;
                    candidateId = candidate.Id;
                }
            }
            
            return candidateId;
        } else if (contactList.size() > 0) {
            return contactList[0].Id;
        } else {
            return 'invalid';
        }
        
    }
    
    //To get candidate Info
    @AuraEnabled
    public static Contact getCandidateData(String candidateId) {
        
        List<Contact> contactList = [SELECT Id, Email, Hall_Ticket_No__c, Sec_Consumed__c, Written_Test_Status__c, Coding_Round_Status__c 
                                     FROM Contact 
                                     WHERE Id = :candidateId];
        if (contactList.size() > 0) {
            return contactList[0];
        } else {
            return null;
        }
    }
    

    //To get candidate Info
    @AuraEnabled
    public static List<String> getSecretKeys(String candidateId) {
        try{
            Online_Exam_Settings__c coding = Online_Exam_Settings__c.getValues('Coding Round');
            Online_Exam_Settings__c written = Online_Exam_Settings__c.getValues('Written Test');            
            Online_Exam_Settings__c codingTime = Online_Exam_Settings__c.getValues('Coding Exam Duration (Minutes)');            
            Online_Exam_Settings__c writtenTime = Online_Exam_Settings__c.getValues('Written Exam Duration (Minutes)');  
            
            return new List<String> {written.Secret_Key__c, coding.Secret_Key__c,codingTime.Secret_Key__c,writtenTime.Secret_Key__c};
        }
        catch (Exception e) {
            return null;
        }
    }


    //generate both writtenRound and codingRound Questions
    @AuraEnabled
    public static String generateQuestions(String candidateId, String category) {
        
        try {
            Contact candidate = [SELECT Id, Written_Test_Status__c, Coding_Round_Status__c, 
                                 (SELECT Id FROM Candidate_Written_Answers__r), 
                                 (SELECT Id FROM Candidate_Coding_Answers__r) 
                                 FROM Contact 
                                 WHERE Id = :candidateId LIMIT 1];
            if (candidate.Written_Test_Status__c == 'Not Started' && candidate.Candidate_Written_Answers__r.size() == 0) {
                WrittenQuestionAnswerController.insertWrittenQuestions(WrittenQuestionAnswerController.getwrittenQuestions(category), 
                                                                        candidateId );
            } else if(candidate.Written_Test_Status__c == 'Selected' && candidate.Coding_Round_Status__c == 'Not Started' 
                      && candidate.Candidate_Coding_Answers__r.size() == 0) 
            {
                CodingAnswerController.insertCodingQuestions(CodingAnswerController.generateCodingQuestions(category), candidateId );
            }
            return 'success';
        } catch (Exception e) {
            System.debug('CandidateLoginHelper -> generateQuestions :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage();
        }        
    }
    
    //check if password and hallTicket Matches for adminLogin
    @AuraEnabled
    public static String adminLogin(String candidateHallticket, String password) {
        
        try {
            List<Contact> contactList = [SELECT Id 
                                         FROM Contact 
                                         WHERE Username__c = :candidateHallticket.toUpperCase()];
            if (contactList.size() > 0 && Online_Exam_Settings__c.getValues('Admin Key').Secret_Key__c == password) {
                return contactList[0].Id;
            } else {
                return 'invalid';
            }
        } catch (exception e) {
            System.debug('CandidateLoginHelper -> adminLogin :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
}