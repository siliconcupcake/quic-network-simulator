#!/bin/bash

echo -e "\e[1;33mRunning tests with varying drop-rate \e[0m"
REQUEST=50000000
COUNT=1
for DROP_RATE in {1..10}
do
    echo -e "\e[1;34mSetting drop rate to ${DROP_RATE} % \e[0m"
    SCENARIO="drop-rate --delay=30ms \
        --bandwidth=60Mbps \
        --queue=25 \
        --rate_to_server=0 \
        --rate_to_client=${DROP_RATE}"
    for CC in {0..2}
    do
        SERVER_PARAMS="--cc ${CC}"
        CLIENT_PARAMS="--cc ${CC} -r ${REQUEST} -n ${COUNT}"
        case  ${CC}  in
                0)
                CC_NAME="NewReno Congestion Control"
                    ;;
                1)
                CC_NAME="Cubic Congestion Control"
                    ;;
                2)
                CC_NAME="Vivace Congestion Control"
                    ;;
                *)
                    ;;
        esac
        echo -e "\e[1;34mUsing ${CC_NAME} \e[0m"
        echo -e "\e[1;32mBuilding containers \e[0m"
        docker-compose up -d >> /dev/null 2>&1
        docker exec -it client python3 examples/http3_client.py \
            --ca-certs tests/pycacert.pem \
            ${CLIENT_PARAMS} \
            https://193.167.100.100:4433/
        echo -e "\e[1;31mDestroying containers \e[0m"
        docker-compose down >> /dev/null 2>&1
    done
done

cd logs
if [[ ! -e results ]]; then
    mkdir results
fi

sudo chown -R $USER reno
sudo chown -R $USER cubic
sudo chown -R $USER vivace

echo -e "\e[1;33mPlotting window graph for 6% \e[0m"
gnuplot window-fixed.gp
mv window-fixed.svg results/window-fixed-drop-rate.svg

echo -e "\e[1;33mPlotting loss graph for 6% \e[0m"
gnuplot loss-fixed.gp
mv loss-fixed.svg results/loss-fixed-drop-rate.svg

echo -e "\e[1;33mPlotting latency graph for 6% \e[0m"
gnuplot latency-fixed.gp
mv latency-fixed.svg results/latency-fixed-drop-rate.svg

echo -e "\e[1;33mPlotting window graph for range of drop-rates \e[0m"
python3 window.py 1
gnuplot -e "labelname='Drop Rate (%)'" window-varied.gp
mv window-varied.svg results/window-varied-drop-rate.svg

echo -e "\e[1;33mPlotting loss graph for range of drop-rates \e[0m"
python3 loss.py 1
gnuplot -e "labelname='Drop Rate (%)'" loss-varied.gp
mv loss-varied.svg results/loss-varied-drop-rate.svg

echo -e "\e[1;33mPlotting latency graph for range of drop-rates \e[0m"
python3 latency.py 1
gnuplot -e "labelname='Drop Rate (%)'" latency-varied.gp
mv latency-varied.svg results/latency-varied-drop-rate.svg

echo -e "\e[1;31mRemoving old backups \e[0m"
rm -rf drop-rate
mkdir drop-rate

echo -e "\e[1;32mBacking up logs \e[0m"
mv reno drop-rate/
mv cubic drop-rate/
mv vivace drop-rate/
