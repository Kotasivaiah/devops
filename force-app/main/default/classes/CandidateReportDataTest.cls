/*
Apex class		:	CandidateReportData, ExamPortalHelper
*/

@isTest
public class CandidateReportDataTest {
    
    @isTest(SeeAllData=true)
    static void reportTest () {
        
        Test.startTest ();
            List<Map<String, String>> reportNames = CandidateReportData.fetchReportNames();
            CandidateReportData.getReportData( reportNames[0].get('value') );
            CandidateReportData.getReportData( reportNames[1].get('value') );
        Test.stopTest();
        
    }
    
    @isTest
    static void wrapperTestMethod () {
        Test.startTest ();
            ExamPortalHelper.CandidateWrapper wrapper1 = new ExamPortalHelper.CandidateWrapper();
            ExamPortalHelper.filteredCandidateWrapper wrapper2 = new ExamPortalHelper.filteredCandidateWrapper();
            ExamPortalHelper.codingReviewWrapper wrapper3 = new ExamPortalHelper.codingReviewWrapper();
            ExamPortalHelper.technicalReviewWrapper wrapper4 = new ExamPortalHelper.technicalReviewWrapper();
        	ExamPortalHelper.decryptKey(ExamPortalHelper.encryptKey('test string')[1]);
        Test.stopTest();
    }
}