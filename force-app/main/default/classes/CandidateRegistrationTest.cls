@isTest
public class CandidateRegistrationTest {
    
    @isTest
    private static void candidateData () {
        Map<Object, Object> obj = 
            new Map<Object, Object> {
                'firstName' => 'Kotla',
                    'lastName' => 'Seetha Ramireddy',
                    'dob' => '2002-03-08',
                    'gender' => 'Male',
                    'mobileNumber' => '6303205839',
                    'email' => 'seetharamkotla266@gmailtest.com',
                    'sl' => 'English;Hindi;Telugu;Other',
                    'caddress' => 'APHB Colony, Guntur',
                    'collegeName' => 'Tirumala Engineering College',
                    'gYear' => '2023',
                    'gHallTicketNumber' => '19Ne1a0477',
                    'gPercent' => '65',
                    'interName' => 'Sri Chiatanya Jr College',
                    'interBranch' => 'Other',
                    'interYear' => '2019',
                    'interPercent' => '90',
                    'schoolName' => 'Shivam Merits Public School',
                    'schoolYear' => '2017',
                    'schoolPercent' => '85',
                    'pl' => 'Java;Python;HTML;CSS',
                    'pgName' => 'ANU',
                    'pgBranch' => 'Other',
                    'pgYear' => '2023',
                    'pgHallTicketNumber' => '19ne1a0478',
                    'pgPercent' => '65',
                    'paddress' => 'APHB Colony, Guntur',
                    'otherpgBranch' => 'PG',
                    'otherbranch' => 'Aeronuatical',
                    'otherinterBranch' => 'BiMPC'
                    };
                        
                        Test.startTest();
        
        CandidateRegistration.registerCandidate (obj);
        CandidateRegistration.registerCandidate (obj);
        CandidateRegistration.getCustomAddress();
        CandidateRegistration.getPicklistValues(
            new List<Map<String, String>> {
                new Map<String, String> {'sobjectName' => 'Lead', 'fieldName' => 'Gender__c'}
            }
        );
        
        Test.stopTest();
    }
    
}