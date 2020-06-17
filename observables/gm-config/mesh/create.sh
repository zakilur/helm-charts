#!/bin/sh 
# Run from this directory

greymatter create cluster < 00.cluster.json
greymatter create cluster < 00.cluster.edge.json
greymatter create domain < 01.domain.json
greymatter create listener < 02.listener.json
greymatter create proxy < 03.proxy.json
greymatter create shared_rules < 04.shared_rules.json
greymatter create shared_rules < 04.shared_rules.edge.json
greymatter create route < 05.route.json
greymatter create route < 05.route.edge.1.json
greymatter create route < 05.route.edge.2.json