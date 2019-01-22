#!/usr/bin/env bash

source openweathermap.key

function usage() { echo "Usage: $0 -z ZIP_CODE -k(Optional) API_KEY" 1>&2; exit 1; }

OPTIND=1

while getopts "h?k:z:" opt; do
    case "$opt" in 
        z) 
            ZIPCODE=$OPTARG
            ;;
        k)
            APIKEY=$OPTARG
            ;;
        h|\?\*)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z $ZIPCODE ]]; then usage; fi

#Current weather by zipcode
function get_current_weather() {
    current_weather=$(curl -s "http://api.openweathermap.org/data/2.5/weather?zip=$ZIPCODE,us&APPID=$APIKEY&units=imperial")
    #current_weather=$(cat cur_weather.txt)
}

#5day Forcast
function get_5day_forcast() {
    #five_day_forcast=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?zip=$ZIPCODE,us&APPID=$APIKEY&units=imperial")
    five_day_forcast=$(cat five_day.txt)
}

#Current Conditions
function get_current_cond() {
    current_cond=""
    while read i; do
        current_cond+=`echo $i | jq -c '.description' | tr -d '"'`
        current_cond+=", "
    done < <(echo $current_weather | jq -c '.weather[]')

    current_temp=$(echo $current_weather | jq '.main.temp') 
    current_temp+=$'\xc2\xb0'
    current_temp+="F"
}

#Display the weather
function display_weather() {
    echo "***** Current Conditions"
    echo "************************"
    echo $current_cond $current_temp
}

get_current_weather
#echo $current_weather

get_5day_forcast
#echo $five_day_forcast

get_current_cond

display_weather
