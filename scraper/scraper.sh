curl -s -c cookies -o /dev/null "https://secure.sos.state.or.us/orestar/GotoSearchByElection.do"

search_page="https://secure.sos.state.or.us/orestar/CommitteeSearchSecondPage.do"
dump_page="https://secure.sos.state.or.us/orestar/XcelSooSearch"

for year in $(seq 2016 -1 1989)
do
    if [ ! -f scraped_data/comms/$year.xls ]; then
        echo "searching $year"
        curl -s -b cookies -o /dev/null --data "yearActive=$year&discontinuedSOO=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
#    curl -s -b cookies 'https://secure.sos.state.or.us/orestar/XcelSooSearch' | in2csv -f xls > scraped_data/comms/$year.csv
        curl -s -b cookies $dump_page > scraped_data/comms/$year.xls

        echo "searching $year"
        curl -s -b cookies -o /dev/null --data "yearActive=$year&allCandidateConComm=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
        curl -s -b cookies $dump_page > scraped_data/comms/$year-cc.xls

        echo "searching $year"
        curl -s -b cookies -o /dev/null --data "yearActive=$year&allSlateMailer=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
        curl -s -b cookies $dump_page > scraped_data/comms/$year-sl.xls
    else
        echo "skipping $year"
    fi
done

for year in scraped_data/comms/*.xls
do
    echo "fetching financials for $year"
    for comm in $(in2csv $year | csvcut -c 1 | tail -n +2)
    do
        if [ ! -f scraped_data/fins/$comm.xls ]; then
            echo "searching $comm"
            curl -s -b cookies -o /dev/null "https://secure.sos.state.or.us/orestar/gotoPublicTransactionSearchResults.do?cneSearchFilerCommitteeId=$comm"
            echo "downloading $comm"
#        curl -s -b cookies 'https://secure.sos.state.or.us/orestar/XcelCNESearch' | in2csv -f xls > scraped_data/fins/$comm.csv
            curl -s -b cookies 'https://secure.sos.state.or.us/orestar/XcelCNESearch' > scraped_data/fins/$comm.xls
        else
            echo "skipping $comm"
        fi
    done
done
