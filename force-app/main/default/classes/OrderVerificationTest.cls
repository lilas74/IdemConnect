/**
 * Created by lilas on 23/07/2021.
 * @description class to test the trigger and the orderVerification class
 */

@IsTest
public class OrderVerificationTest {
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
	/**
	 * @description Test to verify that if no items are present in the order we can't change the status to activated
	 * @expected For each order in the list an exception should be thrown and an error should be present and display the message set in the error
	 */
	@IsTest
	static void NoItemsSetInOrderShouldReturnAnErrorTest() {
		List<Order> orders = [
				SELECT Id, AccountId, Status, (
						SELECT Id, UnitPrice, Quantity, OrderId
						FROM OrderItems
				)
				FROM Order
				WHERE Name LIKE 'Order_%'
		];

		for (Order order : orders) {
			order.Status = 'Activated';//We want to change the status to activated
			delete order.OrderItems;//We add to manually delete the order items create by the TestDataFactory
		}

		Test.startTest();

		try {
			update orders;

		} catch (Exception e) {
			Boolean expectedExceptionThrown = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
			Boolean expectedMessage = e.getMessage().contains('Please add product to the order before changing status') ? true : false;


			System.assertEquals(expectedExceptionThrown, true);
			System.assertEquals(expectedMessage, true);

		}

		Test.stopTest();
		orders = [
				SELECT Id, AccountId, Status, (
						SELECT Id, UnitPrice, Quantity, OrderId
						FROM OrderItems
				)
				FROM Order
				WHERE Name LIKE 'Order_%'
		];

		for (Order ord : orders) {
			System.assertEquals('Draft', ord.Status);//All orders should have the status draft
		}
	}
	/**
	 * @description Test to verify that if no items are present in the order we can't change the status to activated
	 * @expected If items are set in the order we can change the status to activated without any error and exception
	 */
	@IsTest
	static void ItemsSetInOrderShouldNotReturnAnErrorTest() {
		List<Order> orders = [
				SELECT Id, AccountId, Status, (
						SELECT Id, UnitPrice, Quantity, OrderId
						FROM OrderItems
				)
				FROM Order
				WHERE Name LIKE 'Order_%'
		];


		for (Order order : orders) {
			order.Status = 'Activated';

		}

		Test.startTest();
		try {
			update orders;

		} catch (Exception e) {

			System.debug(e);

		}
		Test.stopTest();
		orders = [
				SELECT Id, AccountId, Status, (
						SELECT Id, UnitPrice, Quantity, OrderId
						FROM OrderItems
				)
				FROM Order
				WHERE Name LIKE 'Order_%'
		];

		for (Order ord : orders) {
			System.assertEquals('Activated', ord.Status);
		}

	}
}