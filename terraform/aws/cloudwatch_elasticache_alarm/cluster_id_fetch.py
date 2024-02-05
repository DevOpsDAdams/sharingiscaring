#! /usr/bin/env python
import boto3
import subprocess
import sys

cluster_ids = []
elasticache = boto3.client('elasticache')
clusters = elasticache.describe_cache_clusters()


for cluster in clusters['CacheClusters']:
    cluster_id = cluster['CacheClusterId']
    cluster_ids.append(cluster_id)

print(cluster_ids)
