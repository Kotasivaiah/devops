/*
Description         :   Controller for the VF page to get the parameters and pass it to the LWC
Test class          :   CodingRoundReviewControllerTest
*/
public class CodingRoundReviewController {
    
    public String candidateId { get; set; }
    
    // 
    public CodingRoundReviewController() {
        String parameters = ExamPortalHelper.decryptKey(ApexPages.currentPage().getParameters().get('key'))[1];
        if (parameters.contains('#')) {
            List<String> parameterList = parameters.split('#');
            candidateId = parameterList[0];
        } else {
            candidateId = parameters;
        }
    }
}