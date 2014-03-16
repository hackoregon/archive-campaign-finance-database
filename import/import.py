import os
import pandas
import psycopg2

conn = psycopg2.connect("dbname=hackoregon user=michel")
cur = conn.cursor()

def load_xls(pth, sheet):
    mats = []
    for f in os.listdir(pth):
        if f.endswith('.xls'):
            try:
                mats.append(pandas.read_excel(os.path.join(pth, f), sheet, index_col=0))
            except Exception:
                continue
    return pandas.concat(mats)


comms = load_xls('scraped_data/comms', 'Committee Search Result').reset_index().drop_duplicates('Committee Id')

fins = load_xls('scraped_data/fins', 'ORESTAR Export').reset_index().drop_duplicates('Tran Id')


comms = comms.where((pandas.notnull(comms)), None)
fins = fins.where((pandas.notnull(fins)), None)
for i, row in comms.iterrows():
    print "comm ", i
    tmpl = ", ".join(["%s" for i in range(len(comms.columns))])
    cmd = "INSERT INTO raw_committees VALUES (%s) " % tmpl
    cur.execute(cmd, tuple(row.values))

conn.commit()

for i, row in fins.iterrows():
    print "inserting %s" % row['Tran Id']
    tmpl = ", ".join(["%s" for i in range(len(fins.columns))])
    cmd = "INSERT INTO raw_committee_transactions VALUES (%s) " % tmpl
    #cur.executemany(cmd, [tuple(v.values) for i, v in fin.iterrows()])
    cur.execute(cmd, tuple(row.values))
        
conn.commit()
