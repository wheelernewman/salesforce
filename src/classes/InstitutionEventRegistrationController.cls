public without sharing class InstitutionEventRegistrationController {
    
    private ApexPages.StandardController stdController;
    public Institution_Event_Registration__c thisRequest{get;set;}
    public Institution_Event__c thisEvent{get;set;}
    public List<Institution_Event__c> evtResults {get;set;}
    public String evtId{get;set;}
    Public String coachesFileName{get;set;}
    Public Blob fileContent {get;set;}
    public String highSchoolInput {get;set;} // for smart search - ID of the selected HS
    public String highSchoolTextErrorMessage {get; set;} // for smart search - stores custom error message

    public InstitutionEventRegistrationController(ApexPages.StandardController stdController){
        
        if( String.IsNotEmpty(ApexPages.currentPage().getParameters().get('evtid')) ){
            evtId = ApexPages.currentPage().getParameters().get('evtid');
         	  
        }
        
        //Create a hook onto new record created by VF page
        if(stdController.getRecord() instanceof Institution_Event_Registration__c){
        	thisRequest = (Institution_Event_Registration__c) stdController.getRecord();
        	thisRequest.Institution_Event__c = evtId; 
        }
        else
        {
            thisEvent = (Institution_Event__c) stdController.getRecord();
            thisEvent = [Select  Id, Name, Event_End_Date_Time__c, Event_Start_Date_Time__c , Event_Description__c, Event_Category__c from Institution_Event__c
                        where Id=:thisEvent.Id];
            //parse out parameter
            //ApexPages.currentPage().getParameters.get('evtid');
        }
        
        

        
    }
    
    
    public void doSearch(){
        
        String searchQuery;
        List<String> conditions = new List<String>();
        String startDayStr;
        String endDayStr;
        Date dt;
        
        searchQuery = 'Select Id, Name, Event_End_Date_Time__c, Event_Start_Date_Time__c , Event_Description__c, Event_Category__c from Institution_Event__c ';
        conditions.add('WHERE Past_Event__c = false');
        if( thisRequest.Search_Date_From__c !=null && thisRequest.Search_Date_To__c!=null){
            dt = thisRequest.Search_Date_From__c;
            startDayStr = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            dt = thisRequest.Search_Date_To__c;
            endDayStr = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            conditions.add('(Event_Start_Date_Time__c >= ' + startDayStr + ' AND (Event_End_Date_Time__c <= ' + endDayStr + ' or Event_End_Date_Time__c =null ))');
            //searchQuery += '(Event_Start_Date_Time__c >= ' + startDayStr + ' AND Event_End_Date_Time__c <= ' + endDayStr + ') AND ' ;
        }
        else if ( thisRequest.Search_Date_From__c != null ){
            dt = thisRequest.Search_Date_From__c;
            startDayStr = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            conditions.add('Event_Start_Date_Time__c >= ' + startDayStr);
            //searchQuery += 'Event_Start_Date_Time__c >= ' + startDayStr  ;
        }
        else if ( thisRequest.Search_Date_To__c != null ){
            dt = thisRequest.Search_Date_To__c;
            endDayStr = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            conditions.add('Event_End_Date_Time__c <= ' + endDayStr );
            //searchQuery += 'Event_End_Date_Time__c <= ' + endDayStr  ;
        }
        else if ( thisRequest.Date_Shortcuts__c != null ){
            Switch on thisRequest.Date_Shortcuts__c{
                
                when 'Next 7 Days' {
                    conditions.add('Event_in_Next_7_Days__c = true ');
                    //searchQuery += 'Event_in_Next_7_Days__c = true ';
                }
                when 'This Month' {
                    conditions.add('Event_This_Month__c = true');
                    //searchQuery += 'Event_This_Month__c = true ';
                }
                when 'This Year' {
                    conditions.add('Event_This_Year__c = true');
                    //searchQuery += 'Event_This_Year__c = true ';
                }
                when else {
                     System.debug('do nothing');
                }
            }
        }
        else
        {
            //do nothing
        }
            
        if( thisRequest.Event_Category__c != null )
            conditions.add('Event_Category__c =\'' + thisRequest.Event_Category__c + '\'');
            //searchQuery += 'AND Event_Category__c =\'' + thisRequest.Event_Category__c + '\'';
        
        if(!conditions.isEmpty())
            searchQuery += String.join(conditions, ' AND ');
        
		
        System.debug('query: ' + searchQuery);
        List<SObject> results = Database.query(searchQuery);
        evtResults = new List<Institution_Event__c>();
        for(SObject obj: results){
            evtResults.add((Institution_Event__c) obj);
            System.debug('found result ' + obj);
        }
    }
    
    public String getDetailUrl(){
        Site site = [SELECT GuestUserId, Name, Subdomain, UrlPathPrefix FROM Site WHERE Name = :'Loras_Event_Calendar'];
		Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization];
		//String siteFullUrl = 'https://' + site.Subdomain + '.';
        String siteFullUrl = (org.IsSandbox) ? 'https://' + 'lorascom-collegiscommunity.' : 'http://admissions.';
        siteFullUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
        siteFullUrl += '/' + site.UrlPathPrefix ;
        return siteFullUrl;
    }
    
    public PageReference SavePage(){
        //thisRequest.Institution_Event__c = evtId; (Ask about this...it was blanking out this field on the VF page)
        try{
            
            // make sure the user's High School input matches the Id we have set for it on the page 
            // (it is possible they re-tpyed a new input value after selecting one from the list previously)
            High_School__c[] selectedHighSchool = [SELECT Id, Name FROM High_School__c WHERE Id = :thisRequest.High_School__c];
            
            if (!selectedHighSchool.isEmpty() && selectedHighSchool[0].Name == this.highSchoolInput) {
                this.highSchoolTextErrorMessage = '';
            }
            else {
                this.highSchoolTextErrorMessage = '<b>Error:</b> No matches found';
                return null;
            }
            
            insert thisRequest;
        }
        catch (Exception e){
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Error Submitting the Form: ' + e.getMessage());
      		ApexPages.addmessage(msg);
            return null;
        }
        PageReference pg = Page.LorasThankyouPage;
        pg.setRedirect(true);
        return pg;    
    }
    
    public PageReference saveCoachForm(){
        System.debug('name ' + thisRequest.First_Name__c);
        System.debug('coachesFileName' + coachesFileName);
        if( String.isEmpty(thisRequest.First_Name__c) || String.isBlank(thisRequest.First_Name__c) )
            thisRequest.Name = 'Group Registration';
        insert thisRequest;
        
        if(String.isNotEmpty(coachesFileName) && String.isNotBlank(coachesFileName))
        {
            ContentVersion ContentInsert =new ContentVersion(); 
            ContentInsert.Title =coachesfileName; 
            ContentInsert.VersionData=fileContent;
            ContentInsert.PathOnClient='/' + coachesFileName ;
            insert ContentInsert; 
            system.debug('ContentInsert.id '+ ContentInsert.id);
            ContentInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: ContentInsert.Id];
            ContentDocumentLink cl = new ContentDocumentLink();
            cl.ContentDocumentId = ContentInsert.ContentDocumentId;
            cl.LinkedEntityId = thisRequest.Id; 
            cl.ShareType = 'V';
            cl.Visibility = 'AllUsers';
            insert cl;
        }
            
        PageReference pg = Page.LorasThankyouPage;
        pg.setRedirect(true);
        return pg;
    }
    
    /*public String getDetailUrl(string sitename){
        Site site = [SELECT GuestUserId, Name, Subdomain, UrlPathPrefix FROM Site WHERE Name = :sitename];
		Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization];
		//String siteFullUrl = 'https://' + site.Subdomain + '.';
        String siteFullUrl = 'https://' + 'lorascom-collegiscommunity.';
        siteFullUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
        siteFullUrl += '/' + site.UrlPathPrefix ;
        return siteFullUrl;
    }*/
    //loraspreviewday 
    
    public PageReference getRedirectToRegisterationPage(){
        PageReference regPage;
        System.debug('category ' + thisEvent.Event_Category__c);
        
        Switch on thisEvent.Event_Category__c{
            when 'Daily Visits'{
                regPage = Page.DailyVisitLoras;
                regPage.getParameters().put('evtid', thisEvent.Id);
                regPage.setRedirect(true);
    			return regPage;
            }
            when 'Group Visit Days'{
                regPage = Page.PreviewDaysLoras;
                regPage.getParameters().put('evtid', thisEvent.Id);
                regPage.setRedirect(true);
    			return regPage;
            }
            when 'Saturday Small Group Visit'{
                regPage = Page.CoachesFormLoras;
                regPage.getParameters().put('evtid', thisEvent.Id);
                regPage.setRedirect(true);
    			return regPage;
            }
            when else{
                regPage = Page.OrientationLoras;
                regPage.getParameters().put('evtid', thisEvent.Id);
                regPage.setRedirect(true);
    			return regPage;
            }
            
        }
            
        
    }
    
    // for the PreviewDaysLoras smart search
    @RemoteAction
    public static List <HighSchoolWrapper> getSearchSuggestions(String searchString) {
        
        //String soslSearchString = '';
        
        //List <String> termsToSearch = searchString.split(' ');
        
        //for (String eachTerm : termsToSearch) {
            //if (eachTerm != null && eachTerm != '') {
            	//soslSearchString += '\'' + eachTerm + '*\'' + ' OR ';
            //}
        //}
     
        // Inner class List that is returned to the page
        List <HighSchoolWrapper> highSchoolWrappers = new List <HighSchoolWrapper>();
        
        if (searchString != null && searchString != '') {
            // SOSL query that returns high schools
            List <List<sObject>> searchObjects = [FIND :searchString IN NAME FIELDS 
                                                  RETURNING High_School__c(Id, Name, Address_1__c, City__c, State__c, Zip__c)];
            
            if (!searchObjects.isEmpty()) {
                // Loop through the objects - there should be only one
                for (List <sObject> objects : searchObjects) {
                    // loop through the high schools, create a HighSchoolWrapper that holds the label, custom label, and Id
                    // and add them to the highSchoolWrappers list
                    for (sObject obj : objects) {   
                        High_School__c hs = (High_School__c) obj;
                        highSchoolWrappers.add(new HighSchoolWrapper(hs));
                    }   
                }   
            }
        }
        return highSchoolWrappers;  
    } // getSearchSuggestions end
    
    // action for the PreviewDaysLoras pages' 
    // ActionFunction that sets highSchoolTextErrorMessage
    public void highSchoolIdAF() {}

    // inner class used to display each high school for the PreviewDaysLoras smart search
    private class HighSchoolWrapper {
        
        public String selectedLabel {get; set;} // high school name
        public String label {get; set;} // high school with address
        public String value {get; set;} // high school Id
        
        // constructor that sets the values
        HighSchoolWrapper(High_School__c hs) {
            this.selectedLabel = hs.Name;
            this.value = hs.Id;
            this.label = buildHsLabel(hs);
        }
        
        // builds the label (name and address)
        private String buildHsLabel(High_School__c hsToBuild) {
            
            String theLabel = hsToBuild.Name;
            
            // check if each field is null before adding it to the string
            if (hsToBuild.Address_1__c != null) {
                theLabel += ' - ' + hsToBuild.Address_1__c;
            }
            if (hsToBuild.City__c != null) {
                if (hsToBuild.State__c != null) {
                    theLabel += ' ' + hsToBuild.City__c + ',';
                } 
                else {
                    theLabel += ' ' + hsToBuild.City__c;
                }   
            }
            if (hsToBuild.State__c != null) {
                theLabel += ' ' + hsToBuild.State__c;
            }
            if (hsToBuild.Zip__c != null) {
                theLabel += ' ' + hsToBuild.Zip__c;
            }                     
            return theLabel;
        }
    } // HighSchoolWrapper end
    
    //public void test() {
        //system.debug('highSchoolTextErrorMessage');
    //}
    
}