#!/bin/sh

set -x
set -e

cd ${JIANMU_WORKSPACE}

pwd

ls -al

mvn clean ${JIANMU_MVN_ACTION} ${JIANMU_EXTRA_ARGE}