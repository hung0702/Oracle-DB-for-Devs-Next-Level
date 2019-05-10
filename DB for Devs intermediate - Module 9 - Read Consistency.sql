/*Read inconsistency occurs when multiple users access the same data*/

/*Autonomous transactions allow transactions within transactions, rarely used outside error logging*/

--Sample syntax for declaring autonomous transactions

declare
	pragma autonomous_transaction;
begin
	insert into table_1 values ('col1_value', 2);
	commit;
end;
/

/*Three read phenomena (i.e. issues) can occur when multiple users read/write to the same rows
	• Dirty read: uncommitted row appearing in another transaction, so queries can return data that was never committed
		• Not possible in Oracle db because users cannot view uncommitted rows outside their own transaction
	• Non-repeatable (fuzzy) read: selecting the same row twice returns different results (~non-deterministic) 
	  because row was updated between the queries
		• Oracle has statement-level consistency so fuzzy reads aren't possible in a single query
	• Phantom reads: special fuzzy read where another session inserts/deletes rows matching the where clause of your query
		• Result is ~non-deterministic; also impossible in Oracle using a single statement*/

/*Isolation levels manage which read problems can occur
	• 4 different isolation levels

Levels below 	 | Dirty | Fuzzy | Phantom
Read uncommitted |   Y   |   Y   |   Y
Read committed	 |	 n   |   Y   |   Y
Repeatable reads |	 n   |   n   |   Y
Serializable	 |	 n   |   n   |   n

• Read uncommitted doesn't apply to Oracle since dirty reads are not possible
• Read committed is the default mode in Oracle, and yields statement-level consistency
	• DML can see all data saved before beginning, and any changes by other sessions are hidden after DML begins
	• Achieved through MVCC (multiversion concurrency control
• Repeatable read: not useful in Oracle because MVCC, but a db without MVCC would need this mode
• Serializable: no read phenomena possible because this mode yields transaction-level consistency
	• Any changes from other transactions are hidden from your transaction
	• Your changes are not committed until you commit, so results will not take into consideration your changes until commit
	• Good when transaction accesses the same row multiple times*/

--Sample syntax for setting transaction isolation level (must be first statement of transaction; cannot change mid-way)

set transaction isolation level read committed;

/*Read only is an Oracle mode that resembles serializable that only allows selection, non-select DML throws an exceptions*/

/*Read-write is another mode, identical to read committed*/