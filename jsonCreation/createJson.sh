#!/bin/bash 

# Shell script to create nft metadata

START=1
END=10

for (( i=$START; i<$END; i++ ))
do
    echo  "{" > $i.json
    echo  "  \"name\":\"$i\"," >> $i.json
    echo  "  \"description\":\"Nude Club Reward NFT\", " >> $i.json
    echo  "  \"image\":\"ipfs://QmTtDj2DQGccCoadxceBEXdoQiKte85dhb3MnBfF8Dxj5C/E.png\" " >> $i.json
    echo "}" >> $i.json
done