/**
 * Created by lilas on 02/08/2021.
 */

global class ScheduleBatchReminderTasks implements Schedulable{
	global void execute(SchedulableContext ctx) {
		ReminderForAccountInactivityBatch reminder = new ReminderForAccountInactivityBatch();
		Id batchId = Database.executeBatch(reminder,100);

	}
}