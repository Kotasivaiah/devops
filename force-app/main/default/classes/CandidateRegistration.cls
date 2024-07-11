/*
Description			:	To store the candidate data from registration form
Test class name		:	CandidateRegistrationTest
LWC					:	ep_CandidateRegistrationForm
*/

public without sharing class CandidateRegistration {
    
    // Insert candidate data into Lead
    @AuraEnabled
    public static String registerCandidate(Map<Object, Object> detailObject) {
        
        try {
            system.debug(':::::::::::::::::::::::::::::::::::detailObject::::::::::::::::::::::::::::::::::::' + detailObject);
            for (Object key : detailObject.keySet()) {
                system.debug(key + '::' + detailObject.get(key));
            }
            String email = (String) detailObject.get('email');
            String htNumber = ((String) detailObject.get('gHallTicketNumber')).toUpperCase();
            String pgHtNumber = detailObject.containsKey('pgHallTicketNumber') 
                ? ((String)detailObject.get('pgHallTicketNumber')).toUpperCase() : null;
            String userName = pgHtNumber != null ? pgHtNumber : htNumber;
            
            Lead candidate = new Lead();
            candidate.Username__c = userName;
            candidate.FirstName = (String) detailObject.get('firstName');
            candidate.LastName = (String) detailObject.get('lastName');
            candidate.Dob__c = Date.valueOf((String) detailObject.get('dob'));
            candidate.Gender__c = (String) detailObject.get('gender');
            candidate.MobilePhone = (String) detailObject.get('mobileNumber');
            candidate.Alternate_Mobile__c = (String) detailObject.get('altMobileNumber');
            candidate.Email = email;
            candidate.Languages_Spoken__c = (String) detailObject.get('sl');
            candidate.Current_Location__c = (String) detailObject.get('caddress');
            candidate.Permanent_Location__c = (String) detailObject.get('paddress');
            candidate.Graduation_College_Name__c = (String) detailObject.get('collegeName');
            candidate.Graduation_Passing_Year__c = (String) detailObject.get('gYear');
            candidate.Hall_Ticket_No__c = htNumber;
            
            Decimal graduatePercent = Decimal.valueOf(String.valueOf(detailObject.get('gPercent')));
            
            candidate.Graduation_Percentage__c = graduatePercent <= 10 
                ? String.valueOf(graduatePercent * 10) : String.valueOf(graduatePercent);
            candidate.Intermediate_Polytechnic_College_Name__c = (String) detailObject.get('interName');
            candidate.Intermediate_Polytechnic_Branch__c = (String) detailObject.get('interBranch');
            
            Decimal interPercent = Decimal.valueOf(String.valueOf(detailObject.get('interPercent')));
            
            candidate.Intermediate_Polytechnic_Marks_Grade__c = interPercent <= 10 
                ? String.valueOf(interPercent * 10) : String.valueOf(interPercent);
            candidate.Intermediate_Polytechnic_Passing_Year__c = (String) detailObject.get('interYear');
            
            Decimal schoolPercent = Decimal.valueOf(String.valueOf(detailObject.get('schoolPercent')));
            
            candidate.School_Marks_Grade__c = schoolPercent <= 10 
                ? String.valueOf(schoolPercent * 10) : String.valueOf(schoolPercent);
            
            candidate.School_Passing_Year__c = (String) detailObject.get('schoolYear');
            candidate.School_Name__c = (String) detailObject.get('schoolName');
            candidate.Programming_Languages_Known__c = (String) detailObject.get('pl');
            candidate.Post_Graduate_Branch__c = detailObject.containsKey('pgBranch') ? (String) detailObject.get('pgBranch') : null;
            candidate.Post_Graduate_College_Name__c = detailObject.containsKey('pgName') ? (String) detailObject.get('pgName') : null;
            candidate.Post_Graduate_Passing_Year__c = detailObject.containsKey('pgYear') ? (String) detailObject.get('pgYear') : null;
            candidate.Post_Graduate_Hallticket_Number__c = pgHtNumber;
            candidate.Other_PG_Branch__c = detailObject.containsKey('otherpgBranch') ? (String) detailObject.get('otherpgBranch') : null;
            candidate.Other_Graduation_Branch__c = detailObject.containsKey('otherbranch') ? (String) detailObject.get('otherbranch') : null;
            candidate.Other_Inter_Branch__c = detailObject.containsKey('otherinterBranch') 
                ? (String) detailObject.get('otherinterBranch') : null;
            candidate.Other_Spoken_Language__c  = detailObject.containsKey('othersl') ? (String) detailObject.get('othersl') : null;
            candidate.Company = 'BigWorks Pvt Ltd';
            candidate.Gender__c = (String) detailObject.get('gender');
            candidate.Branch__c = (String) detailObject.get('branch');
            if (detailObject.containsKey('pgPercent') && detailObject.get('pgPercent') != null && detailObject.get('pgPercent') != '') {
                Decimal pgPercentage = Decimal.valueOf(String.valueOf(detailObject.get('pgPercent')));
                candidate.Post_Graduate_Percentage__c = pgPercentage <= 10 ? String.valueOf(pgPercentage* 10) : String.valueOf(pgPercentage);
            }
            insert candidate;
            
            return 'success';
        } catch (System.DmlException dml) {
            String errorMessage = dml.getDmlMessage(0);
            if (errorMessage.contains('duplicate')) {
                if (errorMessage.contains('Hall_Ticket_No__c')) {
                    return 'Graduation HallticketNumber already exists';
                } else if (errorMessage.contains('Post_Graduate_Hallticket_Number__c')) {
                    return 'Postgraduation HallticketNumber already exists';
                }
            }
            return dml.getDmlMessage(0);
        } catch (exception e) {
            System.debug('CandidateRegistration -> apply: ' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage() + ' ' + e.getLineNumber();
        }
    }
    
    // 
    @AuraEnabled
    public static Map<String, List<String>> getPicklistValues(List<Map<String, String>> fieldsAndObjects) {
        
        Map<String, List<String>> picklistValueMap = new Map<String, List<String>>();
        
        for (Map<String, String> fieldAndObject : fieldsAndObjects) {
            String sObjectName = fieldAndObject.get('sobjectName');
            String fieldName = fieldAndObject.get('fieldName');
            picklistValueMap.put(fieldName, getPicklistEntries(sObjectName, fieldName));
        }
        
        return picklistValueMap;
    }
    
    // 
    private static List<String> getPicklistEntries(String sObjectName, String fieldName) {
        
        List <String> picklistValues = new List <String> ();
        
        Schema.DescribeFieldResult fieldResult = 
            Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        
        for (Schema.PicklistEntry picklistValue : fieldResult.getPicklistValues()) {
            picklistValues.add(picklistValue.getValue());
        }
        
        return picklistValues;
    }
}