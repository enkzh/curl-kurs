#!/bin/bash

BANKCODE="jawa_timur"
URL="https://bankjatim.id/en"

export TZ="Asia/Jakarta"
# Ambil HTML halaman dengan curl

response=$(curl -s $URL \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'cache-control: no-cache' \
  -H 'cookie: PHPSESSID=1am6v57grd52lu0752l40ah5e7; _gid=GA1.2.909998381.1729368251; _gcl_au=1.1.2142466010.1729368251; _ga=GA1.2.2061852020.1729368251; _ga_TJWX0P2TCF=GS1.2.1729368251.1.0.1729368251.0.0.0; _fbp=fb.1.1729368253776.213035018712736404; _tt_enable_cookie=1; _ttp=B6mwcWyDFbHpAtso25DNTcCLaUB; _ga_1YJ5BNXE09=GS1.1.1729368251.1.1.1729369084.0.0.0; ion_selected_language=en' \
  -H 'pragma: no-cache' \
  -H 'priority: u=0, i' \
  -H 'referer: https://bankjatim.id/en/exchange-rate/rate' \
  -H 'sec-ch-ua: "Chromium";v="129", "Not=A?Brand";v="8"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-user: ?1' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36')

function formatCurr {
    dollar_amt=$1

    # Pisahkan dollar dan cents jika ada
    if [[ $dollar_amt == *"."* ]]; then
        cent_amt=",$(echo $dollar_amt | cut -d"." -f2 | cut -c1-2)"  # Ganti "." dengan ","
        dollar_amt=$(echo $dollar_amt | cut -d"." -f1)
    else
        cent_amt=",00"
    fi

    # Format dollar_amt dengan tanda titik sebagai pemisah ribuan
    dollar_fin=$(printf "%'d" "$dollar_amt" | sed 's/,/./g')  # Ganti "," dengan "." untuk pemisah ribuan

    # Gabungkan kembali hasilnya dengan cent_amt
    echo "$dollar_fin$cent_amt"
}

# Periksa kode respons HTTP
http_code=$(echo "$response" | tail -n1)  # Ambil kode status HTTP
if [[ "$http_code" -ne 200 ]]; then
  echo "Error: Received HTTP code $http_code"
  exit 1
fi

if [[ -z "$response" ]]; then
  echo "Response is empty."
  exit 1
fi

# Debugging: Periksa output HTML
# echo "$response" | xmllint --html --format -  # Format output HTML untuk memeriksa strukturnya


# Gunakan xmllint untuk mengambil ttBeli dan ttJual dari tabel TT COUNTER
ttBeli=$(echo "$response" | xmllint --html --xpath '//td[@id="tt-buyUSD"]/@data-value' - 2>/dev/null | sed 's/data-value="//;s/"//')
ttJual=$(echo "$response" | xmllint --html --xpath '//td[@id="tt-sellUSD"]/@data-value' - 2>/dev/null | sed 's/data-value="//;s/"//')
# echo "ttBeli raw: $ttBeli"
# echo "ttJual raw: $ttJual"

# Mengubah raw value menjadi integer dan memastikan formatting sesuai
formatted_ttBeli=$(formatCurr $ttBeli)
formatted_ttJual=$(formatCurr $ttJual)

lastUpdate=$(date '+%d/%m/%y - %H.%M WIB')

  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${CLOUDFLARE_KV_ID}/values/${BANKCODE}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"bank\":\"${BANKCODE}\",\"ttBeli\":\"${formatted_ttBeli}\",\"ttJual\":\"${formatted_ttJual}\",\"lastUpdate\":\"${lastUpdate}\"}"
  
# Output hasil
echo "bank: $BANKCODE"
echo "ttBeli: $formatted_ttBeli"
echo "ttJual: $formatted_ttJual"
echo "lastUpdate: $lastUpdate"
