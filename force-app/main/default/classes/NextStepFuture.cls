/*
 * NextStepFuture Class Description:
 * 
 * The NextStepFuture class demonstrates the usage of future methods in Salesforce for performing asynchronous operations.
 * 
 * Benefits of using future methods:
 * 
 * 1. Asynchronous Processing: Allows long-running operations to be handled in the background, freeing up resources.
 * 2. Governor Limit Management: Asynchronous methods have a separate set of limits, providing more flexibility.
 * 3. User Experience Enhancement: Improves responsiveness in user interfaces by offloading processes to the background.
 * 4. Mixed DML Operations Handling: Helps overcome Mixed DML errors by allowing updates on setup and non-setup objects.
 * 5. Enhanced Integration Capabilities: Useful for making callouts to external systems without blocking the user interaction.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
 * 
 * Note: The class below contains placeholders for implementing a future method to update accounts and opportunities.
 *       The accompanying test class 'AsynchronousTest' should also be updated to test this method.
 */
public with sharing class NextStepFuture {

    /* 
     * Update/Uncomment the template code to create a method
     * Create a future method that updates all account and opportunities next step to 'Meeting in the future'
     * Account Next Step field is a custom field
     * Opportunity Next Step field is a standard field
     * Update the corresponding test class AsynchronousTest and test method nextStepFuture_testUpdateAllNextStep to cover test this method
     */
    @future
    public static void updateAcctAndOpportunityNextStep () {
        List<Account> allAccounts = [
                                    SELECT Id 
                                    FROM Account
                                    WHERE Id IN (SELECT AccountID FROM Opportunity)];
        Set<Id> accountIds = new Set<Id>();
        Map<Id,List<Opportunity>> accountToOpps = new Map<Id,List<Opportunity>>();

        // Cycle through all Account records to update Next Step
        for( Account acc : allAccounts){
            accountIds.add(acc.Id); 
            acc.Next_Step__c = 'Meeting in the future';        
        }
        // update Accounts
        update allAccounts;

        // query related Opportunities 
        List<Opportunity> allRelatedOpportunities = [
            SELECT ID, NextStep, AccountID
            FROM Opportunity
            WHERE AccountID IN :accountIds];
        for( Opportunity opp : allRelatedOpportunities){
                opp.NextStep = 'Meeting in the future';    
        // update related opportunities
         update allRelatedOpportunities;
        }
    }

    //Mix DML Error happens when you try to perform DML operations on setup and non-setup objects in a single transaction.
    
    public static void createDeal() {
        Opportunity bigDeal = new Opportunity();
        insertBigDeal(bigDeal); 
    }
    // break Update off to prevent Mixed DML errors 
    @future
    public static void updateRole(){
        UserRole[] roles = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() OR Name = 'CRO' LIMIT 1];
        updateUserRoleName(roles);
    }

    // Helper method to insert big deal
    private static void insertBigDeal(Opportunity opp) {
        opp.Amount = 1000000;
        opp.Name = 'Big Deal';
        opp.StageName = 'Closed Won'; 
        opp.CloseDate = Date.today();
        
        insert opp;
    }


    // Helper method to update role name
    private static void updateUserRoleName(UserRole[] roles){
        UserRole role;
        if (roles.isEmpty()) {
            role = new UserRole();
            role.portalType = 'None'; 
            role.CaseAccessForAccountOwner = 'Edit'; 
            // role.OpportunityAccessForAccountOwner = 'Edit'; //This may need to be uncommented depending on your orgs Organization Wide Defaults(OWD) settings. If you are receiving FIELD_INTEGRITY_EXCEPTION, field integrity exception: unknown (Opportunity access level below organization default): [unknown], uncomment this line.
        } else {
            role = roles[0];
        }

        role.Name = 'CRO';

        upsert role;
    }
}