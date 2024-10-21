#!/bin/bash

BANKCODE="bjb"

export TZ='Asia/Jakarta'

# Ambil data dari Bank BJB
response=$(curl -s 'https://bankbjb.co.id/currency/filter' \
  -X 'POST' \
  -H 'Accept: */*' \
  -H 'Accept-Language: id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Length: 0' \
  -H 'Cookie: _ga=GA1.1.1392771675.1729333260; _ga_PW8VNVXNNY=GS1.1.1729345813.2.1.1729345821.0.0.0' \
  -H 'Origin: https://bankbjb.co.id' \
  -H 'Pragma: no-cache' \
  -H 'Referer: https://bankbjb.co.id/page/daftar-kurs' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Chromium";v="129", "Not=A?Brand";v="8"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"')

# Ambil nilai kurs USD dari JSON respons
ttBeli=$(echo $response | jq -r '.data[] | select(.code == "USD") | .counterBuy')
ttJual=$(echo $response | jq -r '.data[] | select(.code == "USD") | .counterSell')

# Format angka, tambahkan koma untuk ribuan dan desimal
ttBeli=$(printf "%'.2f\n" $ttBeli | sed 's/\./,/g' | sed ':a;s/\B[0-9]\{3\}\(\,\|$\)/.&/;ta')
ttJual=$(printf "%'.2f\n" $ttJual | sed 's/\./,/g' | sed ':a;s/\B[0-9]\{3\}\(\,\|$\)/.&/;ta')
lastUpdate=$(date '+%d/%m/%y - %H.%M WIB')

# Kirim data ke Cloudflare KV Storage dengan key "bjb"
curl -X PUT "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${CLOUDFLARE_KV_ID}/values/${BANKCODE}" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"bank\":\"${BANKCODE}\",\"ttBeli\":\"${ttBeli}\",\"ttJual\":\"${ttJual}\",\"lastUpdate\":\"${lastUpdate}\"}"

# Output hasil
echo "bank: $BANKCODE"
echo "ttBeli: $ttBeli"
echo "ttJual: $ttJual"
echo "lastUpdate: $lastUpdate"
