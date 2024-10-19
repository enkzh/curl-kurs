export TZ="Asia/Jakarta"
response=$(curl -s 'https://www.bankjateng.co.id/api/public/kurs/?page_size=99' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'cache-control: no-cache' \
  -H 'cookie: f5avraaaaaaaaaaaaaaaa_session_=HMJBBFIAJLECCPNAKBBDAIPFGKGDBOIDBFJOGBHNBOHBKCDAODHJFLPMLIMBMMCFCBBDCLAMBBNOMJKCKKMAEGMKGPMEMJEJACEGDLEFJLGENJDEKNJPIIMDBIEOEGFI; _gid=GA1.3.1585819750.1729360302; TS01c0baa0=0104e1dfe38805774048127e12f1ca2354bf60f12edf9a2e70a7318173b63c82a658b1378c28a8086fe5a2a323356114f7dd0a5157f68f2258d1eccbb92053eb500a6f886801e42fd6a1ba94032a531a11321f247192e675795e6de766a8d9cc66078094e7; _ga_GV7281HC2L=GS1.1.1729360302.1.1.1729360368.0.0.0; _ga=GA1.1.1243695241.1729360302' \
  -H 'pragma: no-cache' \
  -H 'priority: u=0, i' \
  -H 'sec-ch-ua: "Chromium";v="129", "Not=A?Brand";v="8"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: none' \
  -H 'sec-fetch-user: ?1' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36')
  
  ttBeli=$(echo $response | jq -r '.data[] | select(.currency == "USD/IDR") | .bid')
  ttJual=$(echo $response | jq -r '.data[] | select(.currency == "USD/IDR") | .offer')
  
  ttBeli=$(printf "%.2f\n" $ttBeli | sed 's/\./,/g' | sed ':a;s/\B[0-9]\{3\}\(\,\|$\)/.&/;ta')
  ttJual=$(printf "%.2f\n" $ttJual | sed 's/\./,/g' | sed ':a;s/\B[0-9]\{3\}\(\,\|$\)/.&/;ta')

# printf "%.2f\n" memastikan angka hanya memiliki dua desimal (misalnya 15385.00).
# sed 's/\./,/g' mengganti titik dengan koma untuk pemisah desimal.
# sed ':a;s/\B[0-9]\{3\}\(\,\|$\)/.&/;ta' menambahkan pemisah ribuan.

  lastUpdate=$(date '+%d/%m/%y - %H.%M WIB')
  
  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/f60335e0aa3a7f534a9ed799d5192a34/storage/kv/namespaces/b2282cc52f25464882a822bd11ceb664/values/bjb" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"bank\":\"jawa_tengah\",\"ttBeli\":\"${ttBeli}\",\"ttJual\":\"${ttJual}\",\"lastUpdate\":\"${lastUpdate}\"}"
