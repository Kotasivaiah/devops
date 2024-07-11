/*
Description     :   
Test Class      :   
*/

public without sharing class CandidateListPanelHelper {
    
    // 
    @AuraEnabled
    public static Contact updateCandidateAssessments(Id candidateId, Map<String, String> technicalAssessments, 
                                                     Map<String, String> hrAssessments) 
    {
        Contact candidate = [SELECT Id, Technical_Skills__c, Problem_Solving_Skills__c, Communication_Skills__c, Learning_Skills__c, 
                             Confidence_Level__c, Attitude_and_Professionalism__c, Behavioral_Aspects__c, Clarity_of_Thought__c, 
                             HR_Round_Status__c, Presentability__c, Expression_of_Views__c, Manager_Round_Comments__c, 
                             HR_Round_Comments__c, Manager_Round_Status__c, Communication_Skills_hr__c 
                             FROM Contact 
                             WHERE Id = :candidateId LIMIT 1];
        
        if (technicalAssessments != null) {
            for (String key : technicalAssessments.keySet()) {
                String value = technicalAssessments.get(key);
                if (value != null) {
                    candidate.put(key, value);
                }
            }
        }
        
        if (hrAssessments != null) {
            for (String key : hrAssessments.keySet()) {
                String value = hrAssessments.get(key);
                if (value != null) {
                    candidate.put(key, value);
                }
            }
        }
        
        update candidate;
        
        return candidate;
    }
    
    // 
    @AuraEnabled
    public static List <ExamPortalHelper.CandidateWrapper> filterListView(String filter) {
        
        List <Contact> filteredCandidates = new List <Contact> ();
        List <ExamPortalHelper.CandidateWrapper> wrapperList = new List <ExamPortalHelper.CandidateWrapper> ();
        
        String query = 'SELECT Id, Name, MobilePhone, Alternate_Mobile__c, Email, Current_Location__c, Graduation_College_Name__c, ' 
            + 'Hall_Ticket_No__c, Intermediate_Polytechnic_College_Name__c, Intermediate_Polytechnic_Marks_Grade__c, ' 
            + 'Intermediate_Polytechnic_Passing_Year__c, School_Marks_Grade__c, School_Passing_Year__c, School_Name__c, ' 
            + 'Written_Test_Marks__c, Written_Test_Aptitude_Marks__c, Written_Test_Status__c, Written_Test_Technical_Marks__c, ' 
            + 'Coding_Round_Marks__c, Coding_Round_Status__c, Manager_Round_Status__c, Technical_Round_Status__c, HR_Round_Status__c, ' 
            + 'Coding_Round_Reviewer__r.Name, Tech_Round_Interviewer__r.Name, TR_Comments__c, Manager_Round_Comments__c, ' 
            + 'HR_Round_Comments__c, Selected_Face_To_Face__c, Technical_Skills__c, Problem_Solving_Skills__c, Communication_Skills_hr__c, ' 
            + 'Learning_Skills__c, Manager_Round_Rating__c, HR_Round_Rating__c, Confidence_Level__c, Attitude_and_Professionalism__c, ' 
            + 'Behavioral_Aspects__c, Clarity_of_Thought__c, Technical_Round_Rating__c, Presentability__c, Expression_of_Views__c, ' 
            + 'Confidence_Level_Tr__c, Attitude_and_Professionalism_Tr__c, Learning_Skills_Tr__c, Communication_Skills_Tr__c, ' 
            + 'Problem_Solving_Skills_Tr__c, Technical_Skills_Tr__c, Graduation_Passing_Year__c ' 
            + 'FROM Contact ' 
            + 'WHERE ';
        
        if (filter == 'Technical') {
            query += 'Coding_Round_Status__c = \'Selected\' AND Technical_Round_Status__c = null';
        } else if (filter == 'Manager') {
            query += '(Technical_Round_Status__c = \'Selected\' OR Manager_Round_Status__c = \'On Hold\' OR Manager_Round_Status__c = \'Selected\' OR Manager_Round_Status__c = \'Rejected\') AND Exam_Start_date__c = TODAY';
        } else if (filter == 'Hr') {
            query += '(Manager_Round_Status__c = \'Selected\' OR HR_Round_Status__c = \'On Hold\' OR HR_Round_Status__c = \'Selected\' OR HR_Round_Status__c = \'Rejected\' OR HR_Round_Status__c = \'Selected\') AND Exam_Start_date__c = TODAY';
        } else if (filter == 'Hold') {
            query += '(Manager_Round_Status__c = \'On Hold\' OR HR_Round_Status__c = \'On Hold\' OR Technical_Round_Status__c = \'On Hold\') AND Exam_Start_date__c = TODAY';
        } else if (filter == 'Rejected') {
            query += '(Manager_Round_Status__c = \'Rejected\' OR HR_Round_Status__c = \'Rejected\' OR Technical_Round_Status__c = \'Rejected\') AND Exam_Start_date__c = TODAY';

        } else if (filter == 'Selected') {
            query += 'HR_Round_Status__c = \'Selected\' AND Exam_Start_date__c = TODAY';
        }
        
        filteredCandidates =  Database.query(query);
        
        for(Contact candidate : filteredCandidates) {
            ExamPortalHelper.CandidateWrapper wrapper = new ExamPortalHelper.CandidateWrapper();
            wrapper.id = candidate.Id;
            wrapper.name = candidate.name;
            wrapper.writtenMarks = candidate.Written_Test_Marks__c;
            wrapper.codingMarks = candidate.Coding_Round_Marks__c;
            wrapper.trRating = candidate.Technical_Round_Rating__c;
            wrapper.trRemarks = candidate.TR_Comments__c;
            wrapper.managerRemarks = candidate.Manager_Round_Comments__c;
            wrapper.hrRemarks = candidate.HR_Round_Comments__c;
            wrapper.assignedTo = candidate.Coding_Round_Reviewer__r.Name;
            wrapper.trInterviewer = candidate.Tech_Round_Interviewer__r.Name;
            wrapper.aptitudeMarks = candidate.Written_Test_Aptitude_Marks__c;
            wrapper.technicalMarks = candidate.Written_Test_Technical_Marks__c;
            wrapper.managerRating  = candidate.Manager_Round_Rating__c;
            wrapper.hrRating = candidate.HR_Round_Rating__c;
            
            if (candidate.Coding_Round_Status__c == 'On Hold') {
                wrapper.onHoldRound = 'Coding Round';
            } else if (candidate.Technical_Round_Status__c == 'On Hold') {
                wrapper.onHoldRound = 'Technical Round';
            } else if (candidate.Manager_Round_Status__c == 'On Hold') {
                wrapper.onHoldRound = 'Manager Round';
            } else if (candidate.HR_Round_Status__c == 'On Hold') {
                wrapper.onHoldRound = 'HR Round';
            } 
            //add 
            if (candidate.Technical_Round_Status__c == 'Selected') {
                wrapper.selectedRound = 'Technical Round';
            } 
            if (candidate.Manager_Round_Status__c == 'Selected') {
                wrapper.selectedRound = 'Manager Round';
            }
            
            if (candidate.HR_Round_Status__c == 'Selected') {
                wrapper.selectedRound = 'HR Round';
            } 
            
            
            if (candidate.Written_Test_Status__c == 'Rejected') {
                wrapper.rejectedRound = 'Written Test';
            } else if (candidate.Coding_Round_Status__c == 'Rejected') {
                wrapper.rejectedRound = 'Coding Round';
            } else if (candidate.Technical_Round_Status__c == 'Rejected') {
                wrapper.rejectedRound = 'Technical Round';
            } else if (candidate.Manager_Round_Status__c == 'Rejected') {
                wrapper.rejectedRound = 'Manager Round';
            } 
            if (candidate.HR_Round_Status__c == 'Rejected') {
                wrapper.rejectedRound = 'HR Round';
            } 
            
            wrapperList.add(wrapper);
        }
        
        if (wrapperList.size() > 0) {
            return wrapperList;
        } else {
            return null;
        }
    }
    
    // 
    @AuraEnabled
    public static Contact getProgressData(String candidateId) {
        system.debug(':::::::::::::::::::::::::::::::::candidateId::::::::::::::::::::::::::::::::' + candidateId);
        Contact con = [SELECT Id, Name, MobilePhone, Alternate_Mobile__c, Email, Dob__c, Gender__c, Languages_Spoken__c, Permanent_Location__c, 
                       Current_Location__c, Graduation_College_Name__c, Other_Spoken_Language__c, Programming_Languages_Known__c, Hall_Ticket_No__c, 
                       Intermediate_Polytechnic_College_Name__c, Branch__c, Manager_Round_Rating__c, Intermediate_Polytechnic_Marks_Grade__c, 
                       Intermediate_Polytechnic_Passing_Year__c, Graduation_Passing_Year__c, Graduation_Percentage__c, School_Marks_Grade__c, 
                       School_Passing_Year__c, School_Name__c, Written_Test_Marks__c, Written_Test_Aptitude_Marks__c, Post_Graduate_Passing_Year__c, 
                       Post_Graduate_Percentage__c, Written_Test_Status__c, Written_Test_Technical_Marks__c, Coding_Round_Marks__c, TR_Comments__c, 
                       Coding_Round_Status__c, Manager_Round_Status__c, Technical_Skills__c, Problem_Solving_Skills__c, Communication_Skills__c, 
                       Learning_Skills__c, Other_Graduation_Branch__c, Other_Inter_Branch__c, Other_PG_Branch__c, Confidence_Level__c, 
                       Attitude_and_Professionalism__c, Post_Graduate_Branch__c, Post_Graduate_College_Name__c, Post_Graduate_Hallticket_Number__c, 
                       Behavioral_Aspects__c, Clarity_of_Thought__c, Communication_Skills_hr__c, Presentability__c, Expression_of_Views__c, 
                       Manager_Round_Comments__c, HR_Round_Comments__c, HR_Round_Status__c, Tech_Round_Interviewer__c, Learning_Skills_Tr__c, 
                       Intermediate_Polytechnic_Branch__c, Technical_Round_Rating__c, Technical_Round_Status__c, Confidence_Level_Tr__c, 
                       Attitude_and_Professionalism_Tr__c, Communication_Skills_Tr__c, Problem_Solving_Skills_Tr__c, Technical_Skills_Tr__c,
                       Tech_Round_Interviewer__r.Name, Coding_Round_Reviewer__r.Name 
                       FROM Contact
                       WHERE Id = :candidateId
                       LIMIT 1];
        if (con.Post_Graduate_Branch__c != null && con.Post_Graduate_Branch__c == 'Other') {
                con.Post_Graduate_Branch__c = con.Other_PG_Branch__c;
        }

        if (con.Branch__c == 'Other') {
            con.Branch__c = con.Other_Graduation_Branch__c;
        }
        
        if (con.Languages_Spoken__c != null && con.Languages_Spoken__c.contains('Other')) {
            con.Languages_Spoken__c = con.Languages_Spoken__c.replace('Other',con.Other_Spoken_Language__c);
        }

        if (con.Intermediate_Polytechnic_Branch__c == 'Other') {
            con.Intermediate_Polytechnic_Branch__c = con.Other_Inter_Branch__c;
        }
        return con;
    }
}