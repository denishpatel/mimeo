CREATE OR REPLACE FUNCTION test_mimeo_refresh () RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

v_dblink_schema     text;
v_mimeo_schema      text;
v_ds_id        text;
v_old_search_path   text;
v_source_dblink     text;
v_this_dblink       text;

v_trash             record;
v_refresh_inserter_source   text;

BEGIN

SELECT current_setting('search_path') INTO v_old_search_path;
SELECT nspname INTO v_mimeo_schema FROM pg_namespace n, pg_extension e WHERE e.extname = 'mimeo' AND e.extnamespace = n.oid;
SELECT nspname INTO v_dblink_schema FROM pg_namespace n, pg_extension e WHERE e.extname = 'dblink' AND e.extnamespace = n.oid;
EXECUTE 'SELECT set_config(''search_path'','''||v_mimeo_schema||','||v_dblink_schema||''',''false'')';

v_source_dblink := 'host=localhost port=5432 dbname=mimeo_source user=mimeo_test password=mimeo_test';
v_this_dblink := 'host=localhost port=5432 dbname='||current_database()||' user=mimeo_test password=mimeo_test';

-- Run refresh tests
PERFORM refresh_snap('mimeo_source.snap_test_source', true);
PERFORM refresh_snap('mimeo_dest.snap_test_dest', true);

PERFORM refresh_inserter('mimeo_source.inserter_test_source', true);
PERFORM refresh_inserter('mimeo_dest.inserter_test_dest', true);

PERFORM refresh_updater('mimeo_source.updater_test_source', true);
PERFORM refresh_updater('mimeo_dest.updater_test_dest', true);

EXECUTE 'SELECT set_config(''search_path'','''||v_old_search_path||''',''false'')';

END
$$;
