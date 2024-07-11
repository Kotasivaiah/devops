/*
Description         :   To get the Candidate Data from the Reports After running the Reports
Test class name     :   CandidateReportDataTest, CandidateLoginHelperTest
LWC                 :   ep_CandidateSelection
*/

public class CandidateReportData {
    
    //fetching report names to display
    @AuraEnabled
    public static List<Map<String, String>> fetchReportNames() {
        
        List<Map<String, String>> reportNames = new List<Map<String, String>>();
        
        try {
            for (Report r : [SELECT Id, Name 
                             FROM Report 
                             WHERE FolderName = 'Exam Portal']) 
            {
                reportNames.add(new Map<String, String> { 'label' => r.Name, 'value' => r.name });
            }
            
            if (!reportNames.isEmpty()) {
                return reportNames;
            } else {
                return null;
            }
        }
        catch (Exception e) {
            System.debug('CandidateReportData -> fetchReportNames: ' + e.getLineNumber() + ' ' + e.getMessage());
            return null;
        }
    }
    
    // Get the ReportData for the given report name
    @AuraEnabled
    public static List<String> getReportData(String reportName) {
        
        List<String> candidateIds = new List<String>();
        
        try {
            List<Report> reportList = [SELECT Id, Name, FolderName 
                                       FROM Report 
                                       WHERE Name = :reportName];
            
            Reports.reportResults results = Reports.ReportManager.runReport(reportList[0].Id, true);
            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap().values()[0];
            List<Reports.ReportDetailRow> detailRow = factDetails.getRows();
            
            for (Reports.ReportDetailRow row : detailRow) {
                candidateIds.add((String) row.getDataCells()[0].getValue());
            }
            
            return candidateIds;
        } catch (Exception e) {
            System.debug('CandidateReportData -> getReportData: ' + e.getLineNumber() + ' ' + e.getMessage());
            return null;
        }
    }
    
    // Updating the status of the corresponding round and mailing the list of candidates to the colleges
    @AuraEnabled
    public static String updateStatus(List<Id> ids, String roundName, List<String> emailAddresses) {
        try {
            String rejectionQuery = 'SELECT Id, Written_Test_Status__c, Coding_Round_Status__c ' 
                + 'FROM Contact ' 
                + 'WHERE Id NOT IN :ids AND Exam_Start_Date__c = TODAY';
                
            String selectionQuery = 'SELECT Id, Written_Test_Status__c, Coding_Round_Status__c, Sec_Consumed__c ' +
                                                'FROM Contact '+
                                                'WHERE Id IN :ids';
            
            List<Contact> selectedCandidates = new List<Contact>();
            List<Contact> updatingConList = new List<Contact>();
            
            if (roundName == 'Written Round Candidate Filter') {
                roundName = 'Round-1';
                for (Contact con : Database.query(selectionQuery)) {
                    con.Written_Test_Status__c = 'Selected';
                    con.Sec_Consumed__c = 0;
                    updatingConList.add(con);
                }
                
                for (Contact con : Database.query(rejectionQuery)) {
                    con.Written_Test_Status__c = 'Rejected';
                    updatingConList.add(con);
                }
            } else if (roundName == 'Coding Round Candidate Filter') {
                roundName = 'Round-2';
                
                for (Contact con : Database.query(selectionQuery)) {
                    con.Coding_Round_Status__c = 'Selected';
                    updatingConList.add(con);
                }
                
                for (Contact con : Database.query(rejectionQuery)) {
                    con.Coding_Round_Status__c = 'Rejected';
                    updatingConList.add(con);
                }
            }
            if (!updatingConList.isEmpty()) {
                update updatingConList;
            }
            
            return emailCandidateList(ids, emailAddresses, roundName);
        } catch (Exception e) {
            System.debug('CandidateReportData -> getReportData: ' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getMessage() + ' ' + e.getLineNumber();
        }
    }
    
    //to mail the Seleted Candidates to the college
    private static String emailCandidateList(List<Id> ids, List<String> emailAddresses, String roundName) {
        
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Contact');
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            
            
            List<Schema.FieldSetMember> fields =  Schema.SObjectType.Contact.fieldSets.getMap().get('Result_Mailing_Fields').getFields();
            String query = 'SELECT ';
            
            for (Schema.FieldSetMember fieldMember : fields) {
                query += fieldMember.getFieldPath() + ', ';
            }
            
            query += 'Other_Graduation_Branch__c,'+
                    'Other_PG_Branch__c, Post_Graduate_Branch__c FROM Contact WHERE Id IN :ids';
            
            List<Contact> conList = Database.query(query);
            
            if (!conList.isEmpty()) {
                
                String csvString = '';
                
                for (Schema.FieldSetMember fieldMember : fields) {
                    
                    String key = fieldMember.getFieldPath();
                    Schema.SObjectField field = fieldsMap.get(key);
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    csvString += fieldDescribe.getLabel() + ',';
                }
                csvString += '\n';
                
                for (Contact con : conList) {
                    for (Schema.FieldSetMember fieldMember : fields) {
                        
                        String key = fieldMember.getFieldPath();
                        
                        if (key == 'Branch__c') {
                            
                            if (con.Post_Graduate_Branch__c != null) {
                                if (con.Post_Graduate_Branch__c == 'Other') {
                                    csvString += con.Other_PG_Branch__c + ', ';
                                } else {
                                    csvString += con.Post_Graduate_Branch__c  + ', ';
                                }
                            } else {
                                if (con.Branch__c == 'Other') {
                                    csvString += con.Other_Graduation_Branch__c  + ', ';
                                } else {
                                    csvString += con.Branch__c + ', ';
                                }
                            }
                        } else {
                            csvString += con.get(key) + ', ';
                        }
                    }
                    csvString += '\n';
                }

                Messaging.EmailFileAttachment csvFile = new Messaging.EmailFileAttachment();
                csvFile.setFileName('Eligible Candidates.csv');
                csvFile.setBody(Blob.valueOf(csvString));

                String templateId;
                
                if (roundName == 'Round-1') {
                    templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'EP Written Round Notification'].Id;
                } else if (roundName == 'Round-2') {
                    templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'EP Coding Round Notification'].Id;
                }
                
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId, Null, Null);
                
                List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
                message.setToAddresses(emailAddresses);
                fileAttachments.add(csvFile);
                message.fileAttachments = fileAttachments;
                
                List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                messages.add(message);
                
                if (!Test.isRunningTest()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (!results[0].success) {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                        return results[0].errors[0].message;
                    } else {
                        return 'success';
                    }
                } else {
                    return 'success';
                }
            } else {
                return 'No Contacts found!';
            }
        } catch (Exception e) {
            System.debug('CandidateReportData -> getRepoemailCandidateListrtData: ' + e.getLineNumber() + ' ' + e.getMessage());
            return e.getLineNumber() + ' ' + e.getMessage();
        }
    }   
}