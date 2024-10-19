#!/bin/bash

BANKCODE="maspion"

export TZ="Asia/Jakarta"
# Ambil HTML halaman dengan curl
#response=$(curl -s 'https://bankmaspion.co.id/exchange-rates')
response=$(curl -s 'https://www.bankmaspion.co.id/exchange-rates' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'cache-control: no-cache' \
  -H 'cookie: _ga_6SH9RHP7ZK=GS1.1.1729359805.1.0.1729359805.0.0.0; _ga=GA1.3.854563524.1729359805; _gid=GA1.3.1436003061.1729359806; XSRF-TOKEN=eyJpdiI6Ikw3YWpySU5OXC9tdlNkK3RJdmNYUDBBPT0iLCJ2YWx1ZSI6IjVZR21vSU9TWTFKcmRrMUJqTVBTMFpvZnpEcTkyWnpLWnBydFRcL1Z6M2J6RUdMVUZWWFRvT01nUWN0ZlBKcHJ4WUxXTzFQYjF3bmpFZVJqRjNZTncwZz09IiwibWFjIjoiYmYzZTE2Mzk2NTE4M2YwZDZlMGQ0ODJhNTI0N2JjMTg5NGMzNGE4N2Q3MjU5YzcwMTI1YjRjZTk3MWExMDc4MSJ9; laravel_session=eyJpdiI6Im5oTmxMU0dmWkpvbDBBWndPWDA2N2c9PSIsInZhbHVlIjoiQzl4cFVnVnZ1YXMrejVqR0JLUnBjemp5ZTd2Umg4RnhMM2hibUZFcDNLemcwRVlUOTNPQ0N3ZnJkNkRFUE9kcytIdTFLMThnMzNMWjA0RGdsdzBDQ3c9PSIsIm1hYyI6IjRmNDM4OGRkOTI4ODFhMGFmYTQzMzAxMjE5MTc0MTcwNGJlNDk5MDc1NTkwNjE1OTAwMTI1NmRlM2U1Mjk4ZWYifQ%3D%3D' \
  -H 'pragma: no-cache' \
  -H 'priority: u=0, i' \
  -H 'referer: https://r.search.yahoo.com/_ylt=Awrx.Gmp7xNnswonegb3RQx.;_ylu=Y29sbwMEcG9zAzUEdnRpZAMEc2VjA3Ny/RV=2/RE=1729388585/RO=10/RU=https%3a%2f%2fwww.bankmaspion.co.id%2fexchange-rates/RK=2/RS=Ob.i37.scpNWkPKNk.cYUROzvLo-' \
  -H 'sec-ch-ua: "Chromium";v="129", "Not=A?Brand";v="8"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: cross-site' \
  -H 'sec-fetch-user: ?1' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36')

# Gunakan xmllint untuk mengambil ttBeli dan ttJual dari tabel TT COUNTER
ttBeli=$(echo "$response" | xmllint --html --xpath '//h3[contains(text(), "TT COUNTER")]/following-sibling::div//tr[td[text()="USD"]]/td[3]/text()' - 2>/dev/null)
ttJual=$(echo "$response" | xmllint --html --xpath '//h3[contains(text(), "TT COUNTER")]/following-sibling::div//tr[td[text()="USD"]]/td[4]/text()' - 2>/dev/null)
  lastUpdate=$(date '+%d/%m/%y - %H.%M WIB')

#    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/${COUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${COUDFLARE_KV_ID}/values/${BANKCODE}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"bank\":\"${BANKCODE}\",\"ttBeli\":\"${ttBeli}\",\"ttJual\":\"${ttJual}\",\"lastUpdate\":\"${lastUpdate}\"}"
  
# Output hasil
echo "bank: $BANKCODE"
echo "ttBeli: $ttBeli"
echo "ttJual: $ttJual"
echo "lastUpdate: $lastUpdate"
