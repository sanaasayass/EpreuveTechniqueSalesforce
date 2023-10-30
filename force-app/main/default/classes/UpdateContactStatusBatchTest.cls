@isTest
private class UpdateContactStatusBatchTest {
    @isTest static void testBatchProcessing() {
        // Create test data
        Account acc = TestDataFactory.createCanceledAccount('Compte de Test');
        insert acc;

        Contact con = TestDataFactory.createActiveContact('Contact de Test');
        insert con;

        AccountContactRelation__c acr = new AccountContactRelation__c(Account__c = acc.Id, Contact__c = con.Id);
        insert acr;
        
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start the batch job
        Test.startTest();
        UpdateContactStatusBatch batch = new UpdateContactStatusBatch(new List<Account>{acc});
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Verify the batch job results
        con = [SELECT Id, IsActive__c FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assertEquals(false, con.IsActive__c, 'Contact should be inactive after batch processing');

        // Add more assertions based on your specific requirements
    }

    
    // Mock HTTP callout response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200); // Set status code 200 for successful response
            res.setBody('{"success": true, "message": "Mock callout successful"}'); // Set desired response body
            return res;
        }
    }
}