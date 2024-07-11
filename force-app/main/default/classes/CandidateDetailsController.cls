/*
Description		:	
VF Page			:	CandidateDetails
Test Class		:	
*/

public class CandidateDetailsController {
    
    public String candidate { get; set; }
    
    public CandidateDetailsController() {
        candidate = ExamPortalHelper.decryptKey(ApexPages.currentPage().getParameters().get('key') )[1];
        //system.debug('::::::::::::::::::Id :::::::::::::::::::::: ' + candidate);
    }
    
}