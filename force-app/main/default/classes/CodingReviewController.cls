/*
Description         :   To store the candidate data, comments, rating, Status after CodingRound Review, Helper for LWC
Test class name     :   
LWC                 :   codingRoundReview
*/

public class CodingReviewController {
    
    // getcandidateData for codingRoundReview for the current logged in User
    @AuraEnabled
    public static List <ExamPortalHelper.codingReviewWrapper> getCandidateCompleteddata() {
        
        List<Contact> contactids = [SELECT Id, Name, Branch__c, Username__c , Coding_Round_Reviewer__c, Coding_Round_Reviewer__r.Name, 
                                    Written_Test_Marks__c, Written_Test_Aptitude_Marks__c, Written_Test_Technical_Marks__c, 
                                    Coding_Round_Status__c, Manager_Round_Comments__c, Coding_Round_Marks__c, Technical_Round_Marks__c, 
                                    Technical_Round_Status__c, Tech_Round_Interviewer__c, Tech_Round_Interviewer__r.Name, Other_Graduation_Branch__c,
                                    Other_PG_Branch__c, Post_Graduate_Branch__c
                                    FROM Contact 
                                    WHERE Written_Test_Status__c = 'Selected' AND
                                    (Coding_Round_Status__c = 'Completed' OR Coding_Round_Status__c = 'Selected' 
                                     OR Coding_Round_Status__c = 'Rejected' OR Coding_Round_Status__c = 'On Hold')
                                     AND Exam_Start_Date__c = TODAY];
        
        List<ExamPortalHelper.codingReviewWrapper> candidates = new List<ExamPortalHelper.codingReviewWrapper>();
        for (Contact contact : contactids) {
            ExamPortalHelper.codingReviewWrapper candidate = new ExamPortalHelper.codingReviewWrapper();
            candidate.id = contact.Id;
            candidate.name = contact.Name;
            if (contact.Post_Graduate_Branch__c != null) {

                if (contact.Post_Graduate_Branch__c == 'Other') {
                    candidate.branch = contact.Other_PG_Branch__c;
                } else {
                    candidate.branch = contact.Post_Graduate_Branch__c;
                }
            } else {
                if (contact.Branch__c == 'Other') {
                    candidate.branch = contact.Other_Graduation_Branch__c;
                } else {
                    candidate.branch = contact.Branch__c;
                }
            }
            //candidate.branch = contact.Branch__c;
            candidate.writtenMarks = String.valueOf(contact.Written_Test_Marks__c);
            candidate.aptitudeMarks = String.valueOf(contact.Written_Test_Aptitude_Marks__c);
            candidate.technicalMarks = String.valueOf(contact.Written_Test_Technical_Marks__c);
            candidate.codingMarks = String.valueOf(contact.Coding_Round_Marks__c);
            candidate.codingRoundStatus = contact.Coding_Round_Status__c;
            candidate.codingReviwedBy = contact.Coding_Round_Reviewer__r.Name;
            candidate.codingRoundReiewerId = contact.Coding_Round_Reviewer__c;
            candidate.technicalRoundStatus = contact.Technical_Round_Status__c;
            candidate.technicalRoundReviewerId = contact.Tech_Round_Interviewer__c;
            candidate.technicalReviewedBy = contact.Tech_Round_Interviewer__r.Name;
            
            candidates.add(candidate);
        }
        return candidates;
    }
    
    // Update CodingRoundReviewer in Contact & Reviewedby in CodingAnswer Records
    @AuraEnabled
    public static String updateCodingReviewer(String candidateId, String userId) {
        List<Candidate_Coding_Answer__c> newCArecords = new List<Candidate_Coding_Answer__c>();
        
        Contact candidate = [SELECT Id, Coding_Round_Reviewer__c 
                             FROM Contact 
                             WHERE Id = :candidateId LIMIT 1];
        candidate.Coding_Round_Reviewer__c = userId;
        try {
            update candidate;            
            return 'success';
        } catch (Exception e) {
            System.debug('CodingReviewController -> updateReviewer :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getLineNumber() + ' ' + e.getMessage();
        }
    }
    

    //update TechnicalRoundReviewer
    @AuraEnabled
    public static String updateTechnicalReviewer(String candidateId, String userId) {
        List<Candidate_Coding_Answer__c> newCArecords = new List<Candidate_Coding_Answer__c>();
        
        Contact candidate = [SELECT Id, Tech_Round_Interviewer__c 
                             FROM Contact 
                             WHERE Id = :candidateId LIMIT 1];
        candidate.Tech_Round_Interviewer__c = userId;        
        try {
            update candidate;
            return 'success';
        } catch (Exception e) {
            System.debug('CodingReviewController -> updateReviewer :' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getLineNumber() + ' ' + e.getMessage();
        }
    }
}