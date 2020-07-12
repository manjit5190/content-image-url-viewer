@IsTest(SeeAllData = false)

private with sharing class RecordUrlDisplayTest {

    @TestSetup
    static void createData() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        ContentVersion file = new ContentVersion();
        file.Title = 'ABC.png';
        file.PathOnClient = 'ABC.png';
        file.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert file;

        ContentVersion version = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :file.Id
                LIMIT 1
        ];

        insert new ContentDocumentLink(
                LinkedEntityId = account.Id, ContentDocumentId = version.ContentDocumentId
        );
    }

    @IsTest
    static void testPositiveScenario() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<ContentDocument> files = RecordUrlDisplay.getUrls(accountId, new List<String>{
                'png', 'jpg'
        });
        System.assert(files.size() == 1);
    }

    @IsTest
    static void testPositiveNegative() {
        List<ContentDocument> files = RecordUrlDisplay.getUrls(null, null);
        System.assert(files.isEmpty());
    }

}