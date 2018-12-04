@isTest
public class LorasLeadRouterTest {
    public static testMethod void testRFILeadRouting(){
        
        Account act = new Account(Name = 'Loras');
        insert act;
        
        Id contRecTypeId = [Select Id, Name from RecordType where DeveloperName='Loras' and SObjectType = 'Contact'].Id;
        
        Lead ld = new Lead (FirstName='FN Test', LastName='LNtest', company='Loras', email='fntest@testln.com');
        insert ld;
        
        Contact cont = new Contact(FirstName='FN Test2', LastName='LNtest2',  email='fntest2@testln.com', AccountId=act.Id, RecordTypeId=contRecTypeId);
		insert cont;
        
        ld = new Lead (FirstName='FN Test2', LastName='LNtest2', company='Loras', email='fntest2@testln.com');
        insert ld;
        
        
    }

}