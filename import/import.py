import os
import pandas
import psycopg2

conn = psycopg2.connect("dbname=test user=michel")
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
comms = comms.where((pandas.notnull(comms)), None)

for i, row in comms.iterrows():
    tmpl = ", ".join(["%s" for i in range(len(comms.columns))])
    cmd = "INSERT INTO raw_committees VALUES (%s) " % tmpl
    cur.execute(cmd, tuple(row.values))

conn.commit()
#import pdb; pdb.set_trace()

for f in os.listdir('scraped_data/fins'):
    if f.endswith('.xls'):
        try:
            fin = pandas.read_excel(os.path.join('scraped_data/fins', f), 'ORESTAR Export', index_col=0)
            fin = fin.where((pandas.notnull(fin)), None)
            fin = fin.reset_index()
        except Exception:
            continue
        print "inserting %s" % f
        tmpl = ", ".join(["%s" for i in range(len(fin.columns))])
        cmd = "INSERT INTO raw_committee_transactions VALUES (%s) " % tmpl
        cur.executemany(cmd, [tuple(v.values) for i, v in fin.iterrows()])

conn.commit()
