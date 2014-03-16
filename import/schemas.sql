
DROP TABLE IF EXISTS raw_committee_transactions;
DROP TABLE IF EXISTS raw_committees;


CREATE TABLE raw_committees (
	"committee_id" INTEGER PRIMARY KEY,
	"committee_name" VARCHAR NOT NULL,
	"committee_type" VARCHAR NOT NULL,
	"committee_subtype" VARCHAR,
	"candidate_office" VARCHAR,
	"candidate_office_group" VARCHAR,
	"filing_date" DATE NOT NULL,
	"organization_filing Date" DATE NOT NULL,
	"treasurer_first_name" VARCHAR,
	"treasurer_last_name" VARCHAR,
	"treasurer_mailing_address" VARCHAR,
	"treasurer_work_phone" VARCHAR,
	"treasurer_fax" VARCHAR,
	"candidate_first_name" VARCHAR,
	"candidate_last_name" VARCHAR,
	"candidate_maling_address" VARCHAR,
	"candidate_work_phone" VARCHAR,
	"candidate_residence_phone" VARCHAR,
	"candidate_fax" VARCHAR,
	"candidate_email" VARCHAR,
	"active_election" VARCHAR,
	"measure" VARCHAR,

        "last_updated" TIMESTAMP,
        "committee_name_vectors" TSVECTOR,
        "measure_vectors" TSVECTOR,
        "all_vectors" TSVECTOR
);

CREATE TRIGGER raw_committees_committee_name_vector_update BEFORE INSERT OR UPDATE
ON raw_committees FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(committee_name_vectors, 'pg_catalog.english', committee_name);
CREATE INDEX raw_committees_committee_name_idx ON raw_committees USING gin(committee_name_vectors);

CREATE TRIGGER raw_committees_measure_vector_update BEFORE INSERT OR UPDATE
ON raw_committees FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(measure_vectors, 'pg_catalog.english', measure);
CREATE INDEX raw_committees_measure_idx ON raw_committees USING gin(measure_vectors);

CREATE TRIGGER raw_committees_search_vector_update BEFORE INSERT OR UPDATE
ON raw_committees FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(all_vectors, 'pg_catalog.english', committee_name, measure);
CREATE INDEX raw_committees_search_idx ON raw_committees USING gin(all_vectors);


CREATE TABLE raw_committee_transactions (
	"tran_id" INTEGER PRIMARY KEY,
	"original_id" INTEGER NOT NULL,
	"tran_date" DATE NOT NULL,
	"tran_status" VARCHAR NOT NULL,
	"filer" VARCHAR,
	"contributor_payee" VARCHAR,
	"sub_type" VARCHAR NOT NULL,
	"amount" FLOAT NOT NULL,
	"aggregate_amount" FLOAT,
	"contributor_payee_committee_id" INTEGER, -- REFERENCES raw_committees (committee_id),
	"filer_id" INTEGER, -- REFERENCES raw_committees (committee_id),
	"attest_by_name" VARCHAR,
	"attest_date" DATE,
	"review_by_name" VARCHAR,
	"review_date" DATE,
	"due_date" DATE,
	"occptn_ltr_date" VARCHAR,
	"pymt_sched_txt" VARCHAR,
	"purp_desc" VARCHAR,
	"intrst_rate" VARCHAR,
	"check_nbr" VARCHAR,
	"tran_stsfd_ind" BOOLEAN,
	"filed_by_name" VARCHAR,
	"filed_date" DATE,
	"addr_book_agent_name" VARCHAR,
	"book_type" VARCHAR,
	"title_txt" VARCHAR,
	"occptn_txt" VARCHAR,
	"emp_name" VARCHAR,
	"emp_city" VARCHAR,
	"emp_state" VARCHAR,
	"employ_ind" BOOLEAN,
	"self_employ_ind" BOOLEAN,
	"addr_line1" VARCHAR,
	"addr_line2" VARCHAR,
	"city" VARCHAR,
	"state" VARCHAR,
	"zip" INTEGER,
	"zip_plus_four" INTEGER,
	"county" VARCHAR,
	"purpose_codes" VARCHAR,
	"exp_date" VARCHAR,

        "last_updated" TIMESTAMP,
        "filer_vectors" TSVECTOR,
        "contributor_payee_vectors" TSVECTOR,
        "purp_desc_vectors" TSVECTOR,
        "all_vectors" TSVECTOR
);

CREATE TRIGGER raw_committee_transactions_search_vector_update BEFORE INSERT OR UPDATE
ON raw_committee_transactions FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(all_vectors, 'pg_catalog.english', filer, contributor_payee, purp_desc);
CREATE INDEX raw_committee_transactions_search_idx ON raw_committee_transactions USING gin(all_vectors);

CREATE TRIGGER raw_committee_transactions_filer_vector_update BEFORE INSERT OR UPDATE
ON raw_committee_transactions FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(filer_vectors, 'pg_catalog.english', filer);
CREATE INDEX raw_committee_transactions_filer_idx ON raw_committee_transactions USING gin(filer_vectors);

CREATE TRIGGER raw_committee_transactions_contributor_payee_vector_update BEFORE INSERT OR UPDATE
ON raw_committee_transactions FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(contributor_payee_vectors, 'pg_catalog.english', contributor_payee);
CREATE INDEX raw_committee_transactions_contributor_payee_idx ON raw_committee_transactions USING gin(contributor_payee_vectors);

CREATE TRIGGER raw_committee_transactions_purp_desc_vector_update BEFORE INSERT OR UPDATE
ON raw_committee_transactions FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(purp_desc_vectors, 'pg_catalog.english', purp_desc);
CREATE INDEX raw_committee_transactions_purp_desc_idx ON raw_committee_transactions USING gin(purp_desc_vectors);
