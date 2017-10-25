#!/usr/bin/env bash

# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

KUBE_VERSION=v1.8.1
KUBE_IMAGES="gcr.io/google_containers/hyperkube-amd64:${KUBE_VERSION}
gcr.io/google_containers/kube-apiserver-amd64:${KUBE_VERSION}
gcr.io/google_containers/kube-controller-manager-amd64:${KUBE_VERSION}
gcr.io/google_containers/kube-proxy-amd64:${KUBE_VERSION}
gcr.io/google_containers/kube-scheduler-amd64:${KUBE_VERSION}
gcr.io/google_containers/pause-amd64:3.0
gcr.io/google_containers/etcd-amd64:3.0.17"

CHART_IMAGES=""
for CHART_DIR in ./*/ ; do
  if [ -e ${CHART_DIR}values.yaml ] && [ "${CHART_DIR}" != "./helm-toolkit/" ]; then
    CHART_IMAGES+=" $(cat ${CHART_DIR}values.yaml | yq '.images.tags | map(.) | join(" ")' | tr -d '"' )"
  fi
done
ALL_IMAGES="${KUBE_IMAGES} ${CHART_IMAGES}"

jq -n -c -M \
--arg devclass "$(echo ${ALL_IMAGES})" \
'{"bootstrap": {"preload_images": ($devclass|split(" "))}}' | \
python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)'
