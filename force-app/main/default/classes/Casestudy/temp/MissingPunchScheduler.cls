global class MissingPunchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new MissingPunchBatch(), 200);
    }
}
