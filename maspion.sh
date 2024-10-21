#!/bin/bash

BANKCODE="maspion"

export TZ="Asia/Jakarta"
# Ambil HTML halaman dengan curl

response=$(curl -s -L 'https://www.bankmaspion.co.id/exchange-rates' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'cache-control: no-cache' \
  -H 'pragma: no-cache' \
  -H 'priority: u=0, i' \
  -H 'sec-ch-ua: "Chromium";v="129", "Not=A?Brand";v="8"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: cross-site' \
  -H 'sec-fetch-user: ?1' \
  -H "Referer: https://bankmaspion.co.id/" \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36')

#echo "$response" | head -n 20  # Menampilkan 20 baris pertama
echo "$response" | xmllint --html --format - 
# Gunakan xmllint untuk mengambil ttBeli dan ttJual dari tabel TT COUNTER
ttBeli=$(echo "$response" | xmllint --html --xpath '//h3[contains(text(), "TT COUNTER")]/following-sibling::div//tr[td[text()="USD"]]/td[3]/text()' - 2>/dev/null)
ttJual=$(echo "$response" | xmllint --html --xpath '//h3[contains(text(), "TT COUNTER")]/following-sibling::div//tr[td[text()="USD"]]/td[4]/text()' - 2>/dev/null)
lastUpdate=$(date '+%d/%m/%y - %H.%M WIB')
# Output hasil
echo "bank: $BANKCODE"
echo "ttBeli: $ttBeli"
echo "ttJual: $ttJual"
echo "lastUpdate: $lastUpdate"

if [[ -z "$ttBeli" || -z "$ttJual" ]]; then
  echo "ttBeli or ttJual is empty. Skipping Cloudflare KV update."
  exit 1
fi

curl -X PUT "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${CLOUDFLARE_KV_ID}/values/${BANKCODE}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"bank\":\"${BANKCODE}\",\"ttBeli\":\"${ttBeli}\",\"ttJual\":\"${ttJual}\",\"lastUpdate\":\"${lastUpdate}\"}"
