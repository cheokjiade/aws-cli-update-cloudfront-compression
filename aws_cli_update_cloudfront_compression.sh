#!/bin/bash
OLDIFS=$IFS
IFS=$'\n'
#list distributions
CF_Distributions=$(sudo aws cloudfront list-distributions)
#iterate through all distributions
for distribution in $(echo $CF_Distributions | jq -c '.DistributionList .Items[]'); do
    CF_ID=$(echo ${distribution} | jq -r '.Id')
    echo $CF_ID
    #echo ${distribution}
    DISTRIBUTION_CONFIG=$(sudo aws cloudfront get-distribution-config --id $CF_ID | jq -c .)
    echo $DISTRIBUTION_CONFIG
    #update all compress to true and get the DistributionConfig value for updating
    CF_JSON=$(echo ${DISTRIBUTION_CONFIG} | jq -c '(.DistributionConfig.CacheBehaviors.Items[]? | .Compress) |= true' | jq -c '(.DistributionConfig.DefaultCacheBehavior? | .Compress) |= true' | jq -c '.DistributionConfig') 
    echo $CF_JSON
    sudo aws cloudfront update-distribution --id $CF_ID --distribution-config $CF_JSON --if-match $(echo ${DISTRIBUTION_CONFIG} | jq -r '.ETag')
done
IFS=$OLDIFS

