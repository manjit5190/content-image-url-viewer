public with sharing class RecordUrlDisplay {
    @AuraEnabled(Cacheable=true)
    public static List<ContentDocument> getUrls(Id recordId, List<String> contentTypes) {
        try {
            if (String.isBlank(recordId)) {
                return new List<ContentDocument>();
            }
            System.debug(contentTypes);
            List<ContentDocumentLink> links = [
                    SELECT Id, ContentDocumentId, ContentDocument.FileType,
                            ContentDocument.Title, ContentDocument.FileExtension
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
                    AND ContentDocument.FileExtension IN :contentTypes
            ];
            Set<Id> contentDocumentIds = new Set<Id>();

            for (ContentDocumentLink link : links) {
                contentDocumentIds.add(link.ContentDocumentId);
            }

            return [
                    SELECT Id, Title, FileExtension, FileType, (
                            SELECT Id
                            FROM ContentVersions
                            ORDER BY CreatedDate ASC
                            LIMIT 1
                    )
                    FROM ContentDocument
                    WHERE Id IN:contentDocumentIds
            ];
        } catch (QueryException qe) {
            throw new AuraHandledException('');
        }
    }
}