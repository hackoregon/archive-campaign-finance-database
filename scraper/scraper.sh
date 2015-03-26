#!/bin/bash

shopt -s expand_aliases
alias curl="curl -s -A \"Mozilla/5.0\""

curl -c cookies -o /dev/null "https://secure.sos.state.or.us/orestar/GotoSearchByElection.do"

search_page="https://secure.sos.state.or.us/orestar/CommitteeSearchSecondPage.do"
dump_page="https://secure.sos.state.or.us/orestar/XcelSooSearch"

for year in $(seq 2016 -1 1989)
do
    if [ ! -f scraped_data/comms/$year.xls ]; then
        #  committees
        echo "searching $year"
        curl -b cookies -o /dev/null --data "yearActive=$year&discontinuedSOO=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
        curl -b cookies $dump_page > scraped_data/comms/$year.xls

        # candidate controlled committees
        echo "searching $year"
        curl -b cookies -o /dev/null --data "yearActive=$year&allCandidateConComm=on&discontinuedSOO=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
        curl -b cookies $dump_page > scraped_data/comms/$year-cc.xls

        # slate mailer organizations
        echo "searching $year"
        curl -b cookies -o /dev/null --data "yearActive=$year&allSlateMailer=on&discontinuedSOO=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
        curl -b cookies $dump_page > scraped_data/comms/$year-sl.xls

        # independent expenditure filers
        echo "searching $year"
        curl -b cookies -o /dev/null --data "yearActive=$year&allIndpendFilers=on&discontinuedSOO=on&buttonName=electionSearch" $search_page
        echo "downloading $year"
        curl -b cookies $dump_page > scraped_data/comms/$year-if.xls
    else
        echo "skipping $year"
    fi
done

for year in scraped_data/comms/*.xls
do
    echo "fetching financials for $year"
    for comm_id in $(in2csv $year | csvcut -c 1 | tail -n +2)
    do
        if [ ! -f scraped_data/fins/$comm_id-0.xls ]; then
            counter=0
            last_tran=$(date +%D)
            while true; do
                echo "searching $comm_id from $last_tran"
                curl -b cookies -o /dev/null "https://secure.sos.state.or.us/orestar/gotoPublicTransactionSearchResults.do?cneSearchFilerCommitteeId=$comm_id&cneSearchTranEndDate=$last_tran"
                echo "downloading $comm_id"
                curl -b cookies "https://secure.sos.state.or.us/orestar/XcelCNESearch" > scraped_data/fins/$comm_id-$counter.xls
                if [ $(in2csv scraped_data/fins/$comm_id-$counter.xls | wc -l) = 5000 ]; then
                    last_tran=$(in2csv scraped_data/fins/$comm_id-$counter.xls | csvcut -c "Tran Date" | tail -n 1)
                    let counter=counter+1
                else
                    break
                fi
            done
        else
            echo "skipping $comm_id"
        fi
    done
done
