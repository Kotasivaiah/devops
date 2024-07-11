/*
Description			:	Has all wrappers, encryption and decryption 
Test class			:	CandidateReportDataTest
*/

public class ExamPortalHelper {
    
    // returns the encryptedValue
    @AuraEnabled
    public static List<String> encryptKey(String valueToEncrypt) {
        List<String> result = new List<String>();
        
        try {
            String code = System.Label.EP_EncryptionCode;
            Blob presetIV = Blob.valueOf (code);
            Blob cryptoKey = Blob.valueOf (code);
            Blob data = Blob.valueOf (valueToEncrypt);
            Blob encryptedData = Crypto.encrypt ('AES128', cryptoKey, presetIV, data);
            result.add('success');
            result.add(EncodingUtil.convertToHex(encryptedData));
            return result;
        } catch (Exception e) {
            System.debug('ExamPortalHelper -> encryptKey: ' + e.getLineNumber() + ' ' + e.getMessage());
            result.add('error');
            result.add(e.getLineNumber() + ' ' + e.getMessage());
            return result;
        }
    }

    @AuraEnabled
    public static String clearDatabase() {
        String result = 'success';
        List<Sobject> deletedRecords = new List<Sobject>();
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE HR_Round_Status__c = 'Selected']);
        List<Candidate_Written_Answer__c> writtenList = [SELECT Id FROM Candidate_Written_Answer__c WHERE Id = :contactMap.keySet()];
        List<Candidate_Coding_Answer__c> codingList = [SELECT Id FROM Candidate_Coding_Answer__c WHERE Id = :contactMap.keySet()];
        List<Candidate_technical_Answer__c> technicalList = [SELECT Id FROM Candidate_technical_Answer__c WHERE Id = :contactMap.keySet()];
        
        deletedRecords.addAll(contactMap.values());
        deletedRecords.addAll(writtenList);
        deletedRecords.addAll(codingList);
        deletedRecords.addAll(technicalList);
        
        Database.DeleteResult[] drList = Database.delete(deletedRecords, false);
        for(Database.DeleteResult dr : drList) {
            if (!dr.isSuccess()) {    
                result = dr.getErrors()[0].getMessage();
                break;
            }
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String updateSecretKey(String recordName, String value) {

        try {
            Online_Exam_Settings__c customSettingRecord = [SELECT Id, Secret_Key__c FROM Online_Exam_Settings__c WHERE Name = :recordName LIMIT 1];
            customSettingRecord.Secret_Key__c = value;
            update customSettingRecord;
            return 'success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static List<String> getRecordNames(String recordName, String value) {

        List<String> recordNames = new List<String>();
        List<Online_Exam_Settings__c> records = Online_Exam_Settings__c.getall().values();
        for (Online_Exam_Settings__c record : records) {
            recordNames.add(record.Name);
        }
        if (recordNames.size() > 0) {
            return recordNames;
        } else {
            return null;
        }
        
    }

    // retruns decrypted value
    @AuraEnabled
    public static List<String> decryptKey(String encryptedkey) {
        List<String> result = new List<String>();
        
        try {
            String code = System.Label.EP_EncryptionCode;
            Blob cryptoKey = Blob.valueOf (code);
            Blob presetIV = Blob.valueOf (code);
            Blob data = EncodingUtil.convertFROMHex(encryptedkey);
            Blob decryptedData = Crypto.decrypt ('AES128', cryptoKey, presetIV, data);
            
            result.add('success');
            result.add(decryptedData.toString());
            return result;
        } catch (Exception e) {
            System.debug('ExamPortalHelper -> decryptKey: ' + e.getLineNumber() + ' ' + e.getMessage());
            result.add('error');
            result.add(e.getLineNumber() + ' ' + e.getMessage());
            return result;
        }
    }
    
    public class CandidateWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal writtenMarks;
        @AuraEnabled
        public Decimal codingMarks;
        @AuraEnabled
        public Decimal trRating;
        @AuraEnabled
        public String assignedTo;
        @AuraEnabled
        public String onHoldRound;
        @AuraEnabled
        public String rejectedRound;
        @AuraEnabled
        public String trRemarks;
        @AuraEnabled
        public String managerRemarks;
        @AuraEnabled
        public String hrRemarks;
        @AuraEnabled
        public String selectedRound;
        @AuraEnabled
        public String trInterviewer;
        @AuraEnabled
        public Decimal aptitudeMarks;
        @AuraEnabled
        public Decimal technicalMarks;
        @AuraEnabled
        public Decimal managerRating;
        @AuraEnabled
        public Decimal hrRating;
        
        public CandidateWrapper () {
            this.id = null;
            this.name = null;
            this.writtenMarks = null;
            this.codingMarks = null;
            this.trRating = null;
            this.assignedTo = null;
            this.onHoldRound = null;
            this.rejectedRound = null;
            this.trRemarks = null;
            this.managerRemarks = null;
            this.selectedRound = null;
            this.trInterviewer = null;
            this.aptitudeMarks = null;
            this.technicalMarks = null;
        }
    }
    
    public class filteredCandidateWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String htNumber;
        @AuraEnabled
        public String branch;
        @AuraEnabled
        public Decimal aptitudeMarks;
        @AuraEnabled
        public Decimal technicalMarks;
        @AuraEnabled
        public Decimal totalMarks;
    }
    
    public class codingReviewWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String branch;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String writtenMarks;
        @AuraEnabled
        public String writtenRoundStatus;
        @AuraEnabled
        public String codingReviwedBy;  
        @AuraEnabled
        public String aptitudeMarks;
        @AuraEnabled
        public String technicalMarks;
        @AuraEnabled
        public String codingRoundStatus; 
        @AuraEnabled
        public String technicalRoundStatus;
        @AuraEnabled
        public String codingMarks; 
        @AuraEnabled
        public String technicalReviewedBy;  
        @AuraEnabled
        public String codingRoundReiewerId;
        @AuraEnabled
        public String technicalRoundReviewerId;  
    }
    
    public class technicalReviewWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String candidateId;
        @AuraEnabled
        public String technicalLanguage;
        @AuraEnabled
        public String difficultyLevel;
        @AuraEnabled
        public String technicalQuestion;
        @AuraEnabled
        public String response;
    }
    
}