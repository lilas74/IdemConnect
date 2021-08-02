/**
 * Created by lilas on 01/08/2021.
 */

global class AccountInactivityReminderBatch implements Database.Batchable<sObject>, Database.Stateful {
	public Integer recordsProcessed = 0;
	/**
	 * @description Creating a batch class apex that is triggered on
	 * first Monday of each month who collects the accounts having no associated orders
	 * nor recall tasks and creates tasks and attached to this account.
	 *
	 * @param info
	 *
	 * @return A Collection of account
	 */
	global Database.QueryLocator start(Database.BatchableContext info) {

		return Database.getQueryLocator(
				'SELECT Id, Name,Owner.Id, (SELECT WhatId, Status, Subject, Priority FROM Tasks WHERE Subject = \'call\')FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');

	}
	/**
	 * @description process each batch of records
	 *
	 * @param info
	 * @param scope , List of Account to update and task
	 */
	global void execute(Database.BatchableContext info, List<Account> scope) {

		List<Task> tasksToUpdate = new List<Task>();
		for (Account account : scope) {
			if (account.Tasks.size() == 0) {
				Task createTasks = new Task();
				createTasks.OwnerId = account.OwnerId;
				createTasks.Status = 'Not started';
				createTasks.Subject = 'Call';
				createTasks.Priority = 'Normal';
				createTasks.IsReminderSet = true;
				createTasks.ReminderDateTime = System.now() + 5;

				tasksToUpdate.add(createTasks);
				recordsProcessed = recordsProcessed + 1;

			}
			//recordsProcessed = recordsProcessed + 1;

		}
		insert tasksToUpdate;
		update scope;

	}
	/**
	 * @description execute any post-processing operations
	 *
	 * @param info
	 */
	global void finish(Database.BatchableContext info) {
		System.debug(recordsProcessed + ' records processed. Shazam!');
		AsyncApexJob job = [
				SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
				FROM AsyncApexJob
				WHERE Id = :info.getJobId()
		];

	}
}