/*
Description         :   Queries the eligible candidates and assigns them with the selected panel members
Test class name     :   ReviewerAssignmentHelperTest
LWC                 :   ep_ReviewerAssignment
*/

public class ReviewerAssignmentHelper {

    // getting all the users
    @AuraEnabled
    public static List<String> getPanelMembers() {
        List<String> panelList = new List<String>();
        for (User u : [SELECT Id, Name 
                                FROM User 
                                WHERE ISActive = TRUE AND Department = 'Salesforce'])
        
        {
            panelList.add(u.Name.toLowerCase());
        }
        if (!panelList.isEmpty()) {
            return panelList;
        } else {
            return null;
        }
    }


    @AuraEnabled
    public static List<ExamPortalHelper.codingReviewWrapper> getCandidateData () {
        List<Contact> contactids = [SELECT Name, Branch__c, Gender__c, Coding_Round_Reviewer__c, Coding_Round_Reviewer__r.Name, 
                                    Written_Test_Marks__c, Written_Test_Aptitude_Marks__c, Written_Test_Technical_Marks__c, 
                                    Coding_Round_Status__c, Coding_Round_Marks__c, Written_Test_Status__c, 
                                    Technical_Round_Status__c, Tech_Round_Interviewer__c, Tech_Round_Interviewer__r.Name, 
                                    Other_Graduation_Branch__c, Other_PG_Branch__c, Post_Graduate_Branch__c, Exam_Start_Date__c
                                    FROM Contact
                                    WHERE Written_Test_Status__c = 'Selected' 
                                    AND (Coding_Round_Status__c = 'Completed' OR Coding_Round_Status__c = 'Selected')
                                    AND Exam_Start_Date__c = TODAY];
    
        List<ExamPortalHelper.codingReviewWrapper> candidates = new List<ExamPortalHelper.codingReviewWrapper>();
        for (Contact contact : contactids) {
            ExamPortalHelper.codingReviewWrapper candidate = new ExamPortalHelper.codingReviewWrapper();
            candidate.id = contact.Id;
            candidate.name = contact.Name;
            candidate.gender = contact.Gender__c;
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
            candidate.writtenRoundStatus = contact.Written_Test_Status__c;
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

    @AuraEnabled
    public static String assignReviewers(List<Map<String, String>> candidates, List<String> panelMembersList){
        Set<Id> contactIds = new Set<Id>();
        Map<String, String> candidateReviewers = new Map<String, String>();
        List<Contact> newContacts = new List<Contact>();
        List<User> users = [select Id, Name from User where Name IN: panelMembersList];
        Map<String, Id> userNameToId = new Map<String, Id>();
        for (User user : users) {
            userNameToId.put((user.Name).toLowerCase(), user.Id);
        }
        for(Map<String, String> candidate : candidates){
            contactIds.add(candidate.get('id'));
            if(candidate.get('writtenRoundStatus') == 'Selected' && candidate.get('codingRoundStatus') == 'Completed'){
                candidateReviewers.put(candidate.get('id'), candidate.get('codingReviwedBy').toLowerCase());
            }else{
                candidateReviewers.put(candidate.get('id'), candidate.get('technicalReviewedBy').toLowerCase());
            }
        }
        List<Contact> contacts = [SELECT Coding_Round_Reviewer__c, Coding_Round_Reviewer__r.Name,
                                    Coding_Round_Status__c, Written_Test_Status__c,
                                    Technical_Round_Status__c, Tech_Round_Interviewer__c,Tech_Round_Interviewer__r.Name
                                 FROM Contact 
                                 WHERE Id IN : contactIds];
        for(Contact contact : contacts){
            if(contact.Written_Test_Status__c == 'Selected' && contact.Coding_Round_Status__c == 'Completed'){ 
                contact.Coding_Round_Reviewer__c = userNameToId.get(candidateReviewers.get(contact.Id));
            }else{
                contact.Tech_Round_Interviewer__c = userNameToId.get(candidateReviewers.get(contact.Id)); 
            }
            newContacts.add(contact);
        }
        try{
            update newContacts;
            return 'success';
        }catch(Exception e){
            System.debug('ReviewerAssignmentHelper -> assignReviewers: ' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage() + ' ' + e.getLineNumber();
        }
    }
    

    // assigning reviewers to the candidates
    @AuraEnabled
    public static String assignPanelMembers(List<String> selectedPanel, String round) {
        try {
            Map<Id, User> selectedPanelMap = new Map<Id, User> ([SELECT Id FROM User WHERE Name IN :selectedPanel]);
            List<Id> members = new List<Id> (selectedPanelMap.keySet());
            Map<String, Map<String, List<Contact>>> branchGenderToContacts = new Map<String, Map<String, List<Contact>>>();
            
            List<Contact> candidateIdtoContact;
            List<Contact> assignees = new List<Contact>();
            
            String query = 'SELECT Name, Coding_Round_Reviewer__c, Coding_Round_Reviewer__r.Name, Gender__c, branch__c, Id'+ 
                ' FROM Contact ' +
                'WHERE Exam_start_Date__c = TODAY AND ';
            
            if (round == 'CodeReview') {
                query += 'Coding_Round_Status__c = \'Completed\' ORDER BY branch__c, Gender__c ';
                candidateIdtoContact = Database.query(query);
            } else if (round == 'TechnicalRound') {
                query += 'Coding_Round_Status__c = \'Selected\' ORDER BY branch__c, Gender__c ';
                candidateIdtoContact = Database.query(query);
            }
            
            if (!candidateIdtoContact.isEmpty()) {
                Integer i = 0;
                Integer totalUsers = members.size();
                
                if (round == 'CodeReview') {
                    for (Contact candidate : candidateIdtoContact) {
                        candidate.Coding_Round_Reviewer__c = members[i];
                        assignees.add(candidate);
                        i++;
                        if (i > totalUsers - 1) {
                            i = 0;
                        }
                    }
                    
                    if (assignees.size() > 0) {
                        update assignees;
                    }
                    return 'success';
                } else if (round == 'TechnicalRound') {
                    
                    return technicalAssignment(members, round, candidateIdtoContact);
                }

            } else {
                return 'No Candidates found';
            }
            
            return null;
        } catch (Exception e) {
            System.debug('ReviewerAssignmentHelper -> assignPanelMembers: ' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage() + ' ' + e.getLineNumber();
        }
    }
        
    public static String technicalAssignment (List<String> members, String round, List<Contact> candidateIdtoContact) {
        //collecting incomplete assignments
        List<Contact> incompleteAssignments = new List <Contact>();
        
        //collecting previous assignments
        Map<String, List<Contact>> previousAssignments = new Map<String, List<Contact>>();
        Map<String, Integer> currentAssignmentCount = new Map<String, Integer>();
        Map<String, Integer> previousAssignmentCount = new Map<String, Integer>();
        List<Contact> assignees = new List<Contact>();
        
        Integer totalUsers = members.size();
        Integer maxCandidates = candidateIdtoContact.size()/totalUsers;
        system.debug('maxCandidates ::::: ' + maxCandidates);
        system.debug('candidateIdtoContact.size() ::::: ' + candidateIdtoContact.size());
        
        //mapping selected students with previous reviewer
        for (Contact candidate : candidateIdtoContact) {
            
            if (previousAssignments.containsKey(candidate.Coding_Round_Reviewer__c)) {
                previousAssignments.get(candidate.Coding_Round_Reviewer__c).add(candidate);
            } else {
                previousAssignments.put(candidate.Coding_Round_Reviewer__c, new List<Contact>{ candidate });
            }
        }
        
        //calculating previous assignment count
        for (String memberId : previousAssignments.keySet()) {
            previousAssignmentCount.put(memberId, previousAssignments.get(memberId).size());
        }
		
        //setting the current assignment count to zero
        for (String member : members) {
            currentAssignmentCount.put(member, 0);
        }
        
        //sorting the reviewers w.r.t selected candidates count
        List<String> sortedAssigners = descendingSort(previousAssignmentCount);        
        //looping previous reviewers
        Integer index = 0;
        for(String prevReviewer : sortedAssigners){

            //looping candidates selected by the previous reviewer
            for(Contact candidate : previousAssignments.get(prevReviewer)){
                //checking if reviewer same as current loop reviewer and checking if count reached max
                if (members[index] != prevReviewer && currentAssignmentCount.get(members[index]) < maxCandidates) {
                        candidate.Tech_Round_Interviewer__c = members[index];
                        assignees.add(candidate);
                        currentAssignmentCount.put(members[index], currentAssignmentCount.get(members[index]) + 1);
                        index++;
                        
                        //if the index has reached the end, assigning it to the start
                        if (index > totalUsers - 1) {
                            index = 0;
                        }
                    } else {
                        
                        Integer flag = index;
                        index++;

                        //if the index has reached the end, assigning it to the start
                        if (index > totalUsers - 1) {
                            index = 0;

                        }
                        
                        //checking for the next reviewer
                        while ((members[index] == prevReviewer || currentAssignmentCount.get(members[index]) >= maxCandidates) && index != flag) {
                            index++;

                            if (index > totalUsers - 1) {
                                index = 0;

                            }
                        }
					
                        if (index == flag) {
                            Boolean assigned = false;
                            for (String panel : sortedAssigners) {
                                if (members.contains(panel)) {
                                    candidate.Tech_Round_Interviewer__c = panel;
                                    assignees.add(candidate);
                                    assigned = true;
                                    break;
                                }
                            }

                            if (!assigned) {
                                List<String> currentSorted = descendingSort(currentAssignmentCount);
                                candidate.Tech_Round_Interviewer__c = currentSorted[currentSorted.size()-1];
                                assignees.add(candidate);
                                currentAssignmentCount.put(members[index], currentAssignmentCount.get(currentSorted[currentSorted.size()-1]) + 1);

                            }

                        }  else {
                            candidate.Tech_Round_Interviewer__c = members[index];
                            assignees.add(candidate);
                            currentAssignmentCount.put(members[index], currentAssignmentCount.get(members[index]) + 1);
                            index++;

                            //if the index has reached the end, assigning it to the start
                            if (index > totalUsers - 1) {
                                index = 0;
                            }
                        }
                }
            }
        }
        
        if (assignees.size()>0) {
            update assignees;
        }
        return 'success';
    }
    
    private static List<String> descendingSort (Map<String, Integer> members) {
        
        List<String> sortedMembers = new List <String> (members.keySet());
        for (Integer i=0; i<sortedMembers.size()-1; i++) {
            for (Integer j=i+1; j<sortedMembers.size(); j++) {
                if (members.get(sortedMembers[i]) < members.get(sortedMembers[j])) {
                    String temp = sortedMembers[i];
                    sortedMembers[i] = sortedMembers[j];
                    sortedMembers[j] = temp;
                }
            }
        }
        return sortedMembers;
    }
}