#!/bin/bash

export TZ="Asia/Jakarta"
# Ambil HTML halaman dengan curl
response=$(curl -s 'https://www.bi.go.id/id/statistik/informasi-kurs/jisdor/default.aspx' \
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
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36')

# Gunakan xmllint untuk mengambil tanggal dan harga
tanggal=$(echo "$response" | xmllint --html --xpath '//tbody/tr[1]/td[1]/text()' - 2>/dev/null)
harga=$(echo "$response" | xmllint --html --xpath '//tbody/tr[1]/td[2]/text()' - 2>/dev/null)

lastUpdate=$(date '+%d/%m/%y - %H.%M WIB')

#    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/${COUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${COUDFLARE_KV_JISDOR}/values/${tanggal}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"harga\":\"${harga}\",\"lastUpdate\":\"${lastUpdate}\"}"

# Output hasil
echo "tanggal: $tanggal"
echo "harga: $harga"
echo "lastUpdate: $lastUpdate"
