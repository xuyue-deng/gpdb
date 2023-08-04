-- Simple smoke test for ALTER EXTENSION
CREATE AGGREGATE example_agg(int4) (
    SFUNC = int4larger,
    STYPE = int4
);

-- pageinspect has already been installed by the pg_regress framework
ALTER EXTENSION pageinspect ADD AGGREGATE example_agg(int4);
ALTER EXTENSION pageinspect DROP AGGREGATE example_agg(int4);

DROP EXTENSION pageinspect;
CREATE EXTENSION pageinspect;

-- Test creating an extension that already exists. Nothing too exciting about
-- it, but let's keep up the test coverage.
CREATE EXTENSION gp_inject_fault;
