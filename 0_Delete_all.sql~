BEGIN
	FOR c IN (select table_name from user_tables) LOOP
	execute immediate ('DROP TABLE '||c.table_name||' cascade constraINts purge');
	END LOOP;

	FOR c IN (select trigger_name from user_triggers) LOOP
	execute immediate ('DROP TRIGGER '||c.trigger_name||' purge');
	END LOOP;

	FOR c IN (select synonym_name from user_synonyms) LOOP
	execute immediate ('DROP SYNONYM '||c.synonym_name);
	END LOOP; 

	FOR c IN (select sequence_name from user_sequences) LOOP
	execute immediate ('DROP SEQUENCE '||c.sequence_name);
	END LOOP;

	FOR c IN (select view_name from user_views) LOOP
	execute immediate ('DROP VIEW '||c.view_name);
	END LOOP;

	FOR c IN (select OBJECT_NAME from user_objects) LOOP
	execute immediate ('DROP FUNCTION '||c.OBJECT_NAME);
	END LOOP; 
END;
