/**
 * Created by lilas on 01/08/2021.
 * @description
 */

@IsTest
private class AccountActivationTest {
	/**
	 * @description Set up per test using the TestDataFactory class
	 */
	@TestSetup
	static void setUpPerTest() {
		List<Account> acct = TestDataFactory.createAccounts(5);

		Product2 productOne = TestDataFactory.createProduct('TestItem', 'Prestation');

		PricebookEntry priceBook = TestDataFactory.createPricebookEntry(productOne.Id, 1020);

		List<Order> ord = TestDataFactory.createOrders(2, acct, priceBook);

		List<OrderItem> orderItems = TestDataFactory.createOrderItemsWithRandomQuantity(ord, priceBook);

	}

	@isTest
	static void AccountWithOrderShouldBeActive() {
		List<Account> accts = [
				SELECT Id, Active__c
				FROM Account
				WHERE Name LIKE 'TestAccount_%'
		];
		List<Order> orders = [
				SELECT Id, AccountId
				FROM Order
				WHERE Name LIKE 'Order_%'
		];
		Test.startTest();
		update orders;
		Test.stopTest();

		for (Account acc : accts) {
			System.assertEquals(true, acc.Active__c);
			System.debug(acc.Active__c);

		}


	}
	@isTest
	static void AccountWithNoOrderShouldBeInactive() {
		List <Account> accts = [
				SELECT Id, Active__c, ( SELECT Id FROM Orders )
				FROM Account
				WHERE Name LIKE 'TestAccount_%'
		];
		for (Account acc : accts) {
			System.assertEquals(true, acc.Active__c);
		}
		Test.startTest();
		for(Account acc : accts){
		for(Order ord : acc.Orders){
			delete ord;
		}}
		Test.stopTest();
		accts = [
				SELECT Id, Active__c
				FROM Account
				WHERE Name LIKE 'TestAccount_%'
		];
		for (Account acc : accts) {
			System.assertEquals(false, acc.Active__c);


		}


	}
}