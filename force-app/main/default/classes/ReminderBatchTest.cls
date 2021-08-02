/**
 * Created by lilas on 02/08/2021.
 */

@IsTest
private class ReminderBatchTest {
	@TestSetup
	static void setUpPerTest() {
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		Profile p = [
				SELECT Id
				FROM Profile
				WHERE Name = 'Standard User'
		];
		UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'MyTestRole');
		User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = uniqueUserName,
				UserRoleId = r.Id
		);
		System.runAs(u) {
			List<Account> acct = TestDataFactory.createAccounts(10);
		}

	}
	/**
	 * @description the batch should add tasks to the database as only accounts have been created
	 */
	@IsTest
	static void ReminderForAccountInactivityBatchTest() {
		Test.startTest();
		ReminderForAccountInactivityBatch reminder = new ReminderForAccountInactivityBatch();
		Id batchId = Database.executeBatch(reminder, 100);
		Test.stopTest();
		List <Task> myTasksReminder = [
				SELECT WhatId, Status, Subject, Priority, OwnerId, IsReminderSet, ReminderDateTime
				FROM Task
				WHERE Subject = 'call' AND OwnerId IN (
						SELECT Id
						FROM User
						WHERE Alias LIKE 'standt'
				)
		];
		System.assertEquals(10, myTasksReminder.size());
		for (Task task : myTasksReminder) {
			System.assertEquals(task.Subject, 'Call', 'The task subject should be a call reminder');
			System.assertEquals(task.Status, 'Not Started', 'The tasks status should be new');
			System.assertEquals(task.Priority, 'Normal');
			System.assertEquals(task.IsReminderSet, true);
			System.assertEquals(task.ReminderDateTime, System.now() + 5);
		}

	}
	@IsTest
	static void ReminderForActiveAccountBatchTest() {
		List<Account> accts = [SELECT Id From Account WHERE Name LIKE 'TestAccount_%' Limit 5];

		Product2 productOne = TestDataFactory.createProduct('TestItem', 'Prestation');

		PricebookEntry priceBook = TestDataFactory.createPricebookEntry(productOne.Id, 1020);

		List<Order> ord = TestDataFactory.createOrders(2, accts, priceBook);


		Test.startTest();
		ReminderForAccountInactivityBatch reminder = new ReminderForAccountInactivityBatch();
		Id batchId = Database.executeBatch(reminder, 100);
		Test.stopTest();
		List <Task> myTasksReminder = [
				SELECT WhatId, Status, Subject, Priority, OwnerId, IsReminderSet, ReminderDateTime
				FROM Task
				WHERE Subject = 'call' AND OwnerId IN (
						SELECT Id
						FROM User
						WHERE Alias LIKE 'standt'
				)
		];
		System.debug(myTasksReminder);
		System.assertEquals(5, myTasksReminder.size());//half of created account has orders
		for (Task task : myTasksReminder) {
			System.assertEquals(task.Subject, 'Call', 'The task subject should be a call reminder');
			System.assertEquals(task.Status, 'Not Started', 'The tasks status should be new');
			System.assertEquals(task.Priority, 'Normal');
			System.assertEquals(task.IsReminderSet, true);
			System.assertEquals(task.ReminderDateTime, System.now() + 5);
		}

		System.debug(myTasksReminder);
	}
}