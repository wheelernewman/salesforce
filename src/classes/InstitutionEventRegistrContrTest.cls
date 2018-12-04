@isTest
public class InstitutionEventRegistrContrTest {
    
    public static testMethod void testEventCalendar(){
        List<Institution_Event__c> eventLst = new List<Institution_Event__c>();
        Institution_Event__c event = new Institution_Event__c();
        event.Name = 'Preview Day - October 8th - 2018';
        event.Event_Category__c = 'Group Visit Days';
        event.Event_Start_Date_Time__c = Datetime.newInstance(2018, 10, 8, 7, 8, 16);
        event.Event_End_Date_Time__c = Datetime.newInstance(2018, 10, 8, 14, 8, 16);
        eventLst.add(event);
        insert eventLst;
        Institution_Event_Registration__c newReg = new Institution_Event_Registration__c();
        
        InstitutionEventRegistrationController controller = new InstitutionEventRegistrationController( new ApexPages.StandardController( newReg ) );
        controller.thisRequest.Search_Date_To__c = Date.newInstance(2018, 10, 8);
        controller.doSearch();
        controller.thisRequest.Search_Date_From__c = Date.newInstance(2018, 10, 8);
        controller.thisRequest.Search_Date_To__c = null;
        controller.doSearch();
        controller.thisRequest.Search_Date_From__c = Date.newInstance(2018, 10, 8);
        controller.thisRequest.Search_Date_To__c =  Date.newInstance(2018, 10, 8);
        controller.doSearch();
        controller.thisRequest.Search_Date_From__c = null;
        controller.thisRequest.Search_Date_To__c = null;
        controller.thisRequest.Date_Shortcuts__c = 'This Year';
        controller.doSearch();
        
        controller.getDetailUrl();
        
        //Test.setCurrentPage('AdmissionEventDetailsLoras');

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('evtid',event.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(event);
        InstitutionEventRegistrationController controller2 = new InstitutionEventRegistrationController( sc );
        controller2.getRedirectToRegisterationPage();
        controller2.thisRequest = new Institution_Event_Registration__c();
        controller2.thisRequest.First_Name__c = 'TestSt';
        controller2.thisRequest.Last_Name__c = 'LNTest';
        controller2.thisRequest.Date_of_Birth__c = System.today();
        controller2.thisRequest.Cell_Phone__c = '1231234555';
        controller2.thisRequest.Email__c = 'testst@testcompany.com';
        controller2.thisRequest.Street_Address_1__c = '1234 El Dorado';
        controller2.thisRequest.City__c = 'Houston';
        controller2.thisRequest.State__c = 'TX';
        controller2.thisRequest.Postal_Code__c = '77476';
        controller2.SavePage();
        
        event.Event_Category__c = 'Daily Visits';
        update event;
        controller2.thisEvent = event;
        controller2.getRedirectToRegisterationPage();
           
        Lead ld = new Lead();
        HelloWelcomeLorasExtension welcomecontroller = new HelloWelcomeLorasExtension( new ApexPages.StandardController(ld) );
        
        ApexPages.currentPage().getParameters().put('evtid',event.Id);
        
        sc = new ApexPages.StandardController(newReg);
        InstitutionEventRegistrationController controller3 = new InstitutionEventRegistrationController( sc );
        
        //controller3.thisRequest = new Institution_Event_Registration__c();
        controller3.thisRequest.First_Name__c = 'TestSt';
        controller3.thisRequest.Last_Name__c = 'LNTest';
        controller3.thisRequest.Date_of_Birth__c = System.today();
        controller3.thisRequest.Cell_Phone__c = '1231234555';
        controller3.thisRequest.Email__c = 'testst@testcompany.com';
        controller3.thisRequest.Street_Address_1__c = '1234 El Dorado';
        controller3.thisRequest.City__c = 'Houston';
        controller3.thisRequest.State__c = 'TX';
        controller3.thisRequest.Postal_Code__c = '77476';
        controller3.coachesFileName = 'testfile.txt';
        controller3.fileContent = Blob.valueOf('test file');
        controller3.saveCoachForm();

        //Preview Day - October 8th - 2018
    }
    


}