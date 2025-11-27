public with sharing class FileUploaderController {
    @AuraEnabled
    public static Id uploadFileToRecord(String base64Data, String fileName, Id recordId) {
        Blob fileBody = EncodingUtil.base64Decode(base64Data);

        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = fileBody;

        if (recordId != null) {
            cv.FirstPublishLocationId = recordId;
        }

        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocId = cv.ContentDocumentId;

        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = contentDocId;
        link.LinkedEntityId = recordId;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;

        return contentDocId;
    }
}
